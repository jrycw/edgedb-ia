module default {

    # ========== abstract object types ==========
    # --8<-- [start:abstract_object_type_Place]
    abstract type Place {
        required name: str {
            delegated constraint exclusive;
        };
    }
    # --8<-- [end:abstract_object_type_Place]

    # ========== object types ==========
    # --8<-- [start:object_type_Landmark]
    type Landmark extending Place;
    # --8<-- [end:object_type_Landmark]

    # --8<-- [start:object_type_Location]
    type Location extending Place;
    # --8<-- [end:object_type_Location]

    # --8<-- [start:object_type_Store]    
    type Store extending Place;
    # --8<-- [end:object_type_Store]    

}
