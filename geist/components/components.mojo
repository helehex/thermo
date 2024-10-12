# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #

@value
struct NameComponent:
    var name: String

@value
@register_passable("trivial")
struct PositionComponent:
    var position: g2.Vector

@value
@register_passable("trivial")
struct RotationComponent:
    var rotation: g2.Rotor

@value
@register_passable("trivial")
struct VelocityComponent:
    var velocity: g2.Vector

@value
struct SpriteComponent:
    var sprite: Texture



