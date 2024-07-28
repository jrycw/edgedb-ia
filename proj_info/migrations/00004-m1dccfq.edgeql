CREATE MIGRATION m1dccfqhsgaadnglq2ckmbu5a2e7yzpxqb2cuf2airm75lj7unb27a
    ONTO m1iolrlkdl63zmbic6vfn3jcbkcygyvzoj6fcg4jo7qv7nfctnjrnq
{
  CREATE TYPE default::ChenLauContact EXTENDING default::Event {
      ALTER LINK who {
          SET default := {default::chen, default::lau};
          SET OWNED;
          SET TYPE default::Character;
      };
      CREATE PROPERTY how: std::str;
  };
};
