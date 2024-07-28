CREATE MIGRATION m1en23ahl7rdq4pcuaoejswszaybhzlgxc3qwpcks56ba7rmc5q6wq
    ONTO m1d2wepwiyhx6ddv7rey265hmvm73jorq6as6ddtu337jwjfdrl4sq
{
  CREATE ALIAS default::year_2002 := (
      std::assert_exists(std::assert_single((SELECT
          default::FuzzyTime
      FILTER
          (((((((.fuzzy_year = 2002) AND (.fuzzy_month ?= <default::FuzzyMonth>{})) AND (.fuzzy_day ?= <default::FuzzyDay>{})) AND (.fuzzy_hour ?= <default::FuzzyHour>{})) AND (.fuzzy_minute ?= <default::FuzzyMinute>{})) AND (.fuzzy_second ?= <default::FuzzySecond>{})) AND (.fuzzy_dow ?= <default::DayOfWeek>{}))
      )))
  );
  CREATE FUNCTION default::test_scene05_alias() ->  std::bool USING (std::all({EXISTS (default::year_1994)}));
  ALTER FUNCTION default::test_alias() USING (std::all({default::test_scene01_alias(), default::test_scene02_alias(), default::test_scene03_alias(), default::test_scene05_alias()}));
};
