# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #


@value
struct Camera:
    var transform: g2.Multivector
    var pivot: g2.Vector
    var target: Texture
    var frame_count: Int
    var viewport: DRect[DType.float32]
    var is_main_camera: Bool

    fn __init__(
        inout self, renderer: Renderer, transform: g2.Multivector[], pivot: g2.Vector[], viewport: DRect) raises:
        self.transform = transform
        self.pivot = pivot
        var size = renderer.get_output_size()
        self.target = Texture(renderer, sdl.TexturePixelFormat.RGBA8888, sdl.TextureAccess.TARGET, int(size[0] * viewport.w), int(size[1] * viewport.h))
        self.frame_count = 0
        self.viewport = viewport.cast[DType.float32]()
        self.is_main_camera = False

    fn __eq__(self, other: Self) -> Bool:
        return Reference(self) == Reference(other)

    fn __ne__(self, other: Self) -> Bool:
        return Reference(self) != Reference(other)

    fn cam2field(self, pos: g2.Vector[]) -> g2.Vector[]:
        return ((pos - self.pivot) * self.transform.rotor()) + (self.transform.v)

    fn field2cam(self, pos: g2.Vector[]) -> g2.Vector[]:
        return ((pos - (self.transform.v)) / self.transform.rotor()) + self.pivot

    # +------( Update )------+ #
    #
    fn update(inout self, delta_time: Float64, keyboard: Keyboard):

        if not self.is_main_camera:
            return

        # rotation
        var angle = 0
        alias rot_speed = 0.5

        if keyboard.state[KeyCode.Q]:
            angle -= 1
        if keyboard.state[KeyCode.E]:
            angle += 1

        # zoom
        var zoom = 0

        if keyboard.state[KeyCode.LSHIFT]:
            zoom -= 1
        if keyboard.state[KeyCode.SPACE]:
            zoom += 1

        var rot = g2.Rotor(
            angle=angle * delta_time * rot_speed
        ) * (1 + (zoom * delta_time))

        # position
        var mov = g2.Vector()
        alias mov_speed = 1000

        if keyboard.state[KeyCode.A]:
            mov.x -= 1
        if keyboard.state[KeyCode.D]:
            mov.x += 1
        if keyboard.state[KeyCode.W]:
            mov.y -= 1
        if keyboard.state[KeyCode.S]:
            mov.y += 1

        if not mov.is_zero():
            mov = (mov / mov.nom()) * self.transform.rotor() * delta_time * mov_speed

        self.transform = self.transform.trans(mov + rot)

    # +------( Draw )------+ #
    #
    fn draw(self, field: Field, renderer: Renderer) raises:
        renderer.set_target(self.target)
        renderer.set_color(thermo.field.background_clear)
        renderer.clear()

        # if self.frame_count == 50:
        #     renderer.clear()
        #     self.frame_count = 0
        # self.frame_count += 1

        for node in field._nodes:
            node[].draw(self, renderer)

        for body in field._bodies:
            body[][].draw(self, renderer)

        renderer.reset_target()
        var size = renderer.get_output_size()
        renderer.set_viewport(DRect[DType.int32](self.viewport.x * size[0], self.viewport.y * size[1], self.viewport.w * size[0], self.viewport.h * size[1]))
        renderer.copy(self.target, None)
