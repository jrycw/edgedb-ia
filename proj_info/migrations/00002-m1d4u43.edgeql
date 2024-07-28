CREATE MIGRATION m1d4u43vqej5cm2hj3atx2rwj64geqmcxwwqahnwx53d6yz5jedfaa
    ONTO m1icz4hxkdlltw2fwwiief5tjgomwgr2ihpmdeny7owr235wmpqecq
{
  CREATE ALIAS default::hon := (
      std::assert_exists(std::assert_single((SELECT
          default::GangsterBoss
      FILTER
          (.name = '韓琛')
      )))
  );
  CREATE ALIAS default::lau := (
      std::assert_exists(std::assert_single((SELECT
          default::GangsterSpy
      FILTER
          (.name = '劉建明')
      )))
  );
  CREATE ALIAS default::year_1992 := (
      std::assert_exists(std::assert_single((SELECT
          default::FuzzyTime
      FILTER
          (((((((.fuzzy_year = 1992) AND (.fuzzy_month ?= <default::FuzzyMonth>{})) AND (.fuzzy_day ?= <default::FuzzyDay>{})) AND (.fuzzy_hour ?= <default::FuzzyHour>{})) AND (.fuzzy_minute ?= <default::FuzzyMinute>{})) AND (.fuzzy_second ?= <default::FuzzySecond>{})) AND (.fuzzy_dow ?= <default::DayOfWeek>{}))
      )))
  );
  CREATE FUNCTION default::test_scene01_alias() ->  std::bool USING (std::all({EXISTS (default::hon), EXISTS (default::lau), EXISTS (default::year_1992)}));
  CREATE FUNCTION default::test_alias() ->  std::bool USING (std::all({default::test_scene01_alias()}));
};
