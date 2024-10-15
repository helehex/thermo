from geist import *
from infrared import hard
from pathlib import _dir_of_current_file


alias TestConfig = Config(
    game_name = "Geist Test",
    window_size = g2.Vector[DType.int32](800, 600),
    target_fps = 10000
)


fn main() raises:
    (
        Game(sdl.SDL(video=True, timer=True, events=True, gfx=True, img=True), TestConfig)
        .register_start[test_start]()
        .register_update[test_update]()
        .register_update[game.controlled_system]()
        .register_update[game.smooth_follow_system]()
        .register_sprite(_dir_of_current_file() / "assets/sprites/crate.png")
        .run()
    )


fn test_start(inout game: Game) raises:
    var character = game.spawn(SpriteComponent(game.sprites[0]), PositionComponent(None), RotationComponent(1.0), ControlledComponent())
    var camera = game.spawn_camera()
    game.add_components(camera, SmoothFollowComponent(5, character), ControlledComponent.arrow_controls)
    

fn test_update(inout game: Game) raises:
    if game.mouse.get_buttons() == 1:
        _ = game.spawn(SpriteComponent(game.sprites[0]), PositionComponent(game.world_mouse), RotationComponent(infrared.hard.g2.Rotor(1)))