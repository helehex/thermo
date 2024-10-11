from geist import *
from infrared import hard
from pathlib import _dir_of_current_file


alias TestGameInfo = GameInfo(
    "Geist Test",
    g2.Vector[DType.int32](800, 600),
)


fn main() raises:
    (
        Game(sdl.SDL(video=True, timer=True, events=True, gfx=True, img=True), TestGameInfo)
        .register_start[test_start]()
        .register_update[test_update]()
        .register_update[game.controlled_system]()
        .register_update[game.smooth_follow_system]()
        .register_sprite(_dir_of_current_file() / "assets/sprites/crate.png")
        .run()
    )


fn test_start(inout game: Game) raises:
    var camera = game.spawn_camera(ControlledComponent.arrow_controls)
    var character = game.spawn_sprite(0, None, 1.0, ControlledComponent())
    game.add_smooth_follow_component(camera, SmoothFollowComponent(5, character))
    

fn test_update(inout game: Game) raises:
    if game.mouse.get_buttons() == 1:
        _ = game.spawn_sprite(0, game.world_mouse, infrared.hard.g2.Rotor(1))