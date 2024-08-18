alias slop = -0.001

@value
struct Collision:
    var still_near: Bool
    var b1: UnsafePointer[Body]
    var b2: UnsafePointer[Body]
    var contacts: List[Contact]
    var elas: Float64
    var fric: Float64

    fn __init__(inout self, b1: Body, b2: Body):
        self.still_near = True
        self.b1 = UnsafePointer[Body].address_of(b1)
        self.b2 = UnsafePointer[Body].address_of(b2)
        self.elas = (b1.elas + b2.elas) / 2
        self.fric = (b1.fric + b2.fric) / 2
        self.contacts = List[Contact](capacity = len(self.b1[].prims) * len(self.b2[].prims))

    fn blank_contacts(inout self):
        for _ in range(len(self.b1[].prims) * len(self.b2[].prims)):
            self.contacts += Contact(self)

    fn detect(inout self):
        self.still_near = False

        var contact_id = 0
        for prim1 in self.b1[].prims:
            for prim2 in self.b2[].prims:
                    if not self.detect_contact(prim1[].body2field(self.b1[]), prim2[].body2field(self.b2[]), self.contacts[contact_id]):
                        self.contacts[contact_id].penetration = slop
                    contact_id += 1

        for contact in self.contacts:
            if contact[].penetration > slop:
                contact[].start()

    fn solve(inout self):
        for contact in self.contacts:
            if contact[].penetration > slop:
                contact[].solve()

    fn detect_contact(self, prim1: Primitive, prim2: Primitive, inout contact: Contact) -> Bool:
        if prim1._data.isa[Circle]():
            return self.detect_contact(prim1._data.unsafe_get[Circle]()[], prim2, contact)
        if prim1._data.isa[Point]():
            return self.detect_contact(prim1._data.unsafe_get[Point]()[], prim2, contact)
        if prim1._data.isa[Line]():
            return self.detect_contact(prim1._data.unsafe_get[Line]()[], prim2, contact)
        return False

    fn detect_contact(self, prim1: Circle, prim2: Primitive, inout contact: Contact) -> Bool:
        if prim2._data.isa[Circle]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Circle]()[], contact)
        elif prim2._data.isa[Point]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Point]()[], contact)
        elif prim2._data.isa[Line]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Line]()[], contact)
        return False
        
    fn detect_contact(self, prim1: Circle, prim2: Circle, inout contact: Contact) -> Bool:
        var rel = prim1.pos - prim2.pos
        var rad_sum = prim1.radius + prim2.radius
        var dis_sqr = rel.inn()
        if dis_sqr < rad_sum * rad_sum:
            var distance = sqrt(dis_sqr)
            var normal = rel / distance
            contact.set(prim2.pos + (normal * prim2.radius), normal, rad_sum - distance)
            return True
        return False

    fn detect_contact(self, prim1: Circle, prim2: Point, inout contact: Contact) -> Bool:
        var rel = prim1.pos - prim2.pos
        var rad_sum = prim1.radius
        var dis_sqr = rel.inn()
        if dis_sqr < rad_sum * rad_sum:
            var distance = sqrt(dis_sqr)
            var normal = rel / distance
            contact.set(prim2.pos, normal, rad_sum - distance)
            return True
        return False

    fn detect_contact(self, prim1: Circle, prim2: Line, inout contact: Contact) -> Bool:
        if prim2.beg == prim2.end:
            return self.detect_contact(prim1, prim2.beg, contact)

        var rel = prim2.beg - prim1.pos
        var lin_rel = prim2.end - prim2.beg
        var lin_nom = sqrt(lin_rel.inn())
        var normal = (lin_rel / lin_nom).nrm()
        var inr = rel.inner(normal)

        if -prim1.radius < inr < prim1.radius:
            var otr = rel.outer(normal)

            if otr < 0:
                return self.detect_contact(prim1, prim2.beg, contact)
            elif otr > lin_nom:
                return self.detect_contact(prim1, prim2.end, contact)
            elif inr > 0:
                contact.set(prim1.pos + (normal * prim1.radius), -normal, prim1.radius - inr)
            else:
                contact.set(prim1.pos - (normal * prim1.radius), normal, prim1.radius + inr)
            return True
        return False

    fn detect_contact(self, prim1: Point, prim2: Primitive, inout contact: Contact) -> Bool:
        if prim2._data.isa[Circle]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Circle]()[], contact)
        elif prim2._data.isa[Point]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Point]()[], contact)
        elif prim2._data.isa[Line]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Line]()[], contact)
        return False

    fn detect_contact(self, prim1: Point, prim2: Circle, inout contact: Contact) -> Bool:
        var rel = prim1.pos - prim2.pos
        var rad_sum = prim2.radius
        var dis_sqr = rel.inn()
        if dis_sqr < rad_sum * rad_sum:
            var distance = sqrt(dis_sqr)
            var normal = rel / distance
            contact.set(prim1.pos, normal, rad_sum - distance)
            return True
        return False

    fn detect_contact(self, prim1: Point, prim2: Point, inout contact: Contact) -> Bool:
        return False

    fn detect_contact(self, prim1: Point, prim2: Line, inout contact: Contact) -> Bool:
        return False

    fn detect_contact(self, prim1: Line, prim2: Primitive, inout contact: Contact) -> Bool:
        if prim2._data.isa[Circle]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Circle]()[], contact)
        elif prim2._data.isa[Point]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Point]()[], contact)
        elif prim2._data.isa[Line]():
            return self.detect_contact(prim1, prim2._data.unsafe_get[Line]()[], contact)
        return False

    fn detect_contact(self, prim1: Line, prim2: Circle, inout contact: Contact) -> Bool:
        if prim1.beg == prim1.end:
            return self.detect_contact(prim1.beg, prim2, contact)

        var rel = prim1.beg - prim2.pos
        var lin_rel = prim1.end - prim1.beg
        var lin_nom = sqrt(lin_rel.inn())
        var normal = (lin_rel / lin_nom).nrm()
        var inr = rel.inner(normal)

        if -prim2.radius < inr < prim2.radius:
            var otr = rel.outer(normal)

            if otr < 0:
                return self.detect_contact(prim1.beg, prim2, contact)
            elif otr > lin_nom:
                return self.detect_contact(prim1.end, prim2, contact)
            elif inr > 0:
                contact.set(prim2.pos + (normal * prim2.radius), normal, prim2.radius - inr)
            else:
                contact.set(prim2.pos - (normal * prim2.radius), -normal, prim2.radius + inr)
            return True
        return False

    fn detect_contact(self, prim1: Line, prim2: Point, inout contact: Contact) -> Bool:
        return False

    fn detect_contact(self, prim1: Line, prim2: Line, inout contact: Contact) -> Bool:
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

            contact.set(position, normal, penetration)
            return True
        return False
