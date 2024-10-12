# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #

from .label_map import LabelMap
from .camera import Camera


@value
struct World[*element_types: CollectionElement]:
    var cameras: List[Camera]
    var entities: List[Entity]
    var position_components: LabelMap[PositionComponent]
    var rotation_components: LabelMap[RotationComponent]
    var sprite_components: LabelMap[SpriteComponent]
    var controlled_components: LabelMap[ControlledComponent]
    var smooth_follow_components: LabelMap[SmoothFollowComponent]

    fn __init__(inout self):
        self.cameras = List[Camera]()
        self.entities = List[Entity]()
        self.position_components = LabelMap[PositionComponent]()
        self.rotation_components = LabelMap[RotationComponent]()
        self.sprite_components = LabelMap[SpriteComponent]()
        self.controlled_components = LabelMap[ControlledComponent]()
        self.smooth_follow_components = LabelMap[SmoothFollowComponent]()

    fn create_entity(inout self) -> Entity:
        var entity = Entity(len(self.entities))
        self.entities += entity
        return entity
