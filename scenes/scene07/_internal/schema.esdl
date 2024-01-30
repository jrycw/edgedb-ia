# --8<-- [start:abstract_object_type_Place]
abstract type Place {
    required name: str {
        delegated constraint exclusive;
    };
}
# --8<-- [end:abstract_object_type_Place]

# --8<-- [start:object_type_Beverage]
type Beverage {
    required name: str;
    produced_by: Store;
    consumed_by: Character;
    `when`: FuzzyTime;
    where: Place;
} 
# --8<-- [end:object_type_Beverage]

# --8<-- [start:scalar_type_TeamTreatNumber]
scalar type TeamTreatNumber extending sequence;
# --8<-- [end:scalar_type_TeamTreatNumber]

# --8<-- [start:object_type_CIBTeamTreat]
type CIBTeamTreat {
    required team_treat_number: TeamTreatNumber {
        constraint exclusive;
        default := sequence_next(introspect TeamTreatNumber);
    }
    multi colleagues: Police {
        default:= (select Police filter .dept="刑事情報科(CIB)");
        readonly := true;
        point: int64 {
            default:= <int64>math::ceil(random()*10)
        }
    };
    team_treat:= max(.colleagues@point) >= 9
}
# --8<-- [end:object_type_CIBTeamTreat]