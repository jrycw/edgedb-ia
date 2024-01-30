CREATE MIGRATION m167aa2yvy7i3v65yyzo4clj6ik3ugilphxirh2o42wnq7g2i7xnta
    ONTO m1ngvzy5p3nncwvb6a5s565yxpkpme45yca2wkfxa764ha3nq5amja
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
