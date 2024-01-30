module default {

    # ========== scalar types ========== 
    # --8<-- [start:scalar_type_SceneNumber]
    scalar type SceneNumber extending sequence;
    # --8<-- [end:scalar_type_SceneNumber]

    # ========== abstract object types ========== 
    # --8<-- [start:abstract_object_type_Event]
    abstract type Event {
        detail: str;
        multi who: Character;
        multi `when`: FuzzyTime;
        multi where: Place;
    }
    # --8<-- [end:abstract_object_type_Event]

    # ========== object types ========== 
    # --8<-- [start:object_type_Scene]
    type Scene extending Event {
        title: str;
        remarks: str;
        references: array<tuple<str, str>>;
        required scene_number: SceneNumber {
            constraint exclusive;
            default := sequence_next(introspect SceneNumber);
        }
        index on (.scene_number);
    }
    # --8<-- [end:object_type_Scene]

}
