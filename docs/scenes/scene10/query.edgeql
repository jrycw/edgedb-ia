insert Police {name:= "test_DCP", police_rank:=PoliceRank.DCP};
set global current_user_id:= (select Police filter .police_rank=PoliceRank.DCP limit 1).id;

update chen 
set {
    classic_lines := .classic_lines ++ ["對唔住，我係差人。"],
};

update lau 
set {
    classic_lines := ["我以前無得揀，我而家想做好人。"],
};

with b:= assert_single((select Police filter .name="林國平"))
insert GangsterSpy {
      name:= b.name,
      nickname:= b.nickname,
      police_rank:= b.police_rank,
      gangster_boss:= hon,
      dept:= b.dept,
      actors:= b.actors
};


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



insert Character {
    name:= "Mary",
    eng_name:= "Mary",
    lover:= lau,
    actors:= (insert Actor{
        name:= "鄭秀文",
        eng_name:= "Sammi",
    }),
};


update lau 
set {
    lover:= assert_single((select Character filter .name="Mary")),
};

insert Character {
    name:= "李心兒",
    lover:= chen,
    actors:= (insert Actor{
        name:= "陳慧琳",
        eng_name:= "Kelly",
    }),
};

update chen 
set {
    lover:= assert_single((select Character filter .name="李心兒")),
};


insert Character{
    name:= "May",
    eng_name:= "May",
    lovers:= chen,
    actors:= (insert Actor{
        name:= "蕭亞軒",
        eng_name:= "Elva",
    }),
};

update chen 
set {
    lovers+= assert_single((select Character filter .name="May")),
};

select chen.lovers.name;

update Character filter .name="陳永仁"
set {lovers:= (select Character filter .name="李心兒")};

update chen
set {lovers:= (select Character filter .name="李心兒")};

with ch:= (select Character filter .name="陳永仁")
update ch
set {lovers:= (select Character filter .name="李心兒")};

update PoliceSpy filter .name="陳永仁"
set {lovers:= (select Character filter .name="李心兒")};

update Character filter .name="陳永仁"
set {lovers:= (select detached Character filter .name="李心兒")};


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

select Police filter .name="test_DCP";

with pid:= <str>(select Police filter .name="test_DCP").id,
select Police filter .id=<uuid>pid;

with pid:= <str>(select Police filter .name="test_DCP").id,
select <Police><uuid>pid;

with pid:= <str>(select Police filter .name="test_DCP").id,
select (<Police><uuid>pid) {*};

with pid:= (select Police filter .name="test_DCP").id,
select <Police>pid;

with pid:= <str>(select Police filter .name="test_DCP").id,
delete <Police><uuid>pid;

reset global current_user_id;
