CREATE MIGRATION m1fn7t6zu27x3lrukpvwfqgliidyq6ouxtqmwqa77mjjuqu37npe6q
    ONTO m1dccfqhsgaadnglq2ckmbu5a2e7yzpxqb2cuf2airm75lj7unb27a
{
  CREATE ALIAS default::police_station := (
      std::assert_exists(std::assert_single((SELECT
          default::Landmark
      FILTER
          (.name = '警察局')
      )))
  );
  CREATE ALIAS default::year_1994 := (
      std::assert_exists(std::assert_single((SELECT
          default::FuzzyTime
      FILTER
          (((((((.fuzzy_year = 1994) AND (.fuzzy_month ?= <default::FuzzyMonth>{})) AND (.fuzzy_day ?= <default::FuzzyDay>{})) AND (.fuzzy_hour ?= <default::FuzzyHour>{})) AND (.fuzzy_minute ?= <default::FuzzyMinute>{})) AND (.fuzzy_second ?= <default::FuzzySecond>{})) AND (.fuzzy_dow ?= <default::DayOfWeek>{}))
      )))
  );
  CREATE FUNCTION default::test_scene03_alias() ->  std::bool USING (std::all({EXISTS (default::year_1994), EXISTS (default::police_station)}));
  ALTER FUNCTION default::test_alias() USING (std::all({default::test_scene01_alias(), default::test_scene02_alias(), default::test_scene03_alias()}));
};
