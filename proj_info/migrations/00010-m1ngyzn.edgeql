CREATE MIGRATION m1ngyznn6gdb6gjlvzcgw7dvdrmz7fbbfxzllxc3765gviarr4dvvq
    ONTO m1dem5eboiim52mq67hlkcoznwqmusag66vp6yfh7ynuggbp3y5cfq
{
  CREATE SCALAR TYPE default::TeamTreatNumber EXTENDING std::sequence;
  CREATE TYPE default::CIBTeamTreat {
      CREATE MULTI LINK colleagues: default::Police {
          SET default := (SELECT
              default::Police
          FILTER
              (.dept = '刑事情報科(CIB)')
          );
          SET readonly := true;
          CREATE PROPERTY point: std::int64 {
              SET default := (<std::int64>math::ceil((std::random() * 10)));
          };
      };
      CREATE PROPERTY team_treat := ((std::max(.colleagues@point) >= 9));
      CREATE REQUIRED PROPERTY team_treat_number: default::TeamTreatNumber {
          SET default := (std::sequence_next(INTROSPECT default::TeamTreatNumber));
          CREATE CONSTRAINT std::exclusive;
      };
  };
};
