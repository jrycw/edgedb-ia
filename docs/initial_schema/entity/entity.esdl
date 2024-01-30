# scalar types
scalar type SceneNumber extending sequence;

# abstract object types
abstract type Event {
    detail: str;
    multi who: Character;
    multi `when`: FuzzyTime;
    multi where: Place;
}

# object types
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
    

