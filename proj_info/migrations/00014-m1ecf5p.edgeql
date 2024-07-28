CREATE MIGRATION m1ecf5pn6k7l4kwhb5w3eg3ucwppgfykndhsxaxkputy3kig7itwva
    ONTO m1yd24uzikzfjk3lbwpgeyzo6kjgourvj5wu7psvbog67u3n4wjmpq
{
  ALTER TYPE default::Character {
      ALTER LINK lover {
          RENAME TO lovers;
      };
  };
  ALTER TYPE default::Character {
      ALTER LINK lovers {
          SET MULTI;
      };
  };
};
