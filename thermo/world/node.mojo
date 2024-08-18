# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #


@value
struct Node:
    var tag: String
    var pos: g2.Multivector
    var prims: List[Primitive]
    var color: Color

    fn __init__(inout self, tag: String = "", pos: g2.Vector[] = None, owned prims: List[Primitive] = Primitive(Circle(None, 1)), color: Color = Color(255, 255, 255, 255)):
        self.tag = tag
        self.pos = pos + 1
        self.prims = prims
        self.color = color

    fn __aabb__(self) -> AABB:
        var result = AABB(Point(self.pos.v))
        for prim in self.prims:
            result += prim[].node2field(self)
        return result

    fn __eq__(self, other: Self) -> Bool:
        return Reference(self) == Reference(other)

    fn __ne__(self, other: Self) -> Bool:
        return Reference(self) != Reference(other)

    fn node2field(self, pos: g2.Vector[]) -> g2.Vector[]:
        return self.pos.v + (pos * self.pos.rotor())

    fn field2node(self, pos: g2.Vector[]) -> g2.Vector[]:
        return (pos - self.pos.v) / self.pos.rotor()

    fn update(inout self, delta_time: Float64, keyboard: Keyboard):
        if self.tag == "movable":
            var angle = 0
            alias rot_speed = 1

            if keyboard.state[KeyCode.COMMA]:
                angle -= 1
            if keyboard.state[KeyCode.PERIOD]:
                angle += 1

            var rot = self.pos.rotor() * g2.Rotor(angle = angle * delta_time * rot_speed)
            self.pos = self.pos.v + rot

        # clamp pos
        if self.pos.v.x > 1700:
            self.pos.v.x -= 1800
        elif self.pos.v.x < -100:
            self.pos.v.x += 1800
        if self.pos.v.y > 1100:
            self.pos.v.y -= 1200
        elif self.pos.v.y < -100:
            self.pos.v.y += 1200


    fn draw(self, camera: Camera, renderer: Renderer) raises:
        Point(self.pos.v).draw(renderer, camera, Color(0, 255, 255))
        AABB(self).draw(renderer, camera, Color(0, 100, 100))
        for prim in self.prims:
            prim[].draw(renderer, camera, self)
