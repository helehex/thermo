alias clear_color = Color(12, 8, 6, 0)

@value
struct Camera:
    var entity: Entity
    var target: Texture

    fn camera2world(self, world: World, pos: g2.Vector[]) -> g2.Vector[]:
        return (pos * world.rotation_components[self.entity.id].unsafe_value()[].rotation) + world.position_components[self.entity.id].unsafe_value()[].position

    fn world2camera(self, world: World, pos: g2.Vector[]) -> g2.Vector[]:
        return ((pos - world.position_components[self.entity.id].unsafe_value()[].position) / world.rotation_components[self.entity.id].unsafe_value()[].rotation)

    fn update[lif: ImmutableLifetime](inout self, game: UnsafePointer[Game[lif]], delta_time: Float64):

        # rotation
        var angle = 0
        alias rot_speed = 0.5

        if game[].keyboard.state[KeyCode.Q]:
            angle -= 1
        if game[].keyboard.state[KeyCode.E]:
            angle += 1

        # zoom
        var zoom = 0

        if game[].keyboard.state[KeyCode.LSHIFT]:
            zoom -= 1
        if game[].keyboard.state[KeyCode.SPACE]:
            zoom += 1

        var rot = g2.Rotor(
            angle=angle * delta_time * rot_speed
        ) * (1 + (zoom * delta_time))

        # position
        var mov = g2.Vector()
        alias mov_speed = 1000

        if game[].keyboard.state[KeyCode.A]:
            mov.x -= 1
        if game[].keyboard.state[KeyCode.D]:
            mov.x += 1
        if game[].keyboard.state[KeyCode.W]:
            mov.y -= 1
        if game[].keyboard.state[KeyCode.S]:
            mov.y += 1

        if not mov.is_zero():
            mov = (mov / mov.nom()) * game[].world.rotation_components[self.entity.id].unsafe_value()[].rotation * delta_time * mov_speed

        var new_transform = (game[].world.position_components[self.entity.id].unsafe_value()[].position + game[].world.rotation_components[self.entity.id].unsafe_value()[].rotation).trans(mov + rot)
        UnsafePointer.address_of(game[].world.position_components[self.entity.id].unsafe_value()[])[] = new_transform.vector()
        UnsafePointer.address_of(game[].world.rotation_components[self.entity.id].unsafe_value()[])[] = new_transform.rotor()

    fn draw(self, world: World, renderer: Renderer) raises:
        renderer.set_target(self.target)
        renderer.set_color(clear_color)
        renderer.clear()

        for idx in range(len(world.sprite_components._data)):
            tex_w = UnsafePointer[IntC].alloc(1)
            tex_h = UnsafePointer[IntC].alloc(1)
            renderer.sdl[]._sdl.query_texture(world.sprite_components._data[idx].sprite[]._texture_ptr, UnsafePointer[UInt32](), UnsafePointer[IntC](), tex_w, tex_h)
            sprite2camera = self.world2camera(world, world.position_components[world.sprite_components._idx2lbl[idx]].unsafe_value()[].position)
            var rot = world.rotation_components[self.entity.id].unsafe_value()[].rotation
            var scale = rot.nom()
            var angle = -rot.arg() * 180 / stdlib.math.pi
            renderer.copy(world.sprite_components._data[idx].sprite[], None, Rect(sprite2camera.x, sprite2camera.y, tex_w[].cast[DType.float64]() / scale, tex_h[].cast[DType.float64]() / scale), angle, Point(tex_w[]/2, tex_h[]/2), RendererFlip{value:RendererFlip.NONE})

        renderer.reset_target()
        renderer.copy(self.target, None)