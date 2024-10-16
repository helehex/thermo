from random import random_float64, seed
from infrared.hard import g2
from sdl import *
from thermo import *

alias screen_width = 1600
alias screen_height = 1000


def main():
    var sdl = SDL(video=True, timer=True, events=True, gfx=True)
    var window = Window(sdl, "Thermo", screen_width, screen_height)
    var keyboard = Keyboard(sdl)
    var mouse = Mouse(sdl)
    var renderer = Renderer(window^, flags = RendererFlags.SDL_RENDERER_ACCELERATED)
    var clock = Clock(sdl, 1000)
    var running = True

    var field = Field(renderer, g2.Vector(0, 0.1) + 1.0) #g2.Multivector(1.00001, 0, 0, 0.00001))
    seed()

    field += Camera(renderer, g2.Rotor(10, 1), g2.Vector(0, 0), DRect[DType.float32](0.4, 0.0, 0.2, 0.2))
    field += Body(g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(thermo.Point(None)), mass=Float64.MAX, iner=Float64.MAX, color=Color(0, 255, 0, 255))
    # field += Body(g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Circle(None, random_float64(20, 80))), mass=Float64.MAX, iner=Float64.MAX, color=sdl.Color(0, 255, 0, 255))
    # field += Body(g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Line(g2.Vector(random_float64(-200, 0), 0.1), g2.Vector(random_float64(0, 200), 0))), mass=1000, color=sdl.Color(0, 255, 0, 255))
    
    field += Body(g2.Vector(-100, 500), Primitive(Line(g2.Vector(-10000, -10000), g2.Vector(10000, 10000))), mass=Float64.MAX, iner=Float64.MAX, color=Color(0, 255, 0, 255))
    field += Body(g2.Vector(800, 1000), Primitive(Line(g2.Vector(-10000, 0), g2.Vector(10000, 1))), mass=Float64.MAX, iner=Float64.MAX, color=Color(0, 255, 0, 255))
    field += Body(g2.Vector(1700, 500), Primitive(Line(g2.Vector(18000, -10000), g2.Vector(-16000, 10000))), mass=Float64.MAX, iner=Float64.MAX, color=Color(0, 255, 0, 255))
    # field += Body(g2.Vector(1700, 500), Primitive(Line(g2.Vector(0, -10000), g2.Vector(0, 10000))), mass=Float64.MAX, iner=Float64.MAX, color=sdl.Color(0, 255, 0, 255))

    # for _ in range(256):
    #     field += Body(g2.Vector(random_float64(100, 1500), random_float64(-1600, 900)), List[Primitive](Primitive(Circle(g2.Vector(random_float64(50, 0), 0), random_float64(20, 60))), Primitive(Circle(g2.Vector(random_float64(-50, 0), 0), random_float64(20, 60)))))
    
    # for _ in range(16):
    #     field += Body(g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Line(g2.Vector(random_float64(-200, 0), -100), g2.Vector(random_float64(0, 200), 0))))
    
    # for _ in range(1):
    #     field += Body(g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Line(g2.Vector(random_float64(-200, 0), 100), g2.Vector(random_float64(0, 200), 0))))

    var spawn: Bool = False
    var spawn_continuous: Bool = False
    
    while running:
        for event in sdl.event_list():
            if event[].isa[events.QuitEvent]():
                running = False
            if event[].isa[events.MouseButtonEvent]():
                var mouse_button_event = event[].unsafe_get[events.MouseButtonEvent]()
                if mouse_button_event[].button == 1:
                    if mouse_button_event[].state == 1:
                        spawn = True
                else:
                    if mouse_button_event[].state == 1:
                        spawn_continuous = True
                    else:
                        spawn_continuous = False
                    
        clock.tick()

        var screen_cursor = mouse.get_position()
        var world_cursor = field._cameras[0].cam2field(g2.Vector(screen_cursor[0], screen_cursor[1]))

        field._bodies[0][].vel.v = (world_cursor - field._bodies[0][].pos.v) * 0.25
        field._bodies[0][].pos.v = world_cursor

        if spawn or spawn_continuous:
            field += Body(world_cursor, List[Primitive](
                Primitive(Line(g2.Vector(-100, -100), g2.Vector(100, -100))), 
                Primitive(Line(g2.Vector(100, -100), g2.Vector(100, 100))), 
                Primitive(Line(g2.Vector(100, 100), g2.Vector(-100, 100))), 
                Primitive(Line(g2.Vector(-100, 100), g2.Vector(-100, -100))),
                Primitive(Circle(None, 99))
                ))
            spawn = False

        # field._nodes[0].prims[0]._data.unsafe_get[Ray]()[].dir = world_cursor

        field.step()
        field._bodies[0][].pos.v = world_cursor
        field.update(clock.delta_time, keyboard)
        field.draw(renderer)
        renderer.present()
