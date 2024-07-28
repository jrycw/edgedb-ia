set global current_user_id:= (select Police filter .police_rank=PoliceRank.SP limit 1).id;

select test_alias();

reset global current_user_id;

select validate_password(morse_code_of_undercover); # {true}
select validate_password("27149"); # {false}

set global current_user_id:= (select Police filter .police_rank=PoliceRank.SP limit 1).id;

insert PoliceSpy {name:= "test_police_spy_by_SP"}; # AccessPolicyError

select PoliceSpy;

update PoliceSpy
filter .name="陳永仁"
set {
    nickname:= .nickname ++ "!",
}; # {}

delete PoliceSpy filter .name="陳永仁"; # {}

insert PoliceSpyFile {
    colleagues:= chen,
    classified_info:= "Handler: test_SP...",
};

select PoliceSpyFile; 

select list_police_spy_names(morse_code_of_undercover); # {Json("{\"names\": [\"陳永仁\"]}")}
select list_police_spy_names("abc"); # {Json("{\"names\": []}")}

update PoliceSpyFile filter .classified_info="Handler: test_SP..."
set {
    classified_info:= .classified_info ++ "..."
};

delete PoliceSpyFile;

reset global current_user_id;

insert Police {name:= "test_DCP", police_rank:=PoliceRank.DCP};
set global current_user_id:= (select Police filter .police_rank=PoliceRank.DCP limit 1).id;

Insert PoliceSpy {name:= "test_police_spy_by_DPC"};

select PoliceSpy;

update PoliceSpy filter .name="test_police_spy_by_DPC"
set {
    nickname:= "test_police_spy_by_DPC",
};

delete PoliceSpy filter .nickname="test_police_spy_by_DPC";

insert PoliceSpyFile {
    colleagues:= chen,
    classified_info:= "Handler: test_DCP...",
};

select PoliceSpyFile; 

select list_police_spy_names(morse_code_of_undercover); # {Json("{\"names\": [\"陳永仁\"]}")}
select list_police_spy_names("abc"); # {Json("{\"names\": []}")}

update PoliceSpyFile filter .classified_info="Handler: test_DCP..."
set {
    classified_info:= .classified_info ++ "..."
};

delete PoliceSpyFile;


insert ChenLauContact {
    how:= "電話",
    detail:= "黃sir殉職後，建明以黃sir手機聯絡永仁",
    `when`:= assert_single((select FuzzyTime filter .fuzzy_fmt="2002/11/23_HH24:MI:SS_ID")),
    where:= police_station union (insert Location {name:= "電車站"}),
};


insert ChenLauContact {
    how:= "面對面",
    detail:= "建明擊斃韓琛後，終於在警局與永仁見面，並確認其臥底身份。",
    `when`:= assert_single((select FuzzyTime filter .fuzzy_fmt="2002/11/23_HH24:MI:SS_ID")),
    where:= police_station,
};

insert Scene {
      title:= "真相大白", 
      detail:= "建明得知黃sir將與警方臥底於大廈見面，通知韓琛。韓琛一面派" ++
               "手下到大廈，一面進行毒品交易。黃sir為掩護永仁離開，被韓琛" ++
               "手下丟下樓，寧願殉職而不發一言。黃sir死後，建明聯手永仁於" ++
               "停車場擊斃韓琛，最終兩人於警察局見面。當建明正幫永仁處理臥" ++
               "底檔案時，永仁發現其親手所寫帶有「標」字的信封竟然在建明桌上，" ++
               "醒悟原來建明就是韓琛派至警隊的臥底，立即悄然離開。",
      who:= (select Gangster filter .nickname in {"迪路", "傻強"}) union {wong, chen, hon, lau},
      `when`:= assert_single((select FuzzyTime filter .fuzzy_fmt="2002/11/23_HH24:MI:SS_ID")),
      where:=  (select Location filter .name in {"天台", "電車站"}) union 
               police_station union
               (select(insert Location {name:="停車場"})),         
};

delete Police filter .name="test_DCP";

reset global current_user_id;
