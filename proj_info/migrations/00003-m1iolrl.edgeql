CREATE MIGRATION m1iolrlkdl63zmbic6vfn3jcbkcygyvzoj6fcg4jo7qv7nfctnjrnq
    ONTO m1d4u43vqej5cm2hj3atx2rwj64geqmcxwwqahnwx53d6yz5jedfaa
{
  CREATE ALIAS default::chen := (
      std::assert_exists(std::assert_single((SELECT
          default::PoliceSpy
      FILTER
          (.name = '陳永仁')
      )))
  );
  CREATE ALIAS default::wong := (
      std::assert_exists(std::assert_single((SELECT
          default::Police
      FILTER
          (.name = '黃志誠')
      )))
  );
  CREATE FUNCTION default::test_scene02_alias() ->  std::bool USING (std::all({EXISTS (default::chen), EXISTS (default::wong)}));
  ALTER FUNCTION default::test_alias() USING (std::all({default::test_scene01_alias(), default::test_scene02_alias()}));
};
