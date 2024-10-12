# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #


@value
@register_passable("trivial")
struct ControlledComponent:
    var speed: Float64
    var forward: KeyCode
    var backward: KeyCode
    var left: KeyCode
    var right: KeyCode
    var clockwise: KeyCode
    var counterclockwise: KeyCode
    var zoomin: KeyCode
    var zoomout: KeyCode

    alias arrow_controls = Self(
        1000,
        KeyCode(KeyCode.UP),
        KeyCode(KeyCode.DOWN),
        KeyCode(KeyCode.LEFT),
        KeyCode(KeyCode.RIGHT),
        KeyCode(KeyCode.RIGHTBRACKET),
        KeyCode(KeyCode.LEFTBRACKET),
        KeyCode(KeyCode.EQUALS),
        KeyCode(KeyCode.MINUS),
    )

    fn __init__(inout self):
        self.speed = 1000
        self.forward = KeyCode.W
        self.backward = KeyCode.S
        self.left = KeyCode.A
        self.right = KeyCode.D
        self.clockwise = KeyCode.E
        self.counterclockwise = KeyCode.Q
        self.zoomin = KeyCode.SPACE
        self.zoomout = KeyCode.LSHIFT


fn controlled_system(inout game: Game) raises:
    for idx in range(len(game.world.controlled_components._data)):
        var controlled = game.world.controlled_components[idx].unsafe_value()[]

        # rotation
        var angle = 0
        alias rot_speed = 0.5

        if game.keyboard.get_key(controlled.counterclockwise):
            angle -= 1
        if game.keyboard.get_key(controlled.clockwise):
            angle += 1

        # zoom
        var zoom = 0

        if game.keyboard.get_key(controlled.zoomin):
            zoom -= 1
        if game.keyboard.get_key(controlled.zoomout):
            zoom += 1

        var rot = g2.Rotor(
            angle=angle * game.clock.delta_time * rot_speed
        ) * (1 + (zoom * game.clock.delta_time))

        # position
        var mov = g2.Vector()
        var mov_speed = controlled.speed

        if game.keyboard.get_key(controlled.left):
            mov.x -= 1
        if game.keyboard.get_key(controlled.right):
            mov.x += 1
        if game.keyboard.get_key(controlled.forward):
            mov.y -= 1
        if game.keyboard.get_key(controlled.backward):
            mov.y += 1

        var entity_id = game.world.controlled_components._idx2lbl[idx]

        if not mov.is_zero():
            mov = (mov / mov.nom()) * game.world.rotation_components[entity_id].unsafe_value()[].rotation * game.clock.delta_time * mov_speed

        var new_transform = (game.world.position_components[entity_id].unsafe_value()[].position + game.world.rotation_components[entity_id].unsafe_value()[].rotation).trans(mov + rot)
        game.world.position_components[entity_id].unsafe_value()[] = new_transform.vector()
        game.world.rotation_components[entity_id].unsafe_value()[] = new_transform.rotor()
        