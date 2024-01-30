# --8<-- [start:global_type_current_user_id]
global current_user_id: uuid;
# --8<-- [end:global_type_current_user_id]

# --8<-- [start:object_type_PoliceSpy]
type PoliceSpy extending Character, IsSpy {
    access policy authorized_allow_insert_update_delete
        allow insert, update, delete
        using (with police_officer:= (select IsPolice filter .id = global current_user_id),
            select if exists police_officer then (
                    police_officer.police_rank ?? PoliceRank.PC >= PoliceRank.DCP
                ) else (
                    false
                )                                                                                                                  
        )
        {
            errmessage := "PoliceRank required: PoliceRank.DCP"
        };

    access policy authorized_allow_select
        allow select
        using (with police_officer:= (select IsPolice filter .id = global current_user_id),
            select if exists police_officer then (
                    police_officer.police_rank ?? PoliceRank.PC >= PoliceRank.SP
                ) else (
                    false
                )                                                                                                                  
        )
        {
            errmessage := "PoliceRank required: PoliceRank.SP"
        };

};
# --8<-- [end:object_type_PoliceSpy]

# --8<-- [start:object_type_PoliceSpyFile]
type PoliceSpyFile extending Archive {
    multi colleagues: PoliceSpy;
    classified_info: str; 

    access policy authorized_allow_all
        allow all
        using (with police_officer:= (select IsPolice filter .id = global current_user_id),
            select if exists police_officer then (
                    police_officer.police_rank ?? PoliceRank.PC >= PoliceRank.SP
                ) else (
                    false
                )                                                                                                                  
        )
    {
        errmessage := "PoliceRank required: PoliceRank.SP"
    };
}
# --8<-- [end:object_type_PoliceSpyFile]

# --8<-- [start:list_police_spy_names]
function list_police_spy_names(code: str) -> json
using (
    with police_spy_file:= PoliceSpyFile if validate_password(code)
                           else <PoliceSpyFile>{},
         names:= array_agg(police_spy_file.colleagues.name),
    select json_object_pack({("names", <json>(names))})
);
# --8<-- [end:list_police_spy_names]

# --8<-- [start:extension_pgcrypto]
...
using extension pg_trgm;

module default {
    ...
}
# --8<-- [end:extension_pgcrypto]

# --8<-- [start:alias_morse_code_of_undercover]
alias morse_code_of_undercover:= str_replace("..- -. -.. . .-. -.-. --- ...- . .-.", "-", "_");
# --8<-- [end:alias_morse_code_of_undercover]

# --8<-- [start:test_alias]
function test_alias() -> bool
using (all({
        test_scene01_alias(),
        test_scene02_alias(),
        test_scene03_alias(),
        test_scene05_alias(),
        test_scene09_alias(),
    })
);
# --8<-- [end:test_alias]

# --8<-- [start:test_scene09_alias]
function test_scene09_alias() -> bool
using (all({
        (exists morse_code_of_undercover),
    })
);
# --8<-- [end:test_scene09_alias]

# --8<-- [start:function_get_stored_encrypted_password]
function get_stored_encrypted_password() -> str
using (
    with code:= morse_code_of_undercover,
            module ext::pgcrypto, 
    select crypt(code, gen_salt())
);
# --8<-- [end:function_get_stored_encrypted_password]

# --8<-- [start:function_validate_password]
function validate_password(code: str) -> bool
using (
    with hash:= get_stored_encrypted_password(),
            module ext::pgcrypto,
    select crypt(code, hash) = hash
);
# --8<-- [end:function_validate_password]