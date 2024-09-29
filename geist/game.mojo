from pathlib import Path
from collections import Optional
from .controlled import ControlledComponent, controlled_system


@value
struct GameInfo:
    var game_name: String

    # default game info
    fn __init__(inout self):
        self.game_name = "My Game"


struct Game[sdl_lif: ImmutableLifetime]:
    var _sdl: Reference[sdl.SDL, sdl_lif]
    var renderer: sdl.Renderer[sdl_lif]
    var keyboard: sdl.Keyboard[sdl_lif]
    var mouse: sdl.Mouse[sdl_lif]
    var clock: sdl.Clock[sdl_lif]

    var start_fns: List[fn (inout Game[sdl_lif]) -> None]
    var update_fns: List[fn (inout Game[sdl_lif]) -> None]
    var sprites: List[sdl.Texture]

    var running: Bool
    var world: World

    fn __init__(inout self, ref[sdl_lif]_sdl: sdl.SDL, info: GameInfo = GameInfo()) raises:
        self._sdl = _sdl
        var window = sdl.Window(_sdl, info.game_name, 800, 600)
        self.renderer = sdl.Renderer(window^)
        self.keyboard = sdl.Keyboard(_sdl)
        self.mouse = sdl.Mouse(_sdl)
        self.clock = sdl.Clock(_sdl, 1000)
        self.start_fns = List[fn (inout Game[sdl_lif]) -> None]()
        self.update_fns = List[fn (inout Game[sdl_lif]) -> None]()
        self.sprites = List[sdl.Texture]()
        self.running = True
        self.world = World()

    @always_inline
    fn __moveinit__(inout self, owned other: Self):
        self._sdl = other._sdl
        self.renderer = other.renderer^
        self.keyboard = sdl.Keyboard(self._sdl[])
        self.mouse = sdl.Mouse(self._sdl[])
        self.clock = other.clock^
        self.start_fns = other.start_fns^
        self.update_fns = other.update_fns^
        self.sprites = other.sprites^
        self.running = other.running
        self.world = other.world^

    fn register_sprite(owned self, path: Path) raises -> Self:
        self.sprites += sdl.Texture(self.renderer, sdl.Surface(self._sdl[], self._sdl[].img.load_image(path.path.unsafe_cstr_ptr().bitcast[DType.uint8]())))
        return self^

    fn register_sprites(owned self, *paths: Path) raises -> Self:
        for path in paths:
            self = self^.register_sprite(path[])
        return self^

    fn create_camera(owned self, controlled: Optional[ControlledComponent] = None) raises -> Self:
        var size = self.renderer.get_output_size()
        var entity = self.world.create_entity()
        self.world.position_components.__setitem__(entity.id, PositionComponent(g2.Vector()))
        self.world.rotation_components.__setitem__(entity.id, RotationComponent(g2.Rotor(1)))
        if controlled:
            self.world.controlled_components.__setitem__(entity.id, controlled.unsafe_value())
        var camera = Camera(entity, Texture(self.renderer, sdl.TexturePixelFormat.RGBA8888, sdl.TextureAccess.TARGET, size[0], size[1]))
        self.world.cameras += camera
        return self^

    fn create_sprite(inout self, position: g2.Vector[], rotation: g2.Rotor[], sprite_id: Int, controlled: Optional[ControlledComponent] = None):
        var entity = self.world.create_entity()
        self.world.position_components.__setitem__(entity.id, PositionComponent(position))
        self.world.rotation_components.__setitem__(entity.id, RotationComponent(rotation))
        self.world.sprite_components.__setitem__(entity.id, SpriteComponent(UnsafePointer.address_of(self.sprites[sprite_id])))
        if controlled:
            self.world.controlled_components.__setitem__(entity.id, controlled.unsafe_value())

    @always_inline
    fn register_start[func: fn [lif: ImmutableLifetime](inout Game[lif]) -> None](owned self) -> Self:
        self.start_fns += func[sdl_lif]
        return self^

    @always_inline
    fn register_update[func: fn [lif: ImmutableLifetime](inout Game[lif]) -> None](owned self) -> Self:
        self.update_fns += func[sdl_lif]
        return self^

    fn run(owned self) raises:
        for start_fn in self.start_fns:
            start_fn[](self)
        
        while self.running:
            for event in self._sdl[].event_list():
                if event[].isa[sdl.events.QuitEvent]():
                    self.running = False
            for update_fn in self.update_fns:
                update_fn[](self)
            for camera in self.world.cameras:
                camera[].draw(self.world, self.renderer)
            controlled_system(self)
            self.renderer.present()
            self.clock.tick()