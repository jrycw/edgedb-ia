# --8<-- [start:object_type_Envelope]
type Envelope {
    name: str {
        default:= "標";
        readonly:= true
    };
    access policy allow_select_insert_delete
        allow select, insert, delete;

    access policy only_one_envelope_exists
        deny insert
        using (exists Envelope)
        {
            errmessage := 'Only one Envelope can be existed.'
        };
}
# --8<-- [end:object_type_Envelope]

# --8<-- [start:extension_pg_trgm]
using extension pg_trgm;

module default {
    ...
}
# --8<-- [end:extension_pg_trgm]