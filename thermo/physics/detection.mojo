# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #
from math import sqrt


# +--------------------------------------------------------------------------+ #
# | Separation
# +--------------------------------------------------------------------------+ #
#
@always_inline("nodebug")
fn separation(a: Point, b: Point) -> Float64:
    return (b.pos - a.pos).nom()


# +--------------------------------------------------------------------------+ #
# | Near
# +--------------------------------------------------------------------------+ #
#
@always_inline("nodebug")
fn near(a: AABB, b: AABB) -> Bool:
    """AABB intersection check."""
    return touching(a, b)





# +--------------------------------------------------------------------------+ #
# | Primitive x Primitive
# +--------------------------------------------------------------------------+ #
#
# @always_inline("nodebug")
# fn touching(a: Node, b: Node) -> Bool:
#     var a_prim: Primitive
#     var b_prim: Primitive

#     if a.prim.isa[AABB]():
#         a_prim = a.prim.unsafe_get[AABB]()[] + a.pos.v
#     elif a.prim.isa[Point]():
#         a_prim = a.prim.unsafe_get[Point]()[] + a.pos.v
#     elif a.prim.isa[Circle]():
#         a_prim = a.prim.unsafe_get[Circle]()[] + a.pos.v
#     elif a.prim.isa[Line]():
#         a_prim = a.prim.unsafe_get[Line]()[] + a.pos.v
#     elif a.prim.isa[Ray]():
#         a_prim = a.prim.unsafe_get[Ray]()[] + a.pos.v
#     else:
#         return False

#     if b.prim.isa[AABB]():
#         b_prim = b.prim.unsafe_get[AABB]()[] + b.pos.v
#     elif b.prim.isa[Point]():
#         b_prim = b.prim.unsafe_get[Point]()[] + b.pos.v
#     elif b.prim.isa[Circle]():
#         b_prim = b.prim.unsafe_get[Circle]()[] + b.pos.v
#     elif b.prim.isa[Line]():
#         b_prim = b.prim.unsafe_get[Line]()[] + b.pos.v
#     elif b.prim.isa[Ray]():
#         b_prim = b.prim.unsafe_get[Ray]()[] + b.pos.v
#     else:
#         return False

#     return touching(a_prim, b_prim)


@always_inline("nodebug")
fn touching(a: Primitive, b: Primitive) -> Bool:
    if a._data.isa[AABB]():
        return touching(a._data.unsafe_get[AABB]()[], b)
    elif a._data.isa[Point]():
        return touching(a._data.unsafe_get[Point]()[], b)
    elif a._data.isa[Circle]():
        return touching(a._data.unsafe_get[Circle]()[], b)
    elif a._data.isa[Line]():
        return touching(a._data.unsafe_get[Line]()[], b)
    elif a._data.isa[Ray]():
        return touching(a._data.unsafe_get[Ray]()[], b)
    else:
        return False


# +--------------------------------------------------------------------------+ #
# | AABB x Primitive
# +--------------------------------------------------------------------------+ #
#
@always_inline("nodebug")
fn touching(a: AABB, b: Primitive) -> Bool:
    if b._data.isa[AABB]():
        return touching(a, b._data.unsafe_get[AABB]()[])
    elif b._data.isa[Point]():
        return touching(a, b._data.unsafe_get[Point]()[])
    elif b._data.isa[Circle]():
        return touching(a, b._data.unsafe_get[Circle]()[])
    elif b._data.isa[Line]():
        return touching(a, b._data.unsafe_get[Line]()[])
    elif b._data.isa[Ray]():
        return touching(a, b._data.unsafe_get[Ray]()[])
    else:
        return False


@always_inline("nodebug")
fn touching(a: AABB, b: AABB) -> Bool:
    return (a.min.x < b.max.x != b.min.x < a.max.x) and (a.min.y < b.max.y != b.min.y < a.max.y)


@always_inline("nodebug")
fn touching(a: AABB, b: Point) -> Bool:
    return a.min.x < b.pos.x < a.max.x and a.min.y < b.pos.y < a.max.y


@always_inline("nodebug")
fn touching(a: AABB, b: Circle) -> Bool:
    # var a_center = Point((a.min.x + a.max.x) / 2, (a.min.y + a.max.y) / 2)

    # naive
    if b.pos.x < a.min.x:
        if b.pos.y < a.min.y:
            return touching(a.min, b)
        elif b.pos.y < a.max.y:
            return b.pos.x + b.radius > a.min.x
        else:
            return touching(Point(a.min.x, a.max.y), b)
    elif b.pos.x < a.max.x:
        if b.pos.y < a.min.y:
            return b.pos.y + b.radius > a.min.y
        elif b.pos.y < a.max.y:
            return True
        else:
            return b.pos.y - b.radius < a.max.y
    else:
        if b.pos.y < a.min.y:
            return touching(Point(a.max.x, a.min.y), b)
        elif b.pos.y < a.max.y:
            return b.pos.x - b.radius < a.max.x
        else:
            return touching(a.max, b)


@always_inline("nodebug")
fn touching(a: AABB, b: Line) -> Bool:
    # naive
    if touching(a, Point(b.beg)) or touching(a, Point(b.end)):
        return True
    elif (b.beg.x > a.max.x and b.end.x > a.max.x) or (b.beg.x < a.min.x and b.end.x < a.min.x) or (b.beg.y > a.max.y and b.end.y > a.max.y) or (b.beg.y < a.min.y and b.end.y < a.min.y):
        return False
    else:
        return touching(Line(a.min, g2.Vector(a.max.x, a.min.y)), b) or touching(Line(g2.Vector(a.max.x, a.min.y), a.max), b) or touching(Line(a.max, g2.Vector(a.min.x, a.max.y)), b) or touching(Line(g2.Vector(a.min.x, a.max.y), a.min), b)


@always_inline("nodebug")
fn touching(a: AABB, b: Ray) -> Bool:
    # naive
    if touching(a, Point(b.beg)) or touching(a, Point(b.dir)):
        return True
    else:
        return touching(Line(a.min, g2.Vector(a.max.x, a.min.y)), b) or touching(Line(g2.Vector(a.max.x, a.min.y), a.max), b) or touching(Line(a.max, g2.Vector(a.min.x, a.max.y)), b) or touching(Line(g2.Vector(a.min.x, a.max.y), a.min), b)


# +--------------------------------------------------------------------------+ #
# | Point x Primitive
# +--------------------------------------------------------------------------+ #
#
@always_inline("nodebug")
fn touching(a: Point, b: Primitive) -> Bool:
    if b._data.isa[AABB]():
        return touching(a, b._data.unsafe_get[AABB]()[])
    elif b._data.isa[Point]():
        return touching(a, b._data.unsafe_get[Point]()[])
    elif b._data.isa[Circle]():
        return touching(a, b._data.unsafe_get[Circle]()[])
    elif b._data.isa[Line]():
        return touching(a, b._data.unsafe_get[Line]()[])
    elif b._data.isa[Ray]():
        return touching(a, b._data.unsafe_get[Ray]()[])
    else:
        return False


@always_inline("nodebug")
fn touching(a: Point, b: AABB) -> Bool:
    return touching(b, a)


@always_inline("nodebug")
fn touching(a: Point, b: Point) -> Bool:
    return a == b


@always_inline("nodebug")
fn touching(a: Point, b: Circle) -> Bool:
    return separation(a, b.pos) < b.radius


@always_inline("nodebug")
fn touching(a: Point, b: Line) -> Bool:
    var rel_a = b.end - a.pos
    var rel_b = b.end - b.beg
    return rel_a.outer(rel_b) == 0 and (rel_b.inner(rel_b) > rel_a.inner(rel_a) > 0)


@always_inline("nodebug")
fn touching(a: Point, b: Ray) -> Bool:
    var rel_a = b.dir - a.pos
    var rel_b = b.dir - b.beg
    return rel_a.outer(rel_b) == 0 and (rel_a.inner(rel_a) > 0)


# +--------------------------------------------------------------------------+ #
# | Circle x Primitive
# +--------------------------------------------------------------------------+ #
#
@always_inline("nodebug")
fn touching(a: Circle, b: Primitive) -> Bool:
    if b._data.isa[AABB]():
        return touching(a, b._data.unsafe_get[AABB]()[])
    elif b._data.isa[Point]():
        return touching(a, b._data.unsafe_get[Point]()[])
    elif b._data.isa[Circle]():
        return touching(a, b._data.unsafe_get[Circle]()[])
    elif b._data.isa[Line]():
        return touching(a, b._data.unsafe_get[Line]()[])
    elif b._data.isa[Ray]():
        return touching(a, b._data.unsafe_get[Ray]()[])
    else:
        return False


@always_inline("nodebug")
fn touching(a: Circle, b: AABB) -> Bool:
    return touching(b, a)

@always_inline("nodebug")
fn touching(a: Circle, b: Point) -> Bool:
    return touching(b, a)


@always_inline("nodebug")
fn touching(a: Circle, b: Circle) -> Bool:
    return separation(a.pos, b.pos) < (a.radius + b.radius)


@always_inline("nodebug")
fn touching(a: Circle, b: Line) -> Bool:
    var rel_a = a.pos - b.beg
    var rel_b = b.end - b.beg
    if rel_a.inner(rel_b) > rel_b.inner(rel_b):
        return separation(b.end, a.pos) < a.radius
    elif rel_a.inner(rel_b) < 0:
        return separation(b.beg, a.pos) < a.radius
    else:
        return abs(rel_a.outer(rel_b)) / separation(b.end, b.beg) < a.radius


@always_inline("nodebug")
fn touching(a: Circle, b: Ray) -> Bool:
    var rel_a = a.pos - b.beg
    var rel_b = b.dir - b.beg
    if rel_a.inner(rel_b) < 0:
        return separation(b.beg, a.pos) < a.radius
    else:
        return abs(rel_a.outer(rel_b)) / separation(b.dir, b.beg) < a.radius


# +--------------------------------------------------------------------------+ #
# | Line x Primitive
# +--------------------------------------------------------------------------+ #
#
@always_inline("nodebug")
fn touching(a: Line, b: Primitive) -> Bool:
    if b._data.isa[AABB]():
        return touching(a, b._data.unsafe_get[AABB]()[])
    elif b._data.isa[Point]():
        return touching(a, b._data.unsafe_get[Point]()[])
    elif b._data.isa[Circle]():
        return touching(a, b._data.unsafe_get[Circle]()[])
    elif b._data.isa[Line]():
        return touching(a, b._data.unsafe_get[Line]()[])
    elif b._data.isa[Ray]():
        return touching(a, b._data.unsafe_get[Ray]()[])
    else:
        return False


fn touching(a: Line, b: AABB) -> Bool:
    return touching(b, a)


fn touching(a: Line, b: Point) -> Bool:
    return touching(b, a)


fn touching(a: Line, b: Circle) -> Bool:
    return touching(b, a)


fn touching(a: Line, b: Line) -> Bool:
    var a_rel = a.end - a.beg
    var b_rel = b.end - b.beg
    var ab_out = a_rel.outer(b_rel)
    var c = b.beg - a.beg
    return (0.0 < c.outer(a_rel) / ab_out < 1) and (0.0 < c.outer(b_rel) / ab_out < 1)


fn touching(a: Line, b: Ray) -> Bool:
    var a_rel = a.end - a.beg
    var b_rel = b.dir - b.beg
    var ab_out = a_rel.outer(b_rel)
    var c = b.beg - a.beg
    return (0.0 < c.outer(a_rel) / ab_out) and (0.0 < c.outer(b_rel) / ab_out < 1)


# +--------------------------------------------------------------------------+ #
# | Ray x Primitive
# +--------------------------------------------------------------------------+ #
#
@always_inline("nodebug")
fn touching(a: Ray, b: Primitive) -> Bool:
    if b._data.isa[AABB]():
        return touching(a, b._data.unsafe_get[AABB]()[])
    elif b._data.isa[Point]():
        return touching(a, b._data.unsafe_get[Point]()[])
    elif b._data.isa[Circle]():
        return touching(a, b._data.unsafe_get[Circle]()[])
    elif b._data.isa[Line]():
        return touching(a, b._data.unsafe_get[Line]()[])
    elif b._data.isa[Ray]():
        return touching(a, b._data.unsafe_get[Ray]()[])
    else:
        return False


fn touching(a: Ray, b: AABB) -> Bool:
    return touching(b, a)


fn touching(a: Ray, b: Point) -> Bool:
    return touching(b, a)


fn touching(a: Ray, b: Circle) -> Bool:
    return touching(b, a)


fn touching(a: Ray, b: Line) -> Bool:
    return touching(b, a)


fn touching(a: Ray, b: Ray) -> Bool:
    var a_rel = a.dir - a.beg
    var b_rel = b.dir - b.beg
    var ab_out = a_rel.outer(b_rel)
    var c = b.beg - a.beg
    return (0.0 < c.outer(a_rel) / ab_out) and (0.0 < c.outer(b_rel) / ab_out)
