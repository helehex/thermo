# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #

from utils import Variant


@value
struct Primitive:
    var _data: Variant[AABB, Point, Circle, Line, Ray]

    fn __aabb__(self) -> AABB:
        if self._data.isa[AABB]():
            return self._data.unsafe_get[AABB]()[]
        elif self._data.isa[Point]():
            return self._data.unsafe_get[Point]()[]
        elif self._data.isa[Circle]():
            return self._data.unsafe_get[Circle]()[]
        elif self._data.isa[Line]():
            return self._data.unsafe_get[Line]()[]
        elif self._data.isa[Ray]():
            return self._data.unsafe_get[Ray]()[]
        return Point(None)

    fn body2field(self, body: Body) -> Self:
        if self._data.isa[AABB]():
            return self._data.unsafe_get[AABB]()[].body2field(body)
        elif self._data.isa[Point]():
            return self._data.unsafe_get[Point]()[].body2field(body)
        elif self._data.isa[Circle]():
            return self._data.unsafe_get[Circle]()[].body2field(body)
        elif self._data.isa[Line]():
            return self._data.unsafe_get[Line]()[].body2field(body)
        elif self._data.isa[Ray]():
            return self._data.unsafe_get[Ray]()[].body2field(body)
        return Point(None)

    fn node2field(self, node: Node) -> Self:
        if self._data.isa[AABB]():
            return self._data.unsafe_get[AABB]()[].node2field(node)
        elif self._data.isa[Point]():
            return self._data.unsafe_get[Point]()[].node2field(node)
        elif self._data.isa[Circle]():
            return self._data.unsafe_get[Circle]()[].node2field(node)
        elif self._data.isa[Line]():
            return self._data.unsafe_get[Line]()[].node2field(node)
        elif self._data.isa[Ray]():
            return self._data.unsafe_get[Ray]()[].node2field(node)
        return Point(None)

    fn field2cam(self, cam: Camera) -> Self:
        if self._data.isa[AABB]():
            return self._data.unsafe_get[AABB]()[].field2cam(cam)
        elif self._data.isa[Point]():
            return self._data.unsafe_get[Point]()[].field2cam(cam)
        elif self._data.isa[Circle]():
            return self._data.unsafe_get[Circle]()[].field2cam(cam)
        elif self._data.isa[Line]():
            return self._data.unsafe_get[Line]()[].field2cam(cam)
        elif self._data.isa[Ray]():
            return self._data.unsafe_get[Ray]()[].field2cam(cam)
        return Point(None)

    fn draw(self, renderer: Renderer, cam: Camera, body: Body) raises:
        if self._data.isa[AABB]():
            self._data.unsafe_get[AABB]()[].draw(renderer, cam, body)
        elif self._data.isa[Point]():
            self._data.unsafe_get[Point]()[].draw(renderer, cam, body)
        elif self._data.isa[Circle]():
            self._data.unsafe_get[Circle]()[].draw(renderer, cam, body)
        elif self._data.isa[Line]():
            self._data.unsafe_get[Line]()[].draw(renderer, cam, body)
        elif self._data.isa[Ray]():
            self._data.unsafe_get[Ray]()[].draw(renderer, cam, body)

    fn draw(self, renderer: Renderer, cam: Camera, node: Node) raises:
        if self._data.isa[AABB]():
            self._data.unsafe_get[AABB]()[].draw(renderer, cam, node)
        elif self._data.isa[Point]():
            self._data.unsafe_get[Point]()[].draw(renderer, cam, node)
        elif self._data.isa[Circle]():
            self._data.unsafe_get[Circle]()[].draw(renderer, cam, node)
        elif self._data.isa[Line]():
            self._data.unsafe_get[Line]()[].draw(renderer, cam, node)
        elif self._data.isa[Ray]():
            self._data.unsafe_get[Ray]()[].draw(renderer, cam, node)

    fn draw(self, renderer: Renderer, cam: Camera, color: Color) raises:
        if self._data.isa[AABB]():
            self._data.unsafe_get[AABB]()[].draw(renderer, cam, color)
        elif self._data.isa[Point]():
            self._data.unsafe_get[Point]()[].draw(renderer, cam, color)
        elif self._data.isa[Circle]():
            self._data.unsafe_get[Circle]()[].draw(renderer, cam, color)
        elif self._data.isa[Line]():
            self._data.unsafe_get[Line]()[].draw(renderer, cam, color)
        elif self._data.isa[Ray]():
            self._data.unsafe_get[Ray]()[].draw(renderer, cam, color)

    fn draw(self, renderer: Renderer, color: Color) raises:
        if self._data.isa[AABB]():
            self._data.unsafe_get[AABB]()[].draw(renderer, color)
        elif self._data.isa[Point]():
            self._data.unsafe_get[Point]()[].draw(renderer, color)
        elif self._data.isa[Circle]():
            self._data.unsafe_get[Circle]()[].draw(renderer, color)
        elif self._data.isa[Line]():
            self._data.unsafe_get[Line]()[].draw(renderer, color)
        elif self._data.isa[Ray]():
            self._data.unsafe_get[Ray]()[].draw(renderer, color)