# x--------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #


@value
struct Collision:
    var still_near: Bool
    var b1: UnsafePointer[Body]
    var b2: UnsafePointer[Body]
    var contacts: List[Contact]
    var elas: Float64
    var fric: Float64

    fn __init__(inout self, b1: UnsafePointer[Body], b2: UnsafePointer[Body]):
        self.still_near = True
        self.b1 = b1
        self.b2 = b2
        self.elas = (b1[].elas + b2[].elas) / 2
        self.fric = (b1[].fric + b2[].fric) / 2
        var num_contacts = len(b1[].prims) * len(b2[].prims)
        self.contacts = List[Contact](capacity = num_contacts)
        for _ in range(num_contacts):
            self.contacts += Contact()

    fn detect(inout self):
        self.still_near = False

        var contact_id = 0
        for prim1 in self.b1[].prims:
            for prim2 in self.b2[].prims:
                    var prepulse = self.contacts[contact_id].prepulse
                    self.contacts[contact_id] = self.detect_contact(prim1[].body2field(self.b1[]), prim2[].body2field(self.b2[]))
                    self.contacts[contact_id].prepulse = prepulse
                    contact_id += 1

        for contact in self.contacts:
            if contact[].penetration > slop:
                contact[].start()

    fn solve(inout self):
        for idx in range(len(self.contacts)):
            if self.contacts[idx].penetration > slop:
                self.contacts[idx].solve()

    fn detect_contact(self, prim1: Primitive, prim2: Primitive) -> Contact:
        if prim1._data.isa[Circle]():
            return self.detect_contact(prim1._data.unsafe_get[Circle]()[], prim2)
        if prim1._data.isa[Point]():
            return self.detect_contact(prim1._data.unsafe_get[Point]()[], prim2)
        if prim1._data.isa[Line]():
            return self.detect_contact(prim1._data.unsafe_get[Line]()[], prim2)
        return Contact()

    fn detect_contact(self, prim1: Circle, prim2: Primitive) -> Contact:
        if prim2._data.isa[Circle]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Circle]()[])
        elif prim2._data.isa[Point]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Point]()[])
        elif prim2._data.isa[Line]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Line]()[])
        return Contact()
        
    fn detect_contact(self, prim1: Circle, prim2: Circle) -> Contact:
        var rel = prim1.pos - prim2.pos
        var rad_sum = prim1.radius + prim2.radius
        var dis_sqr = rel.inn()
        if dis_sqr < rad_sum * rad_sum:
            var distance = sqrt(dis_sqr)
            var normal = rel / distance
            return Contact(self, prim2.pos + (normal * prim2.radius), normal, rad_sum - distance)
        return Contact()

    fn detect_contact(self, prim1: Circle, prim2: Point) -> Contact:
        var rel = prim1.pos - prim2.pos
        var rad_sum = prim1.radius
        var dis_sqr = rel.inn()
        if dis_sqr < rad_sum * rad_sum:
            var distance = sqrt(dis_sqr)
            var normal = rel / distance
            return Contact(self, prim2.pos, normal, rad_sum - distance)
        return Contact()

    fn detect_contact(self, prim1: Circle, prim2: Line) -> Contact:
        if prim2.beg == prim2.end:
            return self.detect_contact(prim1, prim2.beg)

        var rel = prim2.beg - prim1.pos
        var lin_rel = prim2.end - prim2.beg
        var lin_nom = sqrt(lin_rel.inn())
        var normal = (lin_rel / lin_nom).nrm()
        var inr = rel.inner(normal)

        if -prim1.radius < inr < prim1.radius:
            var otr = rel.outer(normal)

            if otr < 0:
                return self.detect_contact(prim1, prim2.beg)
            elif otr > lin_nom:
                return self.detect_contact(prim1, prim2.end)
            elif inr > 0:
                return Contact(self, prim1.pos + (normal * prim1.radius), -normal, prim1.radius - inr)
            else:
                return Contact(self, prim1.pos - (normal * prim1.radius), normal, prim1.radius + inr)
        return Contact()

    fn detect_contact(self, prim1: Point, prim2: Primitive) -> Contact:
        if prim2._data.isa[Circle]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Circle]()[])
        elif prim2._data.isa[Point]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Point]()[])
        elif prim2._data.isa[Line]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Line]()[])
        return Contact()

    fn detect_contact(self, prim1: Point, prim2: Circle) -> Contact:
        var rel = prim1.pos - prim2.pos
        var rad_sum = prim2.radius
        var dis_sqr = rel.inn()
        if 0.0 < dis_sqr < rad_sum * rad_sum:
            var distance = sqrt(dis_sqr)
            var normal = rel / distance
            return Contact(self, prim1.pos, normal, rad_sum - distance)
        return Contact()

    fn detect_contact(self, prim1: Point, prim2: Point) -> Contact:
        return Contact()

    fn detect_contact(self, prim1: Point, prim2: Line) -> Contact:
        return Contact()

    fn detect_contact(self, prim1: Line, prim2: Primitive) -> Contact:
        if prim2._data.isa[Circle]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Circle]()[])
        elif prim2._data.isa[Point]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Point]()[])
        elif prim2._data.isa[Line]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Line]()[])
        return Contact()

    fn detect_contact(self, prim1: Line, prim2: Circle) -> Contact:
        if prim1.beg == prim1.end:
            return self.detect_contact(prim1.beg, prim2)

        var rel = prim1.beg - prim2.pos
        var lin_rel = prim1.end - prim1.beg
        var lin_nom = sqrt(lin_rel.inn())
        var normal = (lin_rel / lin_nom).nrm()
        var inr = rel.inner(normal)

        if -prim2.radius < inr < prim2.radius:
            var otr = rel.outer(normal)

            if otr < 0:
                return self.detect_contact(prim1.beg, prim2)
            elif otr > lin_nom:
                return self.detect_contact(prim1.end, prim2)
            elif inr > 0:
                return Contact(self, prim2.pos + (normal * prim2.radius), normal, prim2.radius - inr)
            else:
                return Contact(self, prim2.pos - (normal * prim2.radius), -normal, prim2.radius + inr)
        return Contact()

    fn detect_contact(self, prim1: Line, prim2: Point) -> Contact:
        return Contact()

    fn detect_contact(self, prim1: Line, prim2: Line) -> Contact:
        var rp: g2.Vector[]
        var a_normal = prim1.normal()
        var b_normal = prim2.normal()
        var a_inr_b1 = (prim2.beg - prim1.beg).inner(a_normal)
        var a_inr_b2 = (prim2.end - prim1.beg).inner(a_normal)
        var a1_inr_b = (prim1.beg - prim2.beg).inner(b_normal)
        var a2_inr_b = (prim1.end - prim2.beg).inner(b_normal)

        var a_crossing = (a_inr_b1 > slop) != (a_inr_b2 > slop)
        var b_crossing = (a1_inr_b > slop) != (a2_inr_b > slop)

        if a_crossing and b_crossing:
            rp = prim1.end - prim1.beg
            var position = prim2.end - prim2.beg
            position = prim1.beg + (rp * ((prim2.beg - prim1.beg).outer(position) / rp.outer(position)))

            var normal: g2.Vector = None
            var penetration: Float64 = 0

            if abs(a_inr_b1) < abs(a_inr_b2) and abs(a_inr_b1) < abs(a1_inr_b) and abs(a_inr_b1) < abs(a2_inr_b):
                normal = a_normal if a_inr_b1 > 0 else -a_normal
                penetration = abs(a_inr_b1)
            elif abs(a_inr_b2) < abs(a_inr_b1) and abs(a_inr_b2) < abs(a1_inr_b) and abs(a_inr_b2) < abs(a2_inr_b):
                normal = a_normal if a_inr_b2 > 0 else -a_normal
                penetration = abs(a_inr_b2)
            elif abs(a1_inr_b) < abs(a_inr_b1) and abs(a1_inr_b) < abs(a_inr_b2) and abs(a1_inr_b) < abs(a2_inr_b):
                normal = -b_normal if a1_inr_b > 0 else b_normal
                penetration = abs(a1_inr_b)
            else:
                normal = -b_normal if a2_inr_b > 0 else b_normal
                penetration = abs(a2_inr_b)

            return Contact(self, position, normal, penetration)
        return Contact()
