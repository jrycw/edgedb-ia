CREATE MIGRATION m1hgbgfi27lwf3vg6pilotkr4i6vxhuqns3zzvhlf7y5czuj53giva
    ONTO m177hjcna3qg77ddbvyxmmbrye3wpwcknz7i6qa4n6ivbq5jejxwwq
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
