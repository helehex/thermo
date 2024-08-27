# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #

from collections import Optional


@value
struct Body:

    var pos: g2.Multivector
    var prims: List[Primitive]
    var color: Color

    var dpos: g2.Multivector
    """Delta Position."""

    var vel: g2.Multivector
    """Velocity."""

    var dvel: g2.Multivector
    """Delta Velocity."""

    var mass: Float64
    """Translational Mass."""

    var iner: Float64
    """Inverse Translational Mass."""

    var elas: Float64
    var fric: Float64

    var collisions: List[UnsafePointer[Collision]]

    fn __init__(inout self, pos: g2.Vector[] = None, owned prims: List[Primitive] = Primitive(Circle(None, 1)), color: Color = Color(255, 255, 255, 255), vel: g2.Vector[] = None, mass: Float64 = 1, iner: Float64 = 10000, elas: Float64 = 0.5, fric: Float64 = 0.5):
        self.pos = pos + 1
        self.prims = prims
        self.color = color
        self.dpos = 1
        self.vel = vel + 1
        self.dvel = 1
        self.mass = mass
        self.iner = iner
        self.elas = elas
        self.fric = fric
        self.collisions = List[UnsafePointer[Collision]](capacity = 32)
        self.life = 10

    fn __del__(owned self):
        for collision in self.collisions:
            collision[].destroy_pointee()
            collision[].free()

    fn __aabb__(self) -> AABB:
        var result = AABB(Point(self.pos.v))
        for prim in self.prims:
            result += prim[].body2field(self)
        return result

    fn __eq__(self, other: Self) -> Bool:
        return Reference(self) == Reference(other)

    fn __ne__(self, other: Self) -> Bool:
        return Reference(self) != Reference(other)

    fn body2field(self, pos: g2.Vector[]) -> g2.Vector[]:
        return self.pos.v + (pos * self.pos.rotor())

    fn field2body(self, pos: g2.Vector[]) -> g2.Vector[]:
        return (pos - self.pos.v) / self.pos.rotor()

    fn apply_dvel_at(inout self, p: g2.Vector):
        pass

    fn apply_dpos_at(inout self, p: g2.Vector):
        pass

    fn add_collision(inout self, b1: UnsafePointer[Self], b2: UnsafePointer[Self]):
        for collision in b1[].collisions:
            if collision[][].b2 == b2:
                collision[][].still_near = True
                return
        
        var ptr = UnsafePointer[Collision].alloc(1)
        ptr.init_pointee_move(Collision(b1, b2))
        self.collisions += ptr

    fn detect_contacts(inout self):
        for idx in reversed(range(len(self.collisions))):
            if self.collisions[idx][].still_near:
                self.collisions[idx][].detect()
            else:
                var ptr = self.collisions.pop(idx)
                ptr.destroy_pointee()
                ptr.free()

    fn solve_contacts(inout self):
        for idx in range(len(self.collisions)):
            self.collisions[idx][].solve()

    fn step(inout self):
        self.vel = (self.vel.v + self.dvel.v) + (self.vel.rotor() * self.dvel.rotor())
        self.dvel = 1
        self.pos = (self.pos.v + self.dpos.v + self.vel.v) + (self.pos.rotor() * self.dpos.rotor() * self.vel.rotor())
        self.dpos = 1

    var life: Float64

    fn update(inout self, inout field: Field, delta_time: Float64, keyboard: Keyboard):
        if self.mass < 1000:
            self.life -= delta_time
        if self.life < 0:
            try:
                field -= self
            except:
                pass

    fn draw(self, camera: Camera, renderer: Renderer) raises:
        # AABB(self).draw(renderer, camera, sdl.Color(0, 100, 100))

        for prim in self.prims:
            prim[].draw(renderer, camera, self)

        Point(self.pos.v).draw(renderer, camera, Color(0, 100, 100))

        for collision in self.collisions:
            if collision[]:
                for contact in collision[][].contacts:
                    if contact[].penetration > 0:
                        var l = Line(g2.Vector(contact[].position.x, contact[].position.y), g2.Vector(contact[].position.x + (contact[].normal.x * contact[].penetration), contact[].position.y + (contact[].normal.y * contact[].penetration)))
                        l.draw(renderer, camera, self.color)
                        var p = Point(contact[].position.x, contact[].position.y)
                        p.draw(renderer, camera, Color(255, 0, 255, 255))
