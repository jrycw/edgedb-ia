# --8<-- [start:set_global]
insert Police {name:= "test_DCP", police_rank:=PoliceRank.DCP};
set global current_user_id:= (select Police filter .police_rank=PoliceRank.DCP limit 1).id;
# --8<-- [end:set_global]

# --8<-- [start:update_chen1]
update chen 
set {
    classic_lines := .classic_lines ++ ["對唔住，我係差人。"],
};
# --8<-- [end:update_chen1]

# --8<-- [start:update_lau1]
update lau 
set {
    classic_lines := ["我以前無得揀，我而家想做好人。"],
};
# --8<-- [end:update_lau1]

# --8<-- [start:insert_big_b_as_gangster_spy]
with b:= assert_single((select Police filter .name="林國平"))
insert GangsterSpy {
      name:= b.name,
      nickname:= b.nickname,
      police_rank:= b.police_rank,
      gangster_boss:= hon,
      dept:= b.dept,
      actors:= b.actors
};
# --8<-- [end:insert_big_b_as_gangster_spy]


# --8<-- [start:insert_chenlaucontact]
insert ChenLauContact {
    how:= "面對面",
    detail:= "建明與永仁相約於天台上談判",
    `when`:=  (insert FuzzyTime {
                fuzzy_year:=2002,
                fuzzy_month:=11,
                fuzzy_day:=27,
                fuzzy_hour:=15,
                fuzzy_minute:=0,
                fuzzy_second:=0,
            }),
    where:= (select Location filter .name="天台"),
};
# --8<-- [end:insert_chenlaucontact]


############################### Actress start ###############################

# --8<-- [start:insert_mary]
insert Character {
    name:= "Mary",
    eng_name:= "Mary",
    lover:= lau,
    actors:= (insert Actor{
        name:= "鄭秀文",
        eng_name:= "Sammi",
    }),
};
# --8<-- [end:insert_mary]


# --8<-- [start:update_lau2]
update lau 
set {
    lover:= assert_single((select Character filter .name="Mary")),
};
# --8<-- [end:update_lau2]

# --8<-- [start:insert_li]
insert Character {
    name:= "李心兒",
    lover:= chen,
    actors:= (insert Actor{
        name:= "陳慧琳",
        eng_name:= "Kelly",
    }),
};
# --8<-- [end:insert_li]

# --8<-- [start:update_chen2]
update chen 
set {
    lover:= assert_single((select Character filter .name="李心兒")),
};
# --8<-- [end:update_chen2]


# --8<-- [start:insert_may]
insert Character{
    name:= "May",
    eng_name:= "May",
    lovers:= chen,
    actors:= (insert Actor{
        name:= "蕭亞軒",
        eng_name:= "Elva",
    }),
};
# --8<-- [end:insert_may]

# --8<-- [start:update_chen3]
update chen 
set {
    lovers+= assert_single((select Character filter .name="May")),
};
# --8<-- [end:update_chen3]

# --8<-- [start:check_chen_lovers]
select chen.lovers.name;
# --8<-- [end:check_chen_lovers]

# --8<-- [start:update_chen4_1_ng]
update Character filter .name="陳永仁"
set {lovers:= (select Character filter .name="李心兒")};
# --8<-- [end:update_chen4_1_ng]

# --8<-- [start:update_chen4_2_ok]
update chen
set {lovers:= (select Character filter .name="李心兒")};
# --8<-- [end:update_chen4_2_ok]

# --8<-- [start:update_chen4_3_ok]
with ch:= (select Character filter .name="陳永仁")
update ch
set {lovers:= (select Character filter .name="李心兒")};
# --8<-- [end:update_chen4_3_ok]

# --8<-- [start:update_chen4_4_ok]
update PoliceSpy filter .name="陳永仁"
set {lovers:= (select Character filter .name="李心兒")};
# --8<-- [end:update_chen4_4_ok]

# --8<-- [start:update_chen4_5_detached]
update Character filter .name="陳永仁"
set {lovers:= (select detached Character filter .name="李心兒")};
# --8<-- [end:update_chen4_5_detached]

############################### Actress end ###############################

# --8<-- [start:insert_scene]
insert Scene {
      title:= "我想做個好人", 
      detail:= "建明與永仁於天台相見，不料國平也趕到。永仁事先已報警，想持槍壓著建明" ++
               "到樓下交予警方。不料，於進電梯時被國平擊斃，原來他也是韓琛安裝於警" ++ 
               "隊的臥底。國平向建明表明身份，希望之後一起合作。但最終建明選擇於電梯" ++
               "中殺死國平，並營造永仁與國平雙雙死於槍戰的假象。事後，心兒於葉校長遺" ++
               "物中發現永仁臥底檔案，恢復其警察身份，並由建明代表行禮。",
      who:=  (select Police filter .name="林國平") union 
             (select PoliceSpy filter .name="林國平") union
             {chen, lau},
      `when`:= assert_single((select FuzzyTime filter .fuzzy_fmt="2002/11/27_15:00:00_ID")),
      where:= (select Location filter .name="天台"),    
};
# --8<-- [end:insert_scene]

# --8<-- [start:select_dcp_1]
select Police filter .name="test_DCP";
# --8<-- [end:select_dcp_1]

# --8<-- [start:select_dcp_2]
with pid:= <str>(select Police filter .name="test_DCP").id,
select Police filter .id=<uuid>pid;
# --8<-- [end:select_dcp_2]

# --8<-- [start:select_dcp_3]
with pid:= <str>(select Police filter .name="test_DCP").id,
select <Police><uuid>pid;
# --8<-- [end:select_dcp_3]

# --8<-- [start:select_dcp_shape]
with pid:= <str>(select Police filter .name="test_DCP").id,
select (<Police><uuid>pid) {*};
# --8<-- [end:select_dcp_shape]

# --8<-- [start:select_dcp_4]
with pid:= (select Police filter .name="test_DCP").id,
select <Police>pid;
# --8<-- [end:select_dcp_4]

# --8<-- [start:delete_dcp]
with pid:= <str>(select Police filter .name="test_DCP").id,
delete <Police><uuid>pid;
# --8<-- [end:delete_dcp]

# --8<-- [start:reset_global]
reset global current_user_id;
# --8<-- [end:reset_global]
