#=================01=================
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

select test_alias();

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


#=================02=================
insert PoliceSpy {
      name:="陳永仁",
      nickname:= "仁哥",
      gangster_boss:= hon,
      actors := (insert Actor {
                  name:= "余文樂",
                  eng_name:= "Shawn",
                  nickname:= "六叔",
      }),
};

insert Police {
      name:= "黃志誠",
      nickname:= "黃sir",
      police_rank:= PoliceRank.SIP, 
      actors := (insert Actor {
                  name:= "黃秋生",
                  eng_name:= "Anthony",
                  nickname:= "大飛哥",
      }),
};

select test_alias();

insert ChenLauContact {
      how:= "面對面",
      detail:= "永仁假裝鬧事被趕出警校時，與建明在門口有一面之緣。",
      `when`:= year_1992,
      where:= (insert Landmark {name:= "警校"}),
};

insert Scene {
      title:= "我想跟他換",
      detail:= "葉校長與黃sir準備於警校新生中，挑選適合的新人臥底至黑社會。" ++
               "永仁天資優異，觀察入微，為臥底的不二人選。兩人指示永仁假裝鬧" ++
               "事並趁機將其趕出警校，而建明此時剛好入學，看著永仁背影喃喃自" ++
               "語道：「我想跟他換」。或許建明從一開始就真的想做個好人？",
      remarks:= "1.假設黃Sir於1992年官階為`SIP`。",     
      who:= {wong, chen, lau},
      `when`:= year_1992,
      where:= (select Landmark filter .name="警校"),    
};


#=================03=================
insert FuzzyTime {fuzzy_year:= 1994};

insert Landmark {name:= "警察局"};

select test_alias();

update lau set { 
    police_rank:= PoliceRank.PC
};

insert ChenLauContact {
    how:= "面對面",
    detail:= "建明逮捕永仁並在警局替其做筆錄。",
    `when`:= year_1994,
    where:= police_station,
};

with records:= {("CCR9314768", "OFFNCE: A.O.A.B.H   "), ("RN992317", "CD-POD   ")},
for record in records
union (insert CriminalRecord {
                ref_no:= record.0, 
                code:= record.1,
                involved:= chen,
});



select CriminalRecord {**};

for record in CriminalRecord
union (
    update record
    set {
        code:= str_trim_end(.code)
    }
);

select CriminalRecord {**};

select chen {criminal_records:= .<involved[is CriminalRecord] {**}};

select Character {name, criminal_records:= .<involved[is CriminalRecord] {**}};

insert Scene {
      title:= "黑白顛倒",
      detail:= "永仁留下多次案底，並曾經被建明逮捕，但也逐漸取得黑社會的信任。" ++
               "建明畢業後則由警員（PC）做起，表現優異，獲面試晉陞見習督察（PI）" ++
               "的機會。兩人的路就像黑白顛倒一般，誰是好人，誰又是壞人呢？",
      remarks:= "1.假設此時為1994年。",       
      who:= {chen, lau},
      `when`:= year_1994,
      where:= police_station,  
};


#=================04=================
insert FuzzyTime {fuzzy_year:= 2002, fuzzy_month:=11, fuzzy_day:=28};

insert Store {name:="Hi-Fi鋪"};

update lau 
set {
    actors+= (insert Actor {
            name:="劉德華",
            eng_name:= "Andy",
            nickname:= "華仔",
   })
};

update chen 
set {
    classic_lines := ["高音甜、中音準、低音勁。一句講哂，通透啦即係。"],
    actors+= (insert Actor {
            name:="梁朝偉",
            eng_name:= "Tony",
            nickname:= "偉仔",
   })
};

insert ChenLauContact {
    how:= "面對面",
    detail:= "臥底近十年後，建明與永仁在Hi-Fi鋪相遇，一起試聽了`被遺忘的時光", 
    `when`:=  assert_single((select FuzzyTime filter .fuzzy_fmt="2002/11/28_HH24:MI:SS_ID")),
    where:= assert_single((select Store filter .name="Hi-Fi鋪")),
};

select test_hi_fi_store_open(); # {true}

select test_hi_fi_store_close(); # {true}

insert Scene {
    title:= "被遺忘的時光",
    detail:= "臥底近十年後，建明與永仁在Hi-Fi鋪相遇。建明請永仁推薦設備，並一起" ++
             "試聽了`被遺忘的時光`。試聽過程中，建明請永仁換了一條音源線，歌聲立" ++
             "刻變得更加立體，好像真人就在眼前唱歌一般，畢竟這首歌建明聽過太多次，" ++
             "有太多懷念的過去（詳情請見無間道Ⅱ）。",
    remarks:= "簽單日期為2002/11/28", 
    who:= {chen, lau},
    `when`:=  assert_single((select FuzzyTime filter .fuzzy_fmt="2002/11/28_HH24:MI:SS_ID")),
    where:= assert_single((select Store filter .name="Hi-Fi鋪")),         
};


#=================05=================
insert FuzzyTime {fuzzy_year:= 2002};

select test_alias();

update chen 
set {
    classic_lines := .classic_lines ++ 
            ["你話三年。三年之後又三年，三年之後又三年！十年都嚟緊頭啦老細！",
             "收嗲啦！呢句嘢我聽咗九千幾次啦！"],
};

update wong 
set {
    classic_lines := ["你25號生日嘛!25仔!"],
};

select <datetime>"1992-12-01T00:00:00+08";
select to_datetime("1992-12-01T00:00:00+08");
select to_datetime(1992, 12, 1, 0, 0, 0, "Asia/hong_kong");
select to_datetime(<cal::local_datetime>"1992-12-01T00:00:00", "Asia/hong_kong");

select <cal::relative_duration>"9 years 10 months";

select <datetime>"1992-12-01T00:00:00+08" + <cal::relative_duration>"9 years 10 months";

with t:=(select <datetime>"1992-12-01T00:00:00+08" + <cal::relative_duration>"9 years 10 months")
select cal::to_local_datetime(t, "Asia/hong_kong");

select <cal::local_datetime>"1992-12-01T00:00:00" + <cal::relative_duration>"9 years 10 months";

select <cal::local_date>"2002-10-25" - <cal::local_date>"2002-10-01";

insert Scene {
      title:= "三年之後又三年",
      detail:= "永仁與黃sir相約於天台交換情報，韓琛將於這星期進行毒品" ++
               "交易，地點未知。黃sir則說他費盡心力將永仁傷人的案子由" ++
               "坐牢改成看心理醫生，交待永仁要照做。永仁抱怨自己被黃sir" ++
               "騙了，說好只當三年臥底，結果現在都快十年了，不知道何時才" ++
               "能恢復警察身份。十年間發生了太多事，永仁看著黃sir送的手錶" ++
               "，他有時候真的不知道該用什麼心態面對黃sir（詳情請見無間道Ⅱ" ++
               "及無間道Ⅲ）。",
      who:= {wong, chen},
      `when`:= year_2002,
      where:= (insert Location {name:="天台"}),         
};


#=================06=================
insert Location {name:="大廈三樓"};

update wong 
set {
    police_rank:= PoliceRank.SP,
    dept:= "有組織罪案及三合會調查科(O記)",
};

for i in range_unpack(range(1, 11))
union (
    insert Police {
        name:=  "police_" ++ <str>i,
        dept:= "有組織罪案及三合會調查科(O記)",
        police_rank:= PoliceRank.SPC,
    }
);

update lau 
set {
    police_rank:= PoliceRank.SIP,
    dept:= "刑事情報科(CIB)",
};

insert Police{
    name:= "林國平",
    nickname:="大B",
    police_rank:= PoliceRank.SSGT,
    dept:= "刑事情報科(CIB)",
    actors:= (
        insert Actor{
            name:= "林家棟",
            eng_name:= "Gordon",
        }
    )
};

for name in {"大象", "孖八"}
union (
    insert Police {
        name:= name,
        nickname:= name,
        dept:= "刑事情報科(CIB)",
        police_rank:= PoliceRank.SGT,
    }
);

for i in range_unpack(range(11, 14))
union (
    insert Police {
        name:=  "police_" ++ <str>i,
        dept:= "刑事情報科(CIB)",
        police_rank:= PoliceRank.SPC,
    }
);

insert Gangster {
    name:= "迪比亞路",
    nickname:= "迪路",
    gangster_boss:= hon,
    gangster_rank:= GangsterRank.Leader,
    actors:= (insert Actor {
        name:= "林迪安", 
        eng_name:="Dion",
    }),
};

insert Gangster {
    name:= "徐偉強",
    nickname:= "傻強",
    gangster_boss:= hon,
    gangster_rank:= GangsterRank.Leader,
    actors:= (insert Actor {
        name:= "杜汶澤", 
        eng_name:= "Edward",
    }),
};

for i in range_unpack(range(1, 11))
union (
    insert Gangster {
        name:=  "gangster_" ++ <str>i,
        gangster_boss:= hon,
        gangster_rank:= GangsterRank.Nobody,
    }
);

for loc in {"葵涌碼頭", "三號幹線", "龍鼓灘"}
union (
    insert Landmark{
        name:= loc,
    }
);

insert ChenLauContact {
    how:= "面對面",
    detail:= "黃sir帶隊進入韓琛毒品交易現場",
    `when`:= year_2002,
    where:= assert_single((select Location filter .name="大廈三樓")),
};

with p:= Police union PoliceSpy union GangsterSpy,
     g:= (group p by .police_rank),
select g {**};

with p:= Police union PoliceSpy union GangsterSpy,
     g:= (group p by .police_rank),
select g {police_rank:= .key.police_rank, 
          counts:= count(.elements)}
order by .police_rank desc;

with g:= (group Place 
          using name_length:= len(.name)
          by name_length),
select g {name_length:= .key.name_length ,
          counts:= count(.elements),
          names:= .elements.name}
order by .name_length desc;

with g:= (group Place 
          using name_length:= len(.name)
          by name_length),
select g {name_length:= .key.name_length ,
          counts:= count(.elements),
          names:= .elements.name}
order by .counts desc;

with policemen:= (select Police filter .dept in {"有組織罪案及三合會調查科(O記)", "刑事情報科(CIB)"}),
     gangsters:= (select Gangster filter .gangster_boss=hon)
insert Scene {
      title:= "有內鬼終止交易",
      detail:= "O記聯合CIB準備於今晚韓琛與泰國佬交易可卡因（古柯鹼）時，來個" ++
               "人贓並獲。建明知道後，假裝打電話給家人，通知韓琛。韓琛一直監" ++
               "聽警方頻道，並指示迪路和傻強四處亂晃，不要前往交易地點。過程中，" ++
               "永仁一直以摩斯密碼與黃sir聯絡。黃sir在得知韓琛監聽頻道後，隨即" ++
               "轉換頻道，並使用舊頻道發出今晚行動取消的指令。韓琛信以為真，指示" ++
               "迪路和傻強可以前往龍鼓灘交易。正當交易完成，黃sir準備先逮捕迪路" ++
               "和傻強將毒品扣下，再衝進屋逮捕韓琛之際，建仁使用簡訊傳送「有內鬼，" ++
               "終止交易」到韓琛所在位置附近的所有手機。",
      who:= policemen union gangsters union {chen, lau, hon},
      `when`:= year_2002,
      where:= (select Place filter .name="大廈三樓" or .name="龍鼓灘"),         
      remarks:= "1.假設國平官階為`SSGT`，大象與孖八官階為`SGT`。"  
};


#=================07=================
insert Store {name:="龍鼓灘"};

insert Beverage {
    name:= "熱奶茶",
    produced_by:= assert_single((select Store filter .name="龍鼓灘")),
    consumed_by:= lau,
    `when`:= (insert FuzzyTime {fuzzy_hour:=15, fuzzy_minute:=15}), #三點三
    where:= police_station,
};

insert Beverage {
    name:= "綠茶",
    consumed_by:= lau,
    `when`:= (insert FuzzyTime {fuzzy_hour:=20, fuzzy_minute:=15}),
    where:= assert_single((select Location filter .name="大廈三樓")),
};

insert Beverage {
    name:= "凍檸茶",
    produced_by:= assert_single((select Store filter .name="龍鼓灘")),
    consumed_by:= hon,
    `when`:= (insert FuzzyTime {fuzzy_hour:=23, fuzzy_minute:=15}),
    where:= police_station,
};

select Beverage {name} filter .consumed_by=lau;

select lau {name, nickname, beverages:= .<consumed_by[is Beverage] {name}};

select lau {name, nickname, beverages:= .<consumed_by[is Beverage] {name, where : {name}}};

select(insert CIBTeamTreat).team_treat;

select(insert CIBTeamTreat) {team_treat_number, team_treat, points:= .colleagues@point};

select(insert CIBTeamTreat) {team_treat_number, team_treat, colleagues: {name, @point}};

update hon 
set {
    classic_lines := .classic_lines ++  ["你見過有人去殯儀館和屍體握手嗎?"],
};

insert ChenLauContact {
    how:= "面對面",
    detail:= "毒品被韓琛手下迪路與傻強銷毀，永仁隨韓琛一起被帶回警察局",
    `when`:= year_2002,
    where:= police_station,
};

insert Scene {
      title:= "互猜底牌",
      detail:= "韓琛千鈞一髮之際收到建明簡訊，緊急打給迪路與傻強，將與" ++
               "泰國佬交易的可卡因丟進海裡。黃sir見行動失敗，只得暫時" ++
               "將韓琛及其手下帶回警察局。回警察局後，黃sir確認證據不" ++
               "足以起訴韓琛後，帶隊來到韓琛用餐的房間。黃sir藉機嘲諷" ++
               "韓琛，雖然這次無法逮捕他，但以令他損受幾千萬。韓琛聽" ++
               "後，瞬間翻臉將桌上食物往黃sir座位掃去。兩人言談間針鋒" ++
               "相對，互相猜測著對方安排在己方的臥底是誰。最後，韓琛囂" ++
               "張地帶著手下們大步離去。",
      who:= (select Gangster filter .nickname in {"迪路", "傻強"}) union {wong, chen, hon, lau},
      `when`:= year_2002,
      where:= police_station,
      remarks:= "1.假設建明喝綠茶時間為20:15。\n2.假設韓琛於23:15喝凍檸茶。"         
};


#=================08=================
insert Envelope;

update lau 
set {
    dept:= "投訴及內部調查科", 
};

with names:= array_join(array_agg(Police.name), " "), 
       module ext::pg_trgm,
select word_similar("陳永仁", names);

with names:= array_join(array_agg(Police.name), " "), 
       module ext::pg_trgm,
select word_similarity("陳永仁", names);

with names:= array_join(array_agg(Police.name union PoliceSpy.name), " "), 
     module ext::pg_trgm,
select word_similar("陳永仁", names);

with names:= array_join(array_agg(Police.name union PoliceSpy.name), " "), 
     module ext::pg_trgm,
select word_similarity("陳永仁", names);

with names:= array_join(array_agg(Police.name union PoliceSpy.name), " "), 
     module ext::pg_trgm,
select word_similarity("陳永仨", names);

insert Scene {
      title:= "誰是內鬼", 
      detail:= "毒品交易失敗後，韓琛確信身邊有警察臥底。依照建明要求，" ++
               "將所有小弟的個人資料裝在信封中，於電影院L13位置交給建" ++
               "明。永仁偷偷在後觀察並尾隨建明離開，欲看清其模樣，不料" ++
               "手機突然響起，因而錯失良機。而建明也隱約感覺到有人跟蹤，" ++
               "隱於牆後查看但未發現人跡。另一方面，警隊高層也懷疑韓琛" ++
               "安插了臥底，於是將建明調至內務部並在O記辦公，專門調查此" ++
               "事。建明依照韓琛所給資料於警隊資料庫中進行搜尋，卻無發現" ++
               "。於此同時，韓琛試探了身邊所有小弟，包括永仁與傻強...",
      who:= {hon, chen, lau},
      `when`:= (insert FuzzyTime {
                     fuzzy_year:= 2002,
                     fuzzy_month:= 11,
                     fuzzy_day:= 23,
              }),
      where:= police_station union (insert Location {name:="電影院"}),         
};


#=================09=================
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


#=================10=================
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


with one_dcp:= (select Police filter .police_rank=PoliceRank.DCP limit 1)
select if exists one_dcp then {
    (select one_dcp.id)
} else {
    (select (select (insert Police {name:= "test_DCP", police_rank:=PoliceRank.DCP})).id)
};

set global current_user_id:= (select Police filter .police_rank=PoliceRank.DCP limit 1).id;



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


