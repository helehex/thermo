@value
@register_passable("trivial")
struct ControlledComponent:
    var speed: Float64


fn controlled_system(inout game: Game):
    for idx in range(len(game.world.controlled_components._data)):
        # rotation
        var angle = 0
        alias rot_speed = 0.5

        if game.keyboard.state[KeyCode.Q]:
            angle -= 1
        if game.keyboard.state[KeyCode.E]:
            angle += 1

        # zoom
        var zoom = 0

        if game.keyboard.state[KeyCode.LSHIFT]:
            zoom -= 1
        if game.keyboard.state[KeyCode.SPACE]:
            zoom += 1

        var rot = g2.Rotor(
            angle=angle * game.clock.delta_time * rot_speed
        ) * (1 + (zoom * game.clock.delta_time))

        # position
        var mov = g2.Vector()
        var mov_speed = game.world.controlled_components[idx].unsafe_value()[].speed

        if game.keyboard.state[KeyCode.A]:
            mov.x -= 1
        if game.keyboard.state[KeyCode.D]:
            mov.x += 1
        if game.keyboard.state[KeyCode.W]:
            mov.y -= 1
        if game.keyboard.state[KeyCode.S]:
            mov.y += 1

        var entity_id = game.world.controlled_components._idx2lbl[idx]

        if not mov.is_zero():
            mov = (mov / mov.nom()) * game.world.rotation_components[entity_id].unsafe_value()[].rotation * game.clock.delta_time * mov_speed

        var new_transform = (game.world.position_components[entity_id].unsafe_value()[].position + game.world.rotation_components[entity_id].unsafe_value()[].rotation).trans(mov + rot)
        game.world.position_components[entity_id].unsafe_value()[] = new_transform.vector()
        game.world.rotation_components[entity_id].unsafe_value()[] = new_transform.rotor()
        