CREATE MIGRATION m1d2wepwiyhx6ddv7rey265hmvm73jorq6as6ddtu337jwjfdrl4sq
    ONTO m1aied2jdcfmhoyemqucenfzfugenpfkrltizeqmppzossbnlgdiea
{
  CREATE FUNCTION default::is_hi_fi_store_open(dow: default::DayOfWeek, visit_hour: std::int64) ->  std::bool USING (WITH
      open_hours := 
          std::multirange([std::range(11, 13), std::range(14, 19), std::range(20, 22)])
  SELECT
      ((dow != default::DayOfWeek.Wednesday) AND std::contains(open_hours, visit_hour))
  );
  CREATE FUNCTION default::test_hi_fi_store_close() ->  std::bool USING (NOT (std::all({default::is_hi_fi_store_open(default::DayOfWeek.Wednesday, 12), default::is_hi_fi_store_open(default::DayOfWeek.Thursday, 13), default::is_hi_fi_store_open(default::DayOfWeek.Sunday, 19)})));
  CREATE FUNCTION default::test_hi_fi_store_open() ->  std::bool USING (std::all({default::is_hi_fi_store_open(default::DayOfWeek.Monday, 12), default::is_hi_fi_store_open(default::DayOfWeek.Friday, 15), default::is_hi_fi_store_open(default::DayOfWeek.Saturday, 21)}));
};
