# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #

from pathlib import Path
from collections import Optional
from sys.intrinsics import _type_is_eq
from os import abort
from .components import *


@value
struct GameInfo:
    var game_name: String
    var window_size: g2.Vector[DType.int32]

    # default game info
    fn __init__(inout self):
        self.game_name = "My Game"
        self.window_size = g2.Vector[DType.int32](800, 600)


struct Game[sdl_lif: ImmutableLifetime]:
    var _sdl: Reference[sdl.SDL, sdl_lif]
    var renderer: sdl.Renderer[sdl_lif]
    var keyboard: sdl.Keyboard[sdl_lif]
    var mouse: sdl.Mouse[sdl_lif]
    var screen_mouse: g2.Vector
    var world_mouse: g2.Vector
    var clock: sdl.Clock[sdl_lif]

    var start_fns: List[fn (inout Game[sdl_lif]) raises -> None]
    var update_fns: List[fn (inout Game[sdl_lif]) raises -> None]
    var sprites: List[sdl.Texture]

    var running: Bool
    var world: World

    fn __init__(inout self, ref[sdl_lif]_sdl: sdl.SDL, info: GameInfo = GameInfo()) raises:
        self._sdl = _sdl
        var window = sdl.Window(_sdl, info.game_name, info.window_size.x, info.window_size.y)
        self.renderer = sdl.Renderer(window^)
        self.keyboard = sdl.Keyboard(_sdl)
        self.mouse = sdl.Mouse(_sdl)
        self.screen_mouse = None
        self.world_mouse = None
        self.clock = sdl.Clock(_sdl, 1000)
        self.start_fns = List[fn (inout Game[sdl_lif]) raises -> None]()
        self.update_fns = List[fn (inout Game[sdl_lif]) raises -> None]()
        self.sprites = List[sdl.Texture]()
        self.running = True
        self.world = World()

    @always_inline
    fn __moveinit__(inout self, owned other: Self):
        self._sdl = other._sdl
        self.renderer = other.renderer^
        self.keyboard = sdl.Keyboard(self._sdl[])
        self.mouse = sdl.Mouse(self._sdl[])
        self.screen_mouse = other.screen_mouse
        self.world_mouse = other.world_mouse
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

    fn spawn_camera(inout self) raises -> Entity:
        var entity = self.world.create_entity()
        self.world.position_components.__setitem__(entity.id, PositionComponent(g2.Vector()))
        self.world.rotation_components.__setitem__(entity.id, RotationComponent(g2.Rotor(1)))
        var camera = Camera(entity, g2.Vector(0.5, 0.5), self.renderer)
        self.world.cameras += camera
        return entity

    @always_inline
    fn register_start[func: fn [lif: ImmutableLifetime](inout Game[lif]) raises -> None](owned self) -> Self:
        self.start_fns += func[sdl_lif]
        return self^

    @always_inline
    fn register_update[func: fn [lif: ImmutableLifetime](inout Game[lif]) raises -> None](owned self) -> Self:
        self.update_fns += func[sdl_lif]
        return self^

    @always_inline
    fn spawn[*Ts: AnyType](inout self, owned *components: *Ts) -> Entity:
        var entity = self.world.create_entity()
        @parameter
        fn _add_component[T: AnyType](component: T):
            self.add_component(entity, component)
        components.each[_add_component]()
        return entity

    fn add_components[*Ts: AnyType](inout self, entity: Entity, owned *components: *Ts):
        @parameter
        fn _add_component[T: AnyType](component: T):
            self.add_component(entity, component)
        components.each[_add_component]()

    fn add_component[T: AnyType](inout self, entity: Entity, component: T):
        @parameter
        if _type_is_eq[T, PositionComponent]():
            self.world.position_components.__setitem__(entity.id, utils.any_rebind[PositionComponent](component))
        elif _type_is_eq[T, RotationComponent]():
            self.world.rotation_components.__setitem__(entity.id, utils.any_rebind[RotationComponent](component))
        elif _type_is_eq[T, SpriteComponent]():
            self.world.sprite_components.__setitem__(entity.id, utils.any_rebind[SpriteComponent](component))
        elif _type_is_eq[T, ControlledComponent]():
            self.world.controlled_components.__setitem__(entity.id, utils.any_rebind[ControlledComponent](component))
        elif _type_is_eq[T, SmoothFollowComponent]():
            self.world.smooth_follow_components.__setitem__(entity.id, utils.any_rebind[SmoothFollowComponent](component))
        else:
            abort("unknown component")

    fn run(owned self) raises:
        for start_fn in self.start_fns:
            start_fn[](self)
        
        while self.running:
            self.screen_mouse = g2.Vector(self.mouse.get_position()[0], self.mouse.get_position()[1])
            self.world_mouse = self.world.cameras[0].camera2world(self.world, g2.Vector(self.screen_mouse.x, self.screen_mouse.y))
            for event in self._sdl[].event_list():
                if event[].isa[sdl.events.QuitEvent]():
                    self.running = False
            for update_fn in self.update_fns:
                update_fn[](self)
            for camera in self.world.cameras:
                camera[].draw(self.world, self.renderer)
            self.renderer.present()
            self.clock.tick()