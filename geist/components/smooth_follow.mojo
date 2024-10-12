# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #

from geist.math import lerp

@value
@register_passable("trivial")
struct SmoothFollowComponent:
    var speed: Float64
    var target: Entity

fn smooth_follow_system(inout game: Game) raises:
    for idx in range(len(game.world.smooth_follow_components._data)):
        var smooth_follow = game.world.smooth_follow_components[idx].unsafe_value()
        var current_pos = game.world.position_components[game.world.smooth_follow_components._idx2lbl[idx]]
        var target_pos = game.world.position_components[smooth_follow[].target.id]

        if current_pos and target_pos:
            current_pos.unsafe_value()[] = lerp(target_pos.unsafe_value()[].position, current_pos.unsafe_value()[].position, 0.5**(game.clock.delta_time * smooth_follow[].speed))