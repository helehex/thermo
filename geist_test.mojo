from geist import *
from pathlib import _dir_of_current_file


fn main() raises:
    (
        Game(sdl.SDL(video=True, timer=True, events=True, gfx=True, img=True), GameInfo("Geist Test"))
        .register_start[test_start]()
        .register_update[test_update]()
        .register_sprite(_dir_of_current_file() / "assets/sprites/crate.png")
        .create_camera(ControlledComponent.arrow_controls)
        .run()
    )


fn test_start(inout game: Game):
    game.create_sprite(None, 1.0, 0, ControlledComponent())


fn test_update(inout game: Game):
    var screen_mouse = infrared.hard.g2.Vector(game.mouse.get_position()[0], game.mouse.get_position()[1])
    var world_mouse = game.world.cameras[0].camera2world(game.world, infrared.hard.g2.Vector(screen_mouse.x, screen_mouse.y))
    if game.mouse.get_buttons() == 1:
        game.create_sprite(world_mouse, infrared.hard.g2.Rotor(1), 0)