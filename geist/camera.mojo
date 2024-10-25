# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #

alias clear_color = Color(12, 8, 6, 0)


@value
struct Camera:
    var entity: Entity
    var pivot: g2.Vector
    var target: Texture
    var _resolution: g2.Vector[DType.int64]

    fn __init__(inout self, entity: Entity, pivot: g2.Vector[], renderer: Renderer) raises:
        self.entity = entity
        self.pivot = pivot
        var res = renderer.get_output_size()
        self._resolution = g2.Vector[DType.int64](res[0], res[1])
        self.target = Texture(renderer, sdl.TexturePixelFormat.RGBA8888, sdl.TextureAccess.TARGET, int(self._resolution.x), int(self._resolution.y))

    fn camera2world(self, world: World, pos: g2.Vector[]) -> g2.Vector[]:
        var scaled_pivot = g2.Vector(self.pivot.x * int(self._resolution.x), self.pivot.y * int(self._resolution.y))
        return ((pos - scaled_pivot) * world.rotation_components[self.entity.id].unsafe_value()[].rotation) + world.position_components[self.entity.id].unsafe_value()[].position

    fn world2camera(self, world: World, pos: g2.Vector[]) -> g2.Vector[]:
        var scaled_pivot = g2.Vector(self.pivot.x * int(self._resolution.x), self.pivot.y * int(self._resolution.y))
        return ((pos - world.position_components[self.entity.id].unsafe_value()[].position) / world.rotation_components[self.entity.id].unsafe_value()[].rotation) + scaled_pivot

    fn draw(self, world: World, renderer: Renderer) raises:
        renderer.set_target(self.target)
        renderer.set_color(clear_color)
        renderer.clear()

        for idx in range(len(world.sprite_components)):
            var sprite_size = renderer.get_texture_size(world.sprite_components._data[idx].sprite)
            sprite2camera = self.world2camera(world, world.position_components[world.sprite_components._idx2lbl[idx]].unsafe_value()[].position)
            var rot = world.rotation_components[self.entity.id].unsafe_value()[].rotation / world.rotation_components[world.sprite_components._idx2lbl[idx]].unsafe_value()[].rotation
            var scale = rot.nom()
            var angle = -rot.arg() * 180 / stdlib.math.pi
            var sprite_scale = (sprite_size[0] / scale, sprite_size[1] / scale)
            renderer.copy(world.sprite_components._data[idx].sprite, None, Rect(sprite2camera.x - sprite_scale[0]/2, sprite2camera.y - sprite_scale[1]/2, sprite_scale[0], sprite_scale[1]), angle, Point(sprite_scale[0]/2, sprite_scale[1]/2), RendererFlip{value:RendererFlip.NONE})

        renderer.reset_target()
        renderer.copy(self.target, None)