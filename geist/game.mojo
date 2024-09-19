from pathlib import Path
from collections import Optional

struct Game[sdl_lif: ImmutableLifetime]:
    var _sdl: Reference[sdl.SDL, sdl_lif]
    var renderer: sdl.Renderer[sdl_lif]
    var keyboard: sdl.Keyboard[sdl_lif]
    var mouse: sdl.Mouse[sdl_lif]
    var clock: sdl.Clock[sdl_lif]

    var update_fns: List[fn (inout Game[sdl_lif]) -> None]
    var sprites: List[sdl.Texture]

    var running: Bool
    var world: World

    fn __init__(inout self, ref[sdl_lif]_sdl: sdl.SDL) raises:
        self._sdl = _sdl
        var window = sdl.Window(_sdl, "Thermo", 800, 600)
        self.renderer = sdl.Renderer(window^)
        self.keyboard = sdl.Keyboard(_sdl)
        self.mouse = sdl.Mouse(_sdl)
        self.clock = sdl.Clock(_sdl, 1000)
        self.update_fns = List[fn (inout Game[sdl_lif]) -> None]()
        self.sprites = List[sdl.Texture]()
        self.running = True
        self.world = World()

    fn __moveinit__(inout self, owned other: Self):
        self._sdl = other._sdl
        self.renderer = other.renderer^
        self.keyboard = sdl.Keyboard(self._sdl[])
        self.mouse = sdl.Mouse(self._sdl[])
        self.clock = other.clock^
        self.update_fns = other.update_fns^
        self.sprites = other.sprites^
        self.running = other.running
        self.world = other.world^

    fn add_sprite(owned self, path: Path) raises -> Self:
        self.sprites += sdl.Texture(self.renderer, sdl.Surface(self._sdl[], self._sdl[].img.load_image(path.path.unsafe_cstr_ptr().bitcast[DType.uint8]())))
        return self^

    fn add_sprites(owned self, *paths: Path) raises -> Self:
        for path in paths:
            self = self^.add_sprite(path[])
        return self^

    fn create_camera(owned self) raises -> Self:
        var size = self.renderer.get_output_size()
        var entity = self.world.create_entity()
        self.world.position_components.__setitem__(entity.id, PositionComponent(g2.Vector()))
        self.world.rotation_components.__setitem__(entity.id, RotationComponent(g2.Rotor(1)))
        var camera = Camera(entity, Texture(self.renderer, sdl.TexturePixelFormat.RGBA8888, sdl.TextureAccess.TARGET, size[0], size[1]))
        self.world.cameras += camera
        return self^

    fn create_sprite(inout self, position: g2.Vector[], rotation: g2.Rotor[], sprite_id: Int):
        var entity = self.world.create_entity()
        self.world.position_components.__setitem__(entity.id, PositionComponent(position))
        self.world.rotation_components.__setitem__(entity.id, RotationComponent(rotation))
        self.world.sprite_components.__setitem__(entity.id, SpriteComponent(UnsafePointer.address_of(self.sprites[sprite_id])))

    fn register_update[func: fn [lif: ImmutableLifetime](inout Game[lif]) -> None](owned self) -> Self:
        self.update_fns += func[sdl_lif]
        return self^

    fn run(owned self) raises:
        while self.running:
            for event in self._sdl[].event_list():
                if event[].isa[sdl.events.QuitEvent]():
                    self.running = False
            for update_fn in self.update_fns:
                update_fn[](self)
            for camera in self.world.cameras:
                camera[].update(UnsafePointer.address_of(self), self.clock.delta_time)
                camera[].draw(self.world, self.renderer)
            self.renderer.present()
            self.clock.tick()