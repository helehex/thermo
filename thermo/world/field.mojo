# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #

# var camera2world = g2.Vector()
# var world2camera = g2.Vector()

alias update_fn = fn (Float64, List[Bool]) escaping -> None
alias render_fn = fn (Camera, Renderer) raises -> None


# fn update[T: Updateable](inout self: T, delta_time: Float64):
#     self.update(delta_time)


# trait Updateable:
#     fn update(inout self, delta_time: Float64, key_state: List[Bool]): ...


alias background_clear = Color(12, 8, 6, 0)

@value
struct Field:
    var gravity: g2.Multivector
    var _nodes: List[Node]
    var _bodies: List[UnsafePointer[Body]]
    var _cameras: List[Camera]
    # var updateables: List[update_fn]
    # var renderables: List[render_fn]


    fn __init__(inout self):
        self.gravity = None
        self._nodes = List[Node]()
        self._bodies = List[UnsafePointer[Body]]()
        self._cameras = List[Camera]()
        # self.updateables = List[update_fn]()


    fn __init__(inout self, renderer: Renderer, gravity: g2.Multivector[]) raises:
        self.gravity = gravity
        self._nodes = List[Node](capacity=1000)
        self._bodies = List[UnsafePointer[Body]](capacity=1000)
        self._cameras = List[Camera](capacity=1000)
        # self.updateables = List[update_fn]()
        # self.renderables = List[render_fn]()
        self += Camera(renderer, g2.Multivector(1, g2.Vector(800, 500)), g2.Vector(800, 500), DRect[DType.float32](0, 0, 1, 1))
        
    fn __iadd__(inout self, owned camera: Camera):
        if len(self._cameras) == 0:
            camera.is_main_camera = True
        self._cameras.append(camera^)

    fn __iadd__(inout self, owned body: Body):
        var ptr = UnsafePointer[Body].alloc(1)
        ptr.init_pointee_move(body)
        self._bodies.append(ptr)

    fn __iadd__(inout self, owned node: Node):
        self._nodes.append(node^)

    fn __isub__(inout self, camera: Camera) raises:
        _ = self._cameras.pop(self._cameras.index(camera))

    fn __isub__(inout self, body: Body) raises:
        var ptr = self._bodies.pop(self._bodies.index(UnsafePointer.address_of(body)))
        ptr.destroy_pointee()
        ptr.free()

    fn __isub__(inout self, node: Node) raises:
        _ = self._nodes.pop(self._nodes.index(node))

    # +------( Step )------+ #
    #
    fn step(inout self):
        for b1 in range(len(self._bodies)):

            if self._bodies[b1][].mass < 100000:
                self._bodies[b1][].color = Color(127, 127, 0, 255)
                self._bodies[b1][].dvel = self._bodies[b1][].dvel.trans(self.gravity)

            for b2 in range(0, len(self._bodies)):

                if b1 == b2 or (self._bodies[b1][].mass > 100000 and self._bodies[b2][].mass > 100000):
                    continue
                
                # aabb phase collision detection
                if near(self._bodies[b1][], self._bodies[b2][]):
                    self._bodies[b1][].add_collision(self._bodies[b1], self._bodies[b2])

                # # debug touching
                # if (body[].mass < 100000 and body != other_body and touching(body[].prims[0].body2field(body[]), other_body[].prims[0].body2field(other_body[]))):
                #     body[].color = Color(191, 63, 0, 255)

            # # debug touching
            # for other_node in self._nodes:
            #     if (touching(body[].prims[0].body2field(body[]), other_node[].prims[0].node2field(other_node[]))):
            #         body[].color = sdl.Color(255, 0, 0, 255)

        # contact generation
        for body in self._bodies:
            body[][].detect_contacts()

        # solve
        alias iterations = 4
        @parameter
        for _ in range(iterations):
            for body in self._bodies:
                body[][].solve_contacts()

        # constrain pos
        for body in self._bodies:
            body[][].step()
    
    # +------( Update )------+ #
    #
    fn update(inout self, delta_time: Float64, keyboard: Keyboard):
        for camera in self._cameras:
            camera[].update(delta_time, keyboard)

        for node in self._nodes:
            node[].update(delta_time, keyboard)

        for body in self._bodies:
            body[][].update(self, delta_time, keyboard)

        # for updateable in self.updateables:
        #     updateable[](delta_time, key_state)

    # +------( Draw )------+ #
    #
    fn draw(self, renderer: Renderer) raises:
        renderer.set_color(background_clear)
        renderer.clear()
        for camera in self._cameras:
            camera[].draw(self, renderer)
