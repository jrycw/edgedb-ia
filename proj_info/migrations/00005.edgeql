CREATE MIGRATION m1fjui2bohofvhbeyii2pas6fzupyb7a5odygxpqaeewnxrkbtqrhq
    ONTO m136gnzuezxpgyv7ju4pgostosaq3uql6nnqlyzipkvnjmcdicalxq
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
