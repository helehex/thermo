# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #


trait HasBoundingBox:
    fn __aabb__(self) -> AABB: ...


@value
struct AABB:
    var min: g2.Vector
    var max: g2.Vector

    @staticmethod
    fn init_fast(min: g2.Vector[], max: g2.Vector[]) -> Self:
        var result: Self
        result.__init__[True](min, max)
        return result

    fn __init__[fast: Bool = False](inout self, p1: g2.Vector[], p2: g2.Vector[]):
        @parameter
        if fast:
            self.min = p1
            self.max = p2
        else:
            self.min = g2.Vector(min(p1.x, p2.x), min(p1.y, p2.y))
            self.max = g2.Vector(max(p1.x, p2.x), max(p1.y, p2.y))

    fn __init__[T: HasBoundingBox](inout self, primitive: T):
        self = primitive.__aabb__()

    fn __iadd__(inout self, other: Self):
        self.min = g2.Vector(min(self.min.x, other.min.x), min(self.min.y, other.min.y))
        self.max = g2.Vector(max(self.max.x, other.max.x), max(self.max.y, other.max.y))

    fn body2field(self, body: Body) -> Self:
        return Self(body.body2field(self.min), body.body2field(self.max))

    fn node2field(self, node: Node) -> Self:
        return Self(node.node2field(self.min), node.node2field(self.max))

    fn field2cam(self, cam: Camera) -> Self:
        return Self(cam.field2cam(self.min), cam.field2cam(self.max))

    fn draw(self, renderer: Renderer, camera: Camera, body: Body) raises:
        self.body2field(body).draw(renderer, camera, body.color)

    fn draw(self, renderer: Renderer, camera: Camera, node: Node) raises:
        self.node2field(node).draw(renderer, camera, node.color)

    fn draw(self, renderer: Renderer, camera: Camera, color: Color) raises:
        var dim = self.max - self.min

        var p1 = camera.field2cam(self.min)
        var p2 = camera.field2cam(g2.Vector(self.min.x + dim.x, self.min.y))
        var p3 = camera.field2cam(g2.Vector(self.min.x + dim.x, self.min.y + dim.y))
        var p4 = camera.field2cam(g2.Vector(self.min.x, self.min.y + dim.y))
        
        renderer.set_color(color)
        renderer.draw_lines(List(DPoint[DType.float32](p1.x, p1.y), DPoint[DType.float32](p2.x, p2.y), DPoint[DType.float32](p3.x, p3.y), DPoint[DType.float32](p4.x, p4.y), DPoint[DType.float32](p1.x, p1.y)))

    fn draw(self, renderer: Renderer, color: Color) raises:
        var dim = self.max - self.min

        var p1 = self.min
        var p2 = g2.Vector(self.min.x + dim.x, self.min.y)
        var p3 = g2.Vector(self.min.x + dim.x, self.min.y + dim.y)
        var p4 = g2.Vector(self.min.x, self.min.y + dim.y)
        
        renderer.set_color(color)
        renderer.draw_lines(List(DPoint[DType.float32](p1.x, p1.y), DPoint[DType.float32](p2.x, p2.y), DPoint[DType.float32](p3.x, p3.y), DPoint[DType.float32](p4.x, p4.y), DPoint[DType.float32](p1.x, p1.y)))