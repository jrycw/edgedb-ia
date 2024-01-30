CREATE MIGRATION m16xboo673icbje6taadxtud76v5hfutc3hjzxexhy42lszjhogpda
    ONTO m16j44velzxt3wk6olqyjdj6yvptu4k6jrbeqlultuzdjdtx7fd7jq
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
