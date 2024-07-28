CREATE MIGRATION m1lp75tn62kfa4dbkkkv2u4pr3t2jjeyrix7cntwllnjid2mmu23qq
    ONTO m1ngyznn6gdb6gjlvzcgw7dvdrmz7fbbfxzllxc3765gviarr4dvvq
{
  CREATE TYPE default::Envelope {
      CREATE ACCESS POLICY allow_select_insert_delete
          ALLOW SELECT, DELETE, INSERT ;
      CREATE ACCESS POLICY only_one_envelope_exists
          DENY INSERT USING (EXISTS (default::Envelope)) {
              SET errmessage := 'Only one Envelope can be existed.';
          };
      CREATE PROPERTY name: std::str {
          SET default := '標';
          SET readonly := true;
      };
  };
};
