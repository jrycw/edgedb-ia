# --8<-- [start:insert_year_1992]
insert FuzzyTime {fuzzy_year:= 1992};
# --8<-- [end:insert_year_1992]

# --8<-- [start:insert_hon]
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
# --8<-- [end:insert_hon]

# --8<-- [start:insert_lau]
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
# --8<-- [end:insert_lau]

# --8<-- [start:test_alias]
select test_alias();
# --8<-- [end:test_alias]

# --8<-- [start:insert_scene]
insert Scene {
    title:= "韓琛初現",
    detail:= "韓琛準備派遣多個身家較為清白的小弟臥底至香港警隊，包括建明。" ++
             "他向小弟們講述著自己的過去，並說自己不相信算命先生所說的" ++
             "「一將功成萬骨枯」。他認為出來混的，未來的路怎麼走應該由自己決定。",
    remarks:= "1.假設此場景為1992年。",  
    who:= {hon, lau},
    `when`:= year_1992,
    where:= (insert Location {name:= "佛堂"}) ,   
    references:= [("維基百科-無間道", "https://zh.wikipedia.org/zh-tw/%E7%84%A1%E9%96%93%E9%81%93"),
                  ("香港警察職級", "https://zh.wikipedia.org/zh-tw/%E9%A6%99%E6%B8%AF%E8%AD%A6%E5%AF%9F%E8%81%B7%E7%B4%9A")]
};
# --8<-- [end:insert_scene]