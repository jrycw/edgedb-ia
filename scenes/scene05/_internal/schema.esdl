# --8<-- [start:alias_year_2002]
alias year_2002:= assert_exists(assert_single((select FuzzyTime 
                                    filter .fuzzy_year = 2002 
                                    and .fuzzy_month ?= <FuzzyMonth>{}
                                    and .fuzzy_day ?= <FuzzyDay>{}
                                    and .fuzzy_hour ?= <FuzzyHour>{}
                                    and .fuzzy_minute ?= <FuzzyMinute>{}
                                    and .fuzzy_second ?= <FuzzySecond>{}   
                                    and .fuzzy_dow ?= <DayOfWeek>{}
                ))
);
# --8<-- [end:alias_year_2002]

# --8<-- [start:test_alias]
function test_alias() -> bool
using (all({
        test_scene01_alias(),
        test_scene02_alias(),
        test_scene03_alias(),
        test_scene05_alias(),
    })
);
# --8<-- [end:test_alias]

# --8<-- [start:test_scene05_alias]
function test_scene05_alias() -> bool
using (all({
        (exists year_1994),
    })
);
# --8<-- [end:test_scene05_alias]