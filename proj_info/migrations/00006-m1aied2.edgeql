CREATE MIGRATION m1aied2jdcfmhoyemqucenfzfugenpfkrltizeqmppzossbnlgdiea
    ONTO m1fn7t6zu27x3lrukpvwfqgliidyq6ouxtqmwqa77mjjuqu37npe6q
{
  CREATE ABSTRACT TYPE default::Archive;
  CREATE TYPE default::CriminalRecord EXTENDING default::Archive {
      CREATE MULTI LINK involved: default::Character;
      CREATE REQUIRED PROPERTY code: std::str;
      CREATE PROPERTY created_at: std::datetime {
          SET readonly := true;
          CREATE REWRITE
              INSERT 
              USING (std::datetime_of_statement());
      };
      CREATE PROPERTY modified_at: std::datetime {
          CREATE REWRITE
              UPDATE 
              USING (std::datetime_of_statement());
      };
      CREATE REQUIRED PROPERTY ref_no: std::str {
          CREATE CONSTRAINT std::exclusive;
      };
  };
};
