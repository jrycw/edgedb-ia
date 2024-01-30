CREATE MIGRATION m17ioxejmqetxu4ex54m2gt66tjxtyicsvy67eb3p5nhn3hjrz4zhq
    ONTO m167aa2yvy7i3v65yyzo4clj6ik3ugilphxirh2o42wnq7g2i7xnta
{
  CREATE TYPE default::Beverage {
      CREATE LINK consumed_by: default::Character;
      CREATE LINK produced_by: default::Store;
      CREATE LINK `when`: default::FuzzyTime;
      CREATE LINK where: default::Place;
      CREATE REQUIRED PROPERTY name: std::str;
  };
};
