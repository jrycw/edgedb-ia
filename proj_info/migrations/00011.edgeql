CREATE MIGRATION m1cyfd35g55tg36lvobgy2hmxkrpmvvk432vskn5exxmslw3bxyv2a
    ONTO m1ppscybzqoxvx32xwgtfcxz5n4k7nprbzhrkw6n2nn7lleky2ngma
{
  CREATE TYPE default::Envelope {
      CREATE ACCESS POLICY allow_select_insert_delete
          ALLOW SELECT, DELETE, INSERT ;
      CREATE ACCESS POLICY only_one_envelope_exists
          DENY INSERT USING (EXISTS (default::Envelope)) {
              SET errmessage := 'Only one Envelope can be existed.';
          };
      CREATE PROPERTY name: std::str {
          SET default := '標';
          SET readonly := true;
      };
  };
};
