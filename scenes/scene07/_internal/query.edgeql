# --8<-- [start:insert_store_but_having_same_name_as_landmark]
insert Store {name:="龍鼓灘"};
# --8<-- [end:insert_store_but_having_same_name_as_landmark]

# --8<-- [start:insert_hot_milk_tea]
insert Beverage {
    name:= "熱奶茶",
    produced_by:= assert_single((select Store filter .name="龍鼓灘")),
    consumed_by:= lau,
    `when`:= (insert FuzzyTime {fuzzy_hour:=15, fuzzy_minute:=15}), #三點三
    where:= police_station,
};
# --8<-- [end:insert_hot_milk_tea]

# --8<-- [start:insert_green_tea]
insert Beverage {
    name:= "綠茶",
    consumed_by:= lau,
    `when`:= (insert FuzzyTime {fuzzy_hour:=20, fuzzy_minute:=15}),
    where:= assert_single((select Location filter .name="大廈三樓")),
};
# --8<-- [end:insert_green_tea]

# --8<-- [start:insert_iced_lemon_tea]
insert Beverage {
    name:= "凍檸茶",
    produced_by:= assert_single((select Store filter .name="龍鼓灘")),
    consumed_by:= hon,
    `when`:= (insert FuzzyTime {fuzzy_hour:=23, fuzzy_minute:=15}),
    where:= police_station,
};
# --8<-- [end:insert_iced_lemon_tea]

# --8<-- [start:select_Beverage_and_filter]
select Beverage {name} filter .consumed_by=lau;
# --8<-- [end:select_Beverage_and_filter]

# --8<-- [start:Beverage_backlinks1]
select lau {name, nickname, beverages:= .<consumed_by[is Beverage] {name}};
# --8<-- [end:Beverage_backlinks1]

# --8<-- [start:Beverage_backlinks2]
select lau {name, nickname, beverages:= .<consumed_by[is Beverage] {name, where : {name}}};
# --8<-- [end:Beverage_backlinks2]

# --8<-- [start:CIBTeamTreat1]
select(insert CIBTeamTreat).team_treat;
# --8<-- [end:CIBTeamTreat1]

# --8<-- [start:CIBTeamTreat2]
select(insert CIBTeamTreat) {team_treat_number, team_treat, points:= .colleagues@point};
# --8<-- [end:CIBTeamTreat2]

# --8<-- [start:CIBTeamTreat3]
select(insert CIBTeamTreat) {team_treat_number, team_treat, colleagues: {name, @point}};
# --8<-- [end:CIBTeamTreat3]

# --8<-- [start:update_hon]
update hon 
set {
    classic_lines := .classic_lines ++  ["你見過有人去殯儀館和屍體握手嗎?"],
};
# --8<-- [end:update_hon]

# --8<-- [start:insert_chenlaucontact]
insert ChenLauContact {
    how:= "面對面",
    detail:= "毒品被韓琛手下迪路與傻強銷毀，永仁隨韓琛一起被帶回警察局",
    `when`:= year_2002,
    where:= police_station,
};
# --8<-- [end:insert_chenlaucontact]

# --8<-- [start:insert_scene]
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
# --8<-- [end:insert_scene]