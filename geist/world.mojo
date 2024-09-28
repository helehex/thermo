from .label_map import LabelMap
from .camera import Camera
from .controlled import ControlledComponent

@value
struct World:
    var cameras: List[Camera]
    var entities: List[Entity]
    var position_components: LabelMap[PositionComponent]
    var rotation_components: LabelMap[RotationComponent]
    var sprite_components: LabelMap[SpriteComponent]
    var controlled_components: LabelMap[ControlledComponent]

    fn __init__(inout self):
        self.cameras = List[Camera]()
        self.entities = List[Entity]()
        self.position_components = LabelMap[PositionComponent]()
        self.rotation_components = LabelMap[RotationComponent]()
        self.sprite_components = LabelMap[SpriteComponent]()
        self.controlled_components = LabelMap[ControlledComponent]()

    fn create_entity(inout self) -> Entity:
        var entity = Entity(len(self.entities))
        self.entities += entity
        return entity
