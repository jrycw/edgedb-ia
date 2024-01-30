# --8<-- [start:alias_hon]
alias hon:= assert_exists(assert_single((select GangsterBoss filter .name = "韓琛")));
# --8<-- [end:alias_hon]

# --8<-- [start:alias_lau]
alias lau:= assert_exists(assert_single((select GangsterSpy filter .name = "劉建明")));
# --8<-- [end:alias_lau]

# --8<-- [start:alias_year_1992] 
alias year_1992:= assert_exists(assert_single((select FuzzyTime 
                                    filter .fuzzy_year = 1992 
                                    and .fuzzy_month ?= <FuzzyMonth>{}
                                    and .fuzzy_day ?= <FuzzyDay>{}
                                    and .fuzzy_hour ?= <FuzzyHour>{}
                                    and .fuzzy_minute ?= <FuzzyMinute>{}
                                    and .fuzzy_second ?= <FuzzySecond>{}   
                                    and .fuzzy_dow ?= <DayOfWeek>{}
                    ))
);
# --8<-- [end:alias_year_1992] 

# --8<-- [start:test_alias] 
function test_alias() -> bool
using (all({
        test_scene01_alias(),
    })
);
# --8<-- [end:test_alias] 

# --8<-- [start:test_scene01_alias]
function test_scene01_alias() -> bool
using (all({
        (exists hon),          
        (exists lau),
        (exists year_1992),   
    })
);
# --8<-- [end:test_scene01_alias] 