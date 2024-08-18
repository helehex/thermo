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
    var _bodies: List[Body]
    var _cameras: List[Camera]
    # var updateables: List[update_fn]
    # var renderables: List[render_fn]


    fn __init__(inout self):
        self.gravity = None
        self._nodes = List[Node]()
        self._bodies = List[Body]()
        self._cameras = List[Camera]()
        # self.updateables = List[update_fn]()


    fn __init__(inout self, renderer: Renderer, gravity: g2.Multivector[]) raises:
        self.gravity = gravity
        self._nodes = List[Node](capacity=1000)
        self._bodies = List[Body](capacity=1000)
        self._cameras = List[Camera](capacity=1000)
        # self.updateables = List[update_fn]()
        # self.renderables = List[render_fn]()
        self += Camera(renderer, g2.Multivector(1, g2.Vector(800, 500)), g2.Vector(800, 500), 1, 1)
        


    fn __iadd__(inout self, owned camera: Camera):
        if len(self._cameras) == 0:
            camera.is_main_camera = True
        self._cameras.append(camera^)
        # var _camera = Reference(self._cameras[-1])
        # fn update(delta_time: Float64, key_state: List[Bool]):
        #     _camera[].update(delta_time, key_state)
        # self.updateables.append(update^)


    fn __iadd__(inout self, owned body: Body):
        self._bodies.append(body^)
        # var _body = Reference(self._bodies[-1])
        # fn update(delta_time: Float64, key_state: List[Bool]):
        #     _body[].update(delta_time, key_state)
        # self.updateables.append(update^)


    fn __iadd__(inout self, owned node: Node):
        self._nodes.append(node^)
        # var _node = Reference(self._nodes[-1])
        # fn update(delta_time: Float64, key_state: List[Bool]):
        #     _node[].update(delta_time, key_state)
        # self.updateables.append(update^)

    fn __isub__(inout self, camera: Camera) raises:
        _ = self._cameras.pop(self._cameras.index(camera))

    fn __isub__(inout self, body: Body) raises:
        _ = self._bodies.pop(self._bodies.index(body))

    fn __isub__(inout self, node: Node) raises:
        _ = self._nodes.pop(self._nodes.index(node))



    fn simulate(inout self):
        for body in self._bodies:
            if body[].mass < 100000:
                body[].color = Color(127, 127, 0, 255)
                body[].dvel = (body[].dvel.v + self.gravity.v) + (body[].dvel.rotor() * self.gravity.rotor())

            for other_body in self._bodies:
                # aabb phase collision detection
                if body != other_body and near(body[], other_body[]) and (body[].mass < 100000 or other_body[].mass < 100000):
                    body[].add_collision(other_body[])

                # debug touching
                if (body[].mass < 100000 and body != other_body and touching(body[].prims[0].body2field(body[]), other_body[].prims[0].body2field(other_body[]))):
                    body[].color = Color(191, 63, 0, 255)

            # # debug touching
            # for other_node in self._nodes:
            #     if (touching(body[].prims[0].body2field(body[]), other_node[].prims[0].node2field(other_node[]))):
            #         body[].color = sdl.Color(255, 0, 0, 255)

        # contact generation
        for body in self._bodies:
            body[].detect_contacts()

        # solve
        alias iterations = 4
        @parameter
        for _ in range(iterations):
            for body in self._bodies:
                body[].solve_contacts()

        # simulate
        for body in self._bodies:
            body[].simulate()
    
    fn update(inout self, delta_time: Float64, keyboard: Keyboard):
        for camera in self._cameras:
            camera[].update(delta_time, keyboard)

        for node in self._nodes:
            node[].update(delta_time, keyboard)

        for body in self._bodies:
            body[].update(self, delta_time, keyboard)

        # for updateable in self.updateables:
        #     updateable[](delta_time, key_state)

    def draw(self, renderer: Renderer):
        # renderer.set_color(background_clear)
        for camera in self._cameras:
            renderer.set_color(background_clear)
            camera[].draw(self, renderer)
