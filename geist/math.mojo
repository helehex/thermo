fn lerp[type: DType, size: Int, //](a: SIMD[type, size], b: SIMD[type, size], t: SIMD[type, size]) -> SIMD[type, size]:
    constrained[type.is_floating_point(), "non-float type was passed to lerp"]()
    # return a.fma(1 - t, b * t)
    return t.fma(b - a, a)

fn lerp[type: DType, size: Int, //](a: g2.Vector[type, size], b: g2.Vector[type, size], t: SIMD[type, size]) -> g2.Vector[type, size]:
    constrained[type.is_floating_point(), "non-float type was passed to lerp"]()
    return g2.Vector(lerp(a.x, b.x, t), lerp(a.y, b.y, t))