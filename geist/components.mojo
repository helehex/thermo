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
@register_passable("trivial")
struct SpriteComponent:
    var sprite: UnsafePointer[Texture]

@value
@register_passable("trivial")
struct SmoothFollowComponent:
    var speed: Float64
    var target: Entity


from geist.math import lerp

fn smooth_follow_system(inout game: Game) raises:
    for idx in range(len(game.world.smooth_follow_components._data)):
        var smooth_follow = game.world.smooth_follow_components[idx].unsafe_value()
        var current_pos = game.world.position_components[game.world.smooth_follow_components._idx2lbl[idx]]
        var target_pos = game.world.position_components[smooth_follow[].target.id]

        if current_pos and target_pos:
            current_pos.unsafe_value()[] = lerp(target_pos.unsafe_value()[].position, current_pos.unsafe_value()[].position, 0.5**(game.clock.delta_time * smooth_follow[].speed))

