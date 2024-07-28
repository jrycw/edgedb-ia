CREATE MIGRATION m1dem5eboiim52mq67hlkcoznwqmusag66vp6yfh7ynuggbp3y5cfq
    ONTO m1en23ahl7rdq4pcuaoejswszaybhzlgxc3qwpcks56ba7rmc5q6wq
{
  CREATE TYPE default::Beverage {
      CREATE LINK consumed_by: default::Character;
      CREATE LINK produced_by: default::Store;
      CREATE LINK `when`: default::FuzzyTime;
      CREATE LINK where: default::Place;
      CREATE REQUIRED PROPERTY name: std::str;
  };
};
