# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #


@value
struct Line:
    var beg: g2.Vector
    var end: g2.Vector

    fn __aabb__(self) -> AABB:
        return AABB(g2.Vector(min(self.beg.x, self.end.x), min(self.beg.y, self.end.y)), g2.Vector(max(self.beg.x, self.end.x), max(self.beg.y, self.end.y)))

    fn normal(self) -> g2.Vector:
        var rel = self.end - self.beg
        var sep = rel.nom()
        return g2.Vector(-rel.y / sep, rel.x / sep)

    fn body2field(self, body: Body) -> Self:
        return Self(body.body2field(self.beg), body.body2field(self.end))

    fn node2field(self, node: Node) -> Self:
        return Self(node.node2field(self.beg), node.node2field(self.end))

    fn field2cam(self, cam: Camera) -> Self:
        return Self(cam.field2cam(self.beg), cam.field2cam(self.end))

    fn draw(self, renderer: Renderer, cam: Camera, body: Body) raises:
        self.body2field(body).draw(renderer, cam, body.color)

    fn draw(self, renderer: Renderer, cam: Camera, node: Node) raises:
        self.node2field(node).draw(renderer, cam, node.color)

    fn draw(self, renderer: Renderer, cam: Camera, color: Color) raises:
        self.field2cam(cam).draw(renderer, color)

    fn draw(self, renderer: Renderer, color: Color) raises:
        renderer.set_color(color)
        renderer.draw_line(self.beg.x.cast[DType.float32](), self.beg.y.cast[DType.float32](), self.end.x.cast[DType.float32](), self.end.y.cast[DType.float32]())

@value
struct NLine:
    var line: Line
    var normal: Point

    fn __init__(inout self, line: Line):
        self.line = line
        self.normal = line.normal()