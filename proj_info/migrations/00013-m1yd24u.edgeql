CREATE MIGRATION m1yd24uzikzfjk3lbwpgeyzo6kjgourvj5wu7psvbog67u3n4wjmpq
    ONTO m1f62bczhdawkow3bphndbuie3gdl2htatf5mxatxw54hqjoy5laaa
{
  CREATE EXTENSION pgcrypto VERSION '1.3';
  CREATE ALIAS default::morse_code_of_undercover := (
      std::str_replace('..- -. -.. . .-. -.-. --- ...- . .-.', '-', '_')
  );
  CREATE FUNCTION default::get_stored_encrypted_password() ->  std::str USING (WITH
      code := 
          default::morse_code_of_undercover
  SELECT
      ext::pgcrypto::crypt(code, ext::pgcrypto::gen_salt())
  );
  CREATE FUNCTION default::test_scene09_alias() ->  std::bool USING (std::all({EXISTS (default::morse_code_of_undercover)}));
  CREATE FUNCTION default::validate_password(code: std::str) ->  std::bool USING (WITH
      hash := 
          default::get_stored_encrypted_password()
  SELECT
      (ext::pgcrypto::crypt(code, hash) = hash)
  );
  CREATE GLOBAL default::current_user_id -> std::uuid;
  CREATE TYPE default::PoliceSpyFile EXTENDING default::Archive {
      CREATE MULTI LINK colleagues: default::PoliceSpy;
      CREATE ACCESS POLICY authorized_allow_all
          ALLOW ALL USING (WITH
              police_officer := 
                  (SELECT
                      default::IsPolice
                  FILTER
                      (.id = GLOBAL default::current_user_id)
                  )
          SELECT
              (IF EXISTS (police_officer) THEN ((police_officer.police_rank ?? default::PoliceRank.PC) >= default::PoliceRank.SP) ELSE false)
          ) {
              SET errmessage := 'PoliceRank required: PoliceRank.SP';
          };
      CREATE PROPERTY classified_info: std::str;
  };
  CREATE FUNCTION default::list_police_spy_names(code: std::str) ->  std::json USING (WITH
      police_spy_file := 
          (default::PoliceSpyFile IF default::validate_password(code) ELSE <default::PoliceSpyFile>{})
      ,
      names := 
          std::array_agg(police_spy_file.colleagues.name)
  SELECT
      std::json_object_pack({('names', <std::json>names)})
  );
  ALTER FUNCTION default::test_alias() USING (std::all({default::test_scene01_alias(), default::test_scene02_alias(), default::test_scene03_alias(), default::test_scene05_alias(), default::test_scene09_alias()}));
  ALTER TYPE default::PoliceSpy {
      CREATE ACCESS POLICY authorized_allow_insert_update_delete
          ALLOW UPDATE, DELETE, INSERT USING (WITH
              police_officer := 
                  (SELECT
                      default::IsPolice
                  FILTER
                      (.id = GLOBAL default::current_user_id)
                  )
          SELECT
              (IF EXISTS (police_officer) THEN ((police_officer.police_rank ?? default::PoliceRank.PC) >= default::PoliceRank.DCP) ELSE false)
          ) {
              SET errmessage := 'PoliceRank required: PoliceRank.DCP';
          };
      CREATE ACCESS POLICY authorized_allow_select
          ALLOW SELECT USING (WITH
              police_officer := 
                  (SELECT
                      default::IsPolice
                  FILTER
                      (.id = GLOBAL default::current_user_id)
                  )
          SELECT
              (IF EXISTS (police_officer) THEN ((police_officer.police_rank ?? default::PoliceRank.PC) >= default::PoliceRank.SP) ELSE false)
          ) {
              SET errmessage := 'PoliceRank required: PoliceRank.SP';
          };
  };
};
