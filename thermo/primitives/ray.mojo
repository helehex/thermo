# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #

alias MAX = 10000
alias MIN = -10000


@value
struct Ray:
    var beg: g2.Vector
    var dir: g2.Vector

    fn __aabb__(self) -> AABB:
        if self.dir.x > self.beg.x:
            if self.dir.y > self.beg.y:
                return AABB.init_fast(self.beg, g2.Vector(MAX, MAX))
            else:
                return AABB.init_fast(g2.Vector(self.beg.x, MIN), g2.Vector(MAX, self.beg.y))
        else:
            if self.dir.y > self.beg.y:
                return AABB.init_fast(g2.Vector(MIN, self.beg.y), g2.Vector(self.beg.x, MAX))
            else:
                return AABB.init_fast(g2.Vector(MIN, MIN), self.beg)

    fn normal(self) -> g2.Vector:
        var rel = self.dir - self.beg
        var sep = rel.nom()
        return g2.Vector(-rel.y / sep, rel.x / sep)

    fn body2field(self, body: Body) -> Self:
        return Self(body.body2field(self.beg), body.body2field(self.dir))

    fn node2field(self, node: Node) -> Self:
        return Self(node.node2field(self.beg), node.node2field(self.dir))

    fn field2cam(self, cam: Camera) -> Self:
        return Self(cam.field2cam(self.beg), cam.field2cam(self.dir))

    fn draw(self, renderer: Renderer, cam: Camera, body: Body) raises:
        self.body2field(body).draw(renderer, cam, body.color)

    fn draw(self, renderer: Renderer, cam: Camera, node: Node) raises:
        self.node2field(node).draw(renderer, cam, node.color)

    fn draw(self, renderer: Renderer, cam: Camera, color: Color) raises:
        self.field2cam(cam).draw(renderer, color)

    fn draw(self, renderer: Renderer, color: Color) raises:
        var end = ((self.dir - self.beg) * 100) + self.beg
        renderer.set_color(color)
        renderer.draw_line(self.beg.x.cast[DType.float32](), self.beg.y.cast[DType.float32](), end.x.cast[DType.float32](), end.y.cast[DType.float32]())