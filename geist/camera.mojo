alias clear_color = Color(12, 8, 6, 0)

@value
struct Camera:
    var entity: Entity
    var target: Texture

    fn camera2world(self, world: World, pos: g2.Vector[]) -> g2.Vector[]:
        return (pos * world.rotation_components[self.entity.id].unsafe_value()[].rotation) + world.position_components[self.entity.id].unsafe_value()[].position

    fn world2camera(self, world: World, pos: g2.Vector[]) -> g2.Vector[]:
        return ((pos - world.position_components[self.entity.id].unsafe_value()[].position) / world.rotation_components[self.entity.id].unsafe_value()[].rotation)

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