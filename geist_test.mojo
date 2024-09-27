from geist import *
from pathlib import _dir_of_current_file

fn main() raises:
    Game(sdl.SDL(video=True, timer=True, events=True, gfx=True, img=True)).register_update[test_update]().add_sprite(_dir_of_current_file() / "assets/sprites/crate.png").create_camera(ControlledComponent(1000)).run()

fn test_update(inout game: Game):
    var world_mouse = game.world.cameras[0].camera2world(game.world, infrared.hard.g2.Vector(game.mouse.get_position()[0], game.mouse.get_position()[1]))
    if game.mouse.get_buttons() == 1:
        game.create_sprite(world_mouse, infrared.hard.g2.Rotor(1), 0)
    if game.mouse.get_buttons() == 4:
        game.create_sprite(world_mouse, infrared.hard.g2.Rotor(1), 0, ControlledComponent(100))
