insert FuzzyTime {fuzzy_year:= 1992};

insert Actor {
     name:= "曾志偉",
     eng_name:= "Eric",
     nickname:= "獎老",
};
  
insert GangsterBoss {
    name:= "韓琛",
    nickname:= "琛哥",
    classic_lines:= ["一將功成萬骨枯"],
    actors := assert_single((select Actor filter .name = "曾志偉")),
};

insert Actor {
    name:= "陳冠希",
    eng_name:= "Edison",
};

insert GangsterSpy {
   name:= "劉建明",
   nickname:= "劉仔",
   gangster_boss:= assert_single((select GangsterBoss filter .name = "韓琛")),
   dept:= "警校學生",
   actors := assert_single((select Actor filter .name in {"陳冠希"})),
};