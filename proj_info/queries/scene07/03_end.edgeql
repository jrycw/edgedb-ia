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
