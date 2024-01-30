# abstract object types
abstract type Place {
    required name: str {
        delegated constraint exclusive;
    };
}

# object types
type Landmark extending Place;
type Location extending Place;
type Store extending Place;


