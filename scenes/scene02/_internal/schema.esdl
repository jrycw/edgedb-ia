# --8<-- [start:object_type_ChenLauContact]
type ChenLauContact extending Event {
    how: str;
    overloaded who: Character {default:= {chen, lau}}
}
# --8<-- [end:object_type_ChenLauContact]

# --8<-- [start:alias_chen]
alias chen:= assert_exists(assert_single((select GangsterSpy filter .name = "陳永仁")));
# --8<-- [end:alias_chen]

# --8<-- [start:alias_wong]
alias wong:= assert_exists(assert_single((select Police filter .name = "黃志誠")));
# --8<-- [end:alias_wong]

# --8<-- [start:test_alias] 
function test_alias() -> bool
using (all({
        test_scene01_alias(),
        test_scene02_alias(),
    })
);
# --8<-- [end:test_alias] 

# --8<-- [start:test_scene02_alias]
function test_scene02_alias() -> bool
using (all({
        (exists chen),          
        (exists wong), 
    })
);
# --8<-- [end:test_scene02_alias] 