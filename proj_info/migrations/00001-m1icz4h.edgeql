CREATE MIGRATION m1icz4hxkdlltw2fwwiief5tjgomwgr2ihpmdeny7owr235wmpqecq
    ONTO initial
{
  CREATE ABSTRACT TYPE default::Person {
      CREATE PROPERTY eng_name: std::str;
      CREATE REQUIRED PROPERTY name: std::str;
      CREATE PROPERTY nickname: std::str;
  };
  CREATE TYPE default::Actor EXTENDING default::Person;
  CREATE TYPE default::Character EXTENDING default::Person {
      CREATE MULTI LINK actors: default::Actor;
      CREATE LINK lover: default::Character;
      CREATE PROPERTY classic_lines: array<std::str>;
  };
  CREATE ABSTRACT TYPE default::Place {
      CREATE REQUIRED PROPERTY name: std::str {
          CREATE DELEGATED CONSTRAINT std::exclusive;
      };
  };
  CREATE SCALAR TYPE default::SceneNumber EXTENDING std::sequence;
  CREATE ABSTRACT TYPE default::Event {
      CREATE MULTI LINK who: default::Character;
      CREATE MULTI LINK where: default::Place;
      CREATE PROPERTY detail: std::str;
  };
  CREATE TYPE default::Scene EXTENDING default::Event {
      CREATE PROPERTY references: array<tuple<std::str, std::str>>;
      CREATE REQUIRED PROPERTY scene_number: default::SceneNumber {
          SET default := (std::sequence_next(INTROSPECT default::SceneNumber));
          CREATE CONSTRAINT std::exclusive;
      };
      CREATE INDEX ON (.scene_number);
      CREATE PROPERTY remarks: std::str;
      CREATE PROPERTY title: std::str;
  };
  CREATE SCALAR TYPE default::PoliceRank EXTENDING enum<Protected, Cadet, PC, SPC, SGT, SSGT, PI, IP, SIP, CIP, SP, SSP, CSP, ACP, SACP, DCP, CP>;
  CREATE ABSTRACT TYPE default::IsPolice {
      CREATE PROPERTY dept: std::str;
      CREATE PROPERTY police_rank: default::PoliceRank {
          SET default := (default::PoliceRank.Cadet);
      };
      CREATE PROPERTY is_officer := ((.police_rank >= default::PoliceRank.PI));
  };
  CREATE TYPE default::Police EXTENDING default::Character, default::IsPolice;
  CREATE SCALAR TYPE default::GangsterRank EXTENDING enum<Nobody, Leader, Boss>;
  CREATE ABSTRACT TYPE default::IsGangster {
      CREATE PROPERTY gangster_rank: default::GangsterRank {
          SET default := (default::GangsterRank.Nobody);
      };
  };
  CREATE ABSTRACT TYPE default::IsSpy EXTENDING default::IsPolice, default::IsGangster;
  CREATE TYPE default::GangsterSpy EXTENDING default::Character, default::IsSpy {
      ALTER PROPERTY police_rank {
          SET default := (default::PoliceRank.Protected);
          SET OWNED;
          SET TYPE default::PoliceRank;
      };
  };
  CREATE TYPE default::Gangster EXTENDING default::Character, default::IsGangster;
  CREATE TYPE default::PoliceSpy EXTENDING default::Character, default::IsSpy;
  CREATE TYPE default::GangsterBoss EXTENDING default::Gangster {
      ALTER PROPERTY gangster_rank {
          SET default := (default::GangsterRank.Boss);
          SET OWNED;
          SET TYPE default::GangsterRank;
          CREATE CONSTRAINT std::expression ON ((__subject__ = default::GangsterRank.Boss));
      };
  };
  CREATE SCALAR TYPE default::DayOfWeek EXTENDING enum<Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday>;
  CREATE SCALAR TYPE default::FuzzyDay EXTENDING std::int64 {
      CREATE CONSTRAINT std::expression ON (((__subject__ >= 1) AND (__subject__ <= 31)));
  };
  CREATE SCALAR TYPE default::FuzzyHour EXTENDING std::int64 {
      CREATE CONSTRAINT std::expression ON (((__subject__ >= 0) AND (__subject__ <= 23)));
  };
  CREATE SCALAR TYPE default::FuzzyMinute EXTENDING std::int64 {
      CREATE CONSTRAINT std::expression ON (((__subject__ >= 0) AND (__subject__ <= 59)));
  };
  CREATE SCALAR TYPE default::FuzzyMonth EXTENDING std::int64 {
      CREATE CONSTRAINT std::expression ON (((__subject__ >= 1) AND (__subject__ <= 12)));
  };
  CREATE SCALAR TYPE default::FuzzySecond EXTENDING std::int64 {
      CREATE CONSTRAINT std::expression ON (((__subject__ >= 0) AND (__subject__ <= 59)));
  };
  CREATE SCALAR TYPE default::FuzzyYear EXTENDING std::int64;
  CREATE TYPE default::FuzzyTime {
      CREATE PROPERTY fuzzy_day: default::FuzzyDay;
      CREATE PROPERTY fuzzy_dow: default::DayOfWeek;
      CREATE PROPERTY fuzzy_hour: default::FuzzyHour;
      CREATE PROPERTY fuzzy_minute: default::FuzzyMinute;
      CREATE PROPERTY fuzzy_month: default::FuzzyMonth;
      CREATE PROPERTY fuzzy_second: default::FuzzySecond;
      CREATE PROPERTY fuzzy_year: default::FuzzyYear;
      CREATE PROPERTY fuzzy_fmt := (WITH
          Y := 
              (<std::str>.fuzzy_year ?? 'YYYY')
          ,
          m := 
              (<std::str>.fuzzy_month ?? 'MM')
          ,
          m := 
              (m IF (std::len(m) > 1) ELSE ('0' ++ m))
          ,
          d := 
              (<std::str>.fuzzy_day ?? 'DD')
          ,
          d := 
              (d IF (std::len(d) > 1) ELSE ('0' ++ d))
          ,
          H := 
              (<std::str>.fuzzy_hour ?? 'HH24')
          ,
          H := 
              (H IF (std::len(H) > 1) ELSE ('0' ++ H))
          ,
          M := 
              (<std::str>.fuzzy_minute ?? 'MI')
          ,
          M := 
              (M IF (std::len(M) > 1) ELSE ('0' ++ M))
          ,
          S := 
              (<std::str>.fuzzy_second ?? 'SS')
          ,
          S := 
              (S IF (std::len(S) > 1) ELSE ('0' ++ S))
          ,
          dow := 
              (<std::str>.fuzzy_dow ?? 'ID')
      SELECT
          ((((((((((((Y ++ '/') ++ m) ++ '/') ++ d) ++ '_') ++ H) ++ ':') ++ M) ++ ':') ++ S) ++ '_') ++ dow)
      );
      CREATE CONSTRAINT std::exclusive ON (.fuzzy_fmt);
      CREATE TRIGGER fuzzy_month_day_check
          AFTER UPDATE, INSERT 
          FOR EACH 
              WHEN ((EXISTS (__new__.fuzzy_month) AND EXISTS (__new__.fuzzy_day)))
          DO (std::assert_exists(cal::to_local_date((__new__.fuzzy_year ?? 2002), __new__.fuzzy_month, __new__.fuzzy_day)));
  };
  ALTER TYPE default::Event {
      CREATE MULTI LINK `when`: default::FuzzyTime;
  };
  ALTER TYPE default::IsGangster {
      CREATE LINK gangster_boss: default::GangsterBoss;
  };
  ALTER TYPE default::GangsterBoss {
      CREATE CONSTRAINT std::expression ON ((__subject__ != .gangster_boss)) {
          SET errmessage := "The boss can't be his/her own boss.";
      };
  };
  CREATE TYPE default::Landmark EXTENDING default::Place;
  CREATE TYPE default::Location EXTENDING default::Place;
  CREATE TYPE default::Store EXTENDING default::Place;
};
