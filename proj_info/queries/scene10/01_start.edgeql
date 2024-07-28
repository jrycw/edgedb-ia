with one_dcp:= (select Police filter .police_rank=PoliceRank.DCP limit 1)
select if exists one_dcp then {
    (select one_dcp.id)
} else {
    (select (select (insert Police {name:= "test_DCP", police_rank:=PoliceRank.DCP})).id)
};

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