# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #

from math import atan2


# TODO: FIX setting properties on b1 here has no effect...
#       I'm not sure why, reading works fine, there's no
#       copies of bodies anywhere... i have no idea... 
#       It's causing issues with the impulse cache as well

# TODO: Should not be using arg and angle,
#       but velocity rotor is not normalized.


@value
struct Contact:
    var collision: UnsafePointer[Collision]
    var position: g2.Vector
    var normal: g2.Vector
    var penetration: Float64
    var prepulse: g2.Vector
    var invect: g2.Vector
    var b1o: g2.Vector
    var b2o: g2.Vector
    var elas: Float64

    fn __init__(inout self):
        self.collision = UnsafePointer[Collision]()
        self.position = None
        self.normal = None
        self.prepulse = None
        self.penetration = slop
        self.b1o = None
        self.b2o = None
        self.invect = None
        self.elas = 0

    fn __init__(inout self, collision: Collision, position: g2.Vector[], normal: g2.Vector[], penetration: Float64):
        self.collision = UnsafePointer.address_of(collision)

        var b1 = collision.b1
        var b2 = collision.b2
        var v: g2.Vector

        self.position = position
        self.normal = normal
        self.penetration = penetration / 2
        self.prepulse = None

        v = position - b1[].pos.v
        self.b1o = g2.Vector(v.outer(normal), -v.inner(normal))
        v = position - b2[].pos.v
        self.b2o = g2.Vector(v.outer(normal), -v.inner(normal))

        self.elas = self.collision[].elas * ((b2[].vel.v - b1[].vel.v).inner(normal) + (b2[].vel.rotor().arg() * self.b2o.x) - (b1[].vel.rotor().arg() * self.b1o.x))

        var b1v = g2.Vector(self.b1o.x * self.b1o.x, self.b1o.y * self.b1o.y) / b1[].iner
        var b2v = g2.Vector(self.b2o.x * self.b2o.x, self.b2o.y * self.b2o.y) / b2[].iner
        v = b1v + b2v

        var i = (1.0/b1[].mass) + (1.0/b2[].mass)

        self.invect = g2.Vector(1.0/(v.x + i), 1.0/(v.y + i))

    fn start(inout self):
        var b1 = self.collision[].b1
        var b2 = self.collision[].b2
        var v = g2.Vector(self.prepulse.inner(self.normal), self.prepulse.outer(self.normal))
        b1[].dvel = b1[].dvel.trans((v/b1[].mass) + g2.Rotor(angle=self.prepulse.inner(self.b1o)/b1[].iner))
        b2[].dvel = b2[].dvel.trans(((v/b2[].mass) + g2.Rotor(angle=self.prepulse.inner(self.b2o)/b2[].iner)).coj())

    fn solve(inout self):
        var b1 = self.collision[].b1
        var b2 = self.collision[].b2
        var i: Float64
        var f: Float64
        var n = self.prepulse.x
        var t = self.prepulse.y
        var v: g2.Vector
        var tangent = self.normal.nrm()

        var b1r = b1[].vel.rotor().arg() + b1[].dvel.rotor().arg()
        var b2r = b2[].vel.rotor().arg() + b2[].dvel.rotor().arg()

        # solve velocity tangent
        i = (((b2[].vel.v + b2[].dvel.v) - (b1[].vel.v + b1[].dvel.v)).inner(tangent) + (b2r * self.b2o.y) - (b1r * self.b1o.y)) * self.invect.y
        var clmp = self.prepulse.x * self.collision[].fric
        f = min(max(t + i, -clmp), clmp)
        i = f - t
        t = f
        v = tangent * i
        b1[].dvel = (b1[].dvel).trans((v/b1[].mass) + g2.Rotor(angle=(self.b1o.y*i)/b1[].iner))
        b2[].dvel = (b2[].dvel).trans(((v/b2[].mass) + g2.Rotor(angle=(self.b2o.y*i)/b2[].iner)).coj())

        b1r = b1[].vel.rotor().arg() + b1[].dvel.rotor().arg()
        b2r = b2[].vel.rotor().arg() + b2[].dvel.rotor().arg()

        # solve velocity normal
        i = (self.elas + ((b2[].vel.v + b2[].dvel.v) - (b1[].vel.v + b1[].dvel.v)).inner(self.normal) + (b2r * self.b2o.x) - (b1r * self.b1o.x)) * self.invect.x
        f = max(0, n + i)
        i = f - n
        n = f
        v = self.normal * i
        b1[].dvel = (b1[].dvel).trans((v/b1[].mass) + g2.Rotor(angle=(self.b1o.x*i)/b1[].iner))
        b2[].dvel = (b2[].dvel).trans(((v/b2[].mass) + g2.Rotor(angle=(self.b2o.x*i)/b2[].iner)).coj())

        # cache prepulse
        self.prepulse = g2.Vector(n, t)

        # solve position normal
        # i = (self.penetration + ((b2[].dpos.v + b2[].dvel.v) - (b1[].dpos.v + b1[].dvel.v)).inner(self.normal) + ((b2[].dpos.rotor().arg() + b2[].dvel.rotor().arg()) * self.b2o.x) - ((b1[].dpos.rotor().arg() + b1[].dvel.rotor().arg()) * self.b1o.x)) * self.invect.x
        i = (self.penetration + (b2[].dpos.v - b1[].dpos.v).inner(self.normal) + (b2[].dpos.rotor().arg() * self.b2o.x) - (b1[].dpos.rotor().arg() * self.b1o.x)) * self.invect.x
        i = max(0, i)
        v = self.normal * i
        b1[].dpos = b1[].dpos.trans((v/b1[].mass) + g2.Rotor(angle=(self.b1o.x*i)/b1[].iner))
        b2[].dpos = b2[].dpos.trans(((v/b2[].mass) + g2.Rotor(angle=(self.b2o.x*i)/b2[].iner)).coj())
