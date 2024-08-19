# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #


@value
struct Circle:
    var pos: g2.Vector
    var radius: Float64

    fn __init__(inout self, owned pos: g2.Vector[], owned radius: Float64):
        self.pos = pos
        self.radius = radius

    fn __aabb__(self) -> AABB:
        return AABB(g2.Vector(self.pos.x - self.radius, self.pos.y - self.radius), g2.Vector(self.pos.x + self.radius, self.pos.y + self.radius))

    fn body2field(self, body: Body) -> Self:
        return Self(body.body2field(self.pos), self.radius * body.pos.rotor().nom())

    fn node2field(self, node: Node) -> Self:
        return Self(node.node2field(self.pos), self.radius * node.pos.rotor().nom())

    fn field2cam(self, cam: Camera) -> Self:
        return Self(cam.field2cam(self.pos), self.radius / cam.transform.rotor().nom())

    fn draw(self, renderer: Renderer, cam: Camera, body: Body) raises:
        self.body2field(body).draw(renderer, cam, body.color)

    fn draw(self, renderer: Renderer, cam: Camera, node: Node) raises:
        self.node2field(node).draw(renderer, cam, node.color)

    fn draw(self, renderer: Renderer, cam: Camera, color: Color) raises:
        self.field2cam(cam).draw(renderer, color)

    fn draw(self, renderer: Renderer, color: Color) raises:
        renderer.set_color(color)
        renderer.draw_circle(DPoint[DType.int16](self.pos.x, self.pos.y), self.radius.cast[DType.int16]())
