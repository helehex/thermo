from random import random_float64, seed
from infrared.hard import g2
import mojo_sdl
from thermo import *

alias screen_width = 1600
alias screen_height = 1000


def main():
    var sdl = mojo_sdl.SDL(video=True, timer=True, events=True)
    var window = mojo_sdl.Window(sdl, "Thermo", screen_width, screen_height)
    var keyboard = mojo_sdl.Keyboard(sdl)
    var mouse = mojo_sdl.Mouse(sdl)
    var renderer = mojo_sdl.Renderer(window^, flags = mojo_sdl.RendererFlags.SDL_RENDERER_ACCELERATED)
    var clock = mojo_sdl.Clock(sdl, 1000)
    var running = True

    var field = Field(renderer, g2.Vector(0, 0.1) + 1.0)#g2.Multivector(1.00001, 0, 0, 0.00001))
    seed()

    field += Camera(renderer, g2.Rotor(10, 1), g2.Vector(0, 0), 0.25, 0.25)

    # field.nodes += Node(g2.Vector(100, 100), g2.Vector(), AABB(g2.Vector(-100, -100), g2.Vector(100, 100)))
    # field.nodes += Node(g2.Vector(), g2.Vector(), g2.Vector())
    # field.add_node(Node(g2.Vector(), g2.Vector(), Circle(100)))
    # field.nodes += Node(g2.Vector(), g2.Vector(), Line(g2.Vector(-100, -100), g2.Vector(100, 100)))
    # field.add_node(Node("", g2.Vector(), Primitive(Ray(g2.Vector(0, 0), g2.Vector(0, 100)))))
    field += Body(g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Point(None)), mass=Float64.MAX, iner=Float64.MAX, color=Color(0, 255, 0, 255))
    # field += Body(g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Circle(None, random_float64(20, 80))), mass=Float64.MAX, iner=Float64.MAX, color=sdl.Color(0, 255, 0, 255))
    # field += Body(g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Line(g2.Vector(random_float64(-200, 0), 0.1), g2.Vector(random_float64(0, 200), 0))), mass=1000, color=sdl.Color(0, 255, 0, 255))
    
    field += Body(g2.Vector(-100, 500), Primitive(Line(g2.Vector(-10000, -10000), g2.Vector(10000, 10000))), mass=Float64.MAX, iner=Float64.MAX, color=Color(0, 255, 0, 255))
    field += Body(g2.Vector(800, 1000), Primitive(Line(g2.Vector(-10000, 0), g2.Vector(10000, 1))), mass=Float64.MAX, iner=Float64.MAX, color=Color(0, 255, 0, 255))
    field += Body(g2.Vector(1700, 500), Primitive(Line(g2.Vector(18000, -10000), g2.Vector(-16000, 10000))), mass=Float64.MAX, iner=Float64.MAX, color=Color(0, 255, 0, 255))
    # field += Body(g2.Vector(1700, 500), Primitive(Line(g2.Vector(0, -10000), g2.Vector(0, 10000))), mass=Float64.MAX, iner=Float64.MAX, color=sdl.Color(0, 255, 0, 255))

    alias spd = 10

    # for _ in range(6):
    #     field.add_node(Node("", g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(AABB(g2.Vector(random_float64(-100, -10), random_float64(-100, -10)), g2.Vector(random_float64(10, 100), random_float64(10, 100))))))
    # for _ in range(6):
    #     field.add_node(Node("", g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Circle(None, random_float64(20, 80)))))
    # for _ in range(6):
    #     field.add_node(Node("", g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Line(g2.Vector(random_float64(-200, 200), random_float64(-200, 200)), g2.Vector(random_float64(-200, 200), random_float64(-200, 200))))))
    
    # for _ in range(6):
    #     field.add_body(Body(g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(AABB(g2.Vector(random_float64(-100, -10), random_float64(-100, -10)), g2.Vector(random_float64(10, 100), random_float64(10, 100))))))
    
    # for _ in range(256):
    #     field += Body(g2.Vector(random_float64(100, 1500), random_float64(-1600, 900)), List[Primitive](Primitive(Circle(g2.Vector(random_float64(50, 0), 0), random_float64(20, 60))), Primitive(Circle(g2.Vector(random_float64(-50, 0), 0), random_float64(20, 60)))))
    
    # for _ in range(128):
    #     field.add_body(Body(g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Circle(None, random_float64(20, 80)))))

    # for _ in range(16):
    #     field += Body(g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Line(g2.Vector(random_float64(-200, 0), -100), g2.Vector(random_float64(0, 200), 0))))
    
    # for _ in range(1):
    #     field += Body(g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Line(g2.Vector(random_float64(-200, 0), 100), g2.Vector(random_float64(0, 200), 0))))

    # field.add_node(Node("movable", g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Circle(None, random_float64(20, 80)))))
    # field.add_node(Node("movable", g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(AABB(g2.Vector(random_float64(-100, -10), random_float64(-100, -10)), g2.Vector(random_float64(10, 100), random_float64(10, 100))))))
    # field.add_node(Node("movable", g2.Vector(random_float64(100, 900), random_float64(100, 900)), Primitive(Line(g2.Vector(random_float64(-200, 200), random_float64(-200, 200)), g2.Vector(random_float64(-200, 200), random_float64(-200, 200))))))

    # for _ in range(1):
    #     field.nodes += Node(g2.Vector(random_float64(100, 900), random_float64(100, 900)), g2.Vector(0, 0), Ray(g2.Vector(random_float64(-400, 400), random_float64(-400, 400)), g2.Vector(random_float64(-400, 400), random_float64(-400, 400))))
    var spawn: Bool = False
    
    while running:
        for event in sdl.event_list():
            if event[].isa[mojo_sdl.events.QuitEvent]():
                running = False
            if event[].isa[mojo_sdl.events.MouseButtonEvent]():
                if event[].unsafe_get[mojo_sdl.events.MouseButtonEvent]()[].clicks == 1 and event[].unsafe_get[mojo_sdl.events.MouseButtonEvent]()[].state == 1:
                    spawn = True
                elif event[].unsafe_get[mojo_sdl.events.MouseButtonEvent]()[].state == 0:
                    spawn = False
                    
        clock.tick()

        var screen_cursor = mouse.get_position()
        var world_cursor = field._cameras[0].cam2field(g2.Vector(screen_cursor[0], screen_cursor[1]))

        # field._bodies[0].vel = (world_cursor - field._bodies[0].pos.v) + 1
        field._bodies[0].pos.v = world_cursor

        if spawn == True:
            # field += Body(world_cursor, List[Primitive](Primitive(Circle(g2.Vector(random_float64(50, 0), 0), random_float64(20, 60))), Primitive(Circle(g2.Vector(random_float64(-50, 0), 0), random_float64(20, 60)))))
            field += Body(world_cursor, List[Primitive](Primitive(Line(g2.Vector(-100, -100), g2.Vector(100, -100))), Primitive(Line(g2.Vector(100, -100), g2.Vector(100, 100))), Primitive(Line(g2.Vector(100, 100), g2.Vector(-100, 100))), Primitive(Line(g2.Vector(-100, 100), g2.Vector(-100, -100)))))
            spawn = False

        # field._nodes[0].prims[0]._data.unsafe_get[Ray]()[].dir = world_cursor
        field.simulate()
        field._bodies[0].pos.v = world_cursor
        field.update(clock.delta_time, keyboard)
        field.draw(renderer)
        renderer.present()