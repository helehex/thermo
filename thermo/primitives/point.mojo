# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #


@value
@register_passable("trivial")
struct Point:
    var pos: g2.Vector

    fn __init__(inout self, owned x: Float64, owned y: Float64):
        self.pos = g2.Vector(x, y)

    fn __init__(inout self, owned vector: g2.Vector[]):
        self.pos = vector

    fn __aabb__(self) -> AABB:
        return AABB(self.pos, self.pos)

    fn __eq__(self, other: Self) -> Bool:
        return self.pos == other.pos

    fn body2field(self, body: Body) -> Self:
        return Self(body.body2field(self.pos))

    fn node2field(self, node: Node) -> Self:
        return Self(node.node2field(self.pos))

    fn field2cam(self, cam: Camera) -> Self:
        return Self(cam.field2cam(self.pos))

    fn draw(self, renderer: Renderer, cam: Camera, body: Body) raises:
        self.body2field(body).draw(renderer, cam, body.color)

    fn draw(self, renderer: Renderer, cam: Camera, node: Node) raises:
        self.node2field(node).draw(renderer, cam, node.color)

    fn draw(self, renderer: Renderer, cam: Camera, color: mojo_sdl.Color) raises:
        self.field2cam(cam).draw(renderer, color)

    fn draw(self, renderer: Renderer, color: mojo_sdl.Color) raises:
        renderer.set_color(color)
        renderer.draw_point(self.pos.x.cast[DType.float32](), self.pos.y.cast[DType.float32]())