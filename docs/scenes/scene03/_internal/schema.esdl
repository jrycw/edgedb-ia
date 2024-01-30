# --8<-- [start:abstract_object_type_Archive]
abstract type Archive;
# --8<-- [end:abstract_object_type_Archive]

# --8<-- [start:object_type_CriminalRecord]
type CriminalRecord extending Archive {
    required ref_no: str {
        constraint exclusive;
    };
    required code: str;
    multi involved: Character;
    created_at: datetime {
        readonly := true;
        rewrite insert using (datetime_of_statement())
    }
    modified_at: datetime {
        rewrite update using (datetime_of_statement())
    }
}
# --8<-- [end:object_type_CriminalRecord]

# --8<-- [start:alias_police_station]
alias police_station:= assert_exists(assert_single((select Landmark filter .name="警察局")));
# --8<-- [end:alias_police_station]

# --8<-- [start:alias_year_1994]
alias year_1994:= assert_exists(assert_single((select FuzzyTime 
                                    filter .fuzzy_year = 1994 
                                    and .fuzzy_month ?= <FuzzyMonth>{}
                                    and .fuzzy_day ?= <FuzzyDay>{}
                                    and .fuzzy_hour ?= <FuzzyHour>{}
                                    and .fuzzy_minute ?= <FuzzyMinute>{}
                                    and .fuzzy_second ?= <FuzzySecond>{}   
                                    and .fuzzy_dow ?= <DayOfWeek>{}
                    ))
);
# --8<-- [end:alias_year_1994]     

# --8<-- [start:test_alias] 
function test_alias() -> bool
using (all({
        test_scene01_alias(),
        test_scene02_alias(),
        test_scene03_alias(),
    })
);
# --8<-- [end:test_alias]

# --8<-- [start:test_scene03_alias] 
function test_scene03_alias() -> bool
using (all({
        (exists year_1994),   
        (exists police_station),   
    })
);
# --8<-- [end:test_scene03_alias] 