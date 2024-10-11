alias clear_color = Color(12, 8, 6, 0)

@value
struct Camera:
    var entity: Entity
    var pivot: g2.Vector
    var target: Texture

    fn camera2world(self, world: World, pos: g2.Vector[]) -> g2.Vector[]:
        return ((pos - self.pivot) * world.rotation_components[self.entity.id].unsafe_value()[].rotation) + (world.position_components[self.entity.id].unsafe_value()[].position - self.pivot)

    fn world2camera(self, world: World, pos: g2.Vector[]) -> g2.Vector[]:
        return ((pos - (world.position_components[self.entity.id].unsafe_value()[].position - self.pivot)) / world.rotation_components[self.entity.id].unsafe_value()[].rotation) + self.pivot

    fn draw(self, world: World, renderer: Renderer) raises:
        renderer.set_target(self.target)
        renderer.set_color(clear_color)
        renderer.clear()

        tex_w = UnsafePointer[IntC].alloc(1)
        tex_h = UnsafePointer[IntC].alloc(1)

        for idx in range(len(world.sprite_components._data)):
            renderer.sdl[]._sdl.query_texture(world.sprite_components._data[idx].sprite[]._texture_ptr, UnsafePointer[UInt32](), UnsafePointer[IntC](), tex_w, tex_h)
            sprite2camera = self.world2camera(world, world.position_components[world.sprite_components._idx2lbl[idx]].unsafe_value()[].position)
            var rot = world.rotation_components[self.entity.id].unsafe_value()[].rotation / world.rotation_components[world.sprite_components._idx2lbl[idx]].unsafe_value()[].rotation
            var scale = rot.nom()
            var angle = -rot.arg() * 180 / stdlib.math.pi
            var sprite_scale = (tex_w[].cast[DType.float64]() / scale, tex_h[].cast[DType.float64]() / scale)
            renderer.copy(world.sprite_components._data[idx].sprite[], None, Rect(sprite2camera.x - sprite_scale[0]/2, sprite2camera.y - sprite_scale[1]/2, sprite_scale[0], sprite_scale[1]), angle, Point(sprite_scale[0]/2, sprite_scale[1]/2), RendererFlip{value:RendererFlip.NONE})
        
        tex_w.free()
        tex_h.free()

        renderer.reset_target()
        renderer.copy(self.target, None)