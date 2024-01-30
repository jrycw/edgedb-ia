CREATE MIGRATION m136gnzuezxpgyv7ju4pgostosaq3uql6nnqlyzipkvnjmcdicalxq
    ONTO m16xboo673icbje6taadxtud76v5hfutc3hjzxexhy42lszjhogpda
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
