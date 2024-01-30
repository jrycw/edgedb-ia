# --8<-- [start:insert_building_3f]
insert Location {name:="大廈三樓"};
# --8<-- [end:insert_building_3f]

# --8<-- [start:update_wong]
update wong 
set {
    police_rank:= PoliceRank.SP,
    dept:= "有組織罪案及三合會調查科(O記)",
};
# --8<-- [end:update_wong]

# --8<-- [start:insert_policemen1]
for i in range_unpack(range(1, 11))
union (
    insert Police {
        name:=  "police_" ++ <str>i,
        dept:= "有組織罪案及三合會調查科(O記)",
        police_rank:= PoliceRank.SPC,
    }
);
# --8<-- [end:insert_policemen1]

# --8<-- [start:update_lau]
update lau 
set {
    police_rank:= PoliceRank.SIP,
    dept:= "刑事情報科(CIB)",
};
# --8<-- [end:update_lau]

# --8<-- [start:insert_big_b]
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
# --8<-- [end:insert_big_b]

# --8<-- [start:insert_2_SGT]
for name in {"大象", "孖八"}
union (
    insert Police {
        name:= name,
        nickname:= name,
        dept:= "刑事情報科(CIB)",
        police_rank:= PoliceRank.SGT,
    }
);
# --8<-- [end:insert_2_SGT]

# --8<-- [start:insert_policemen2]
for i in range_unpack(range(11, 14))
union (
    insert Police {
        name:=  "police_" ++ <str>i,
        dept:= "刑事情報科(CIB)",
        police_rank:= PoliceRank.SPC,
    }
);
# --8<-- [end:insert_policemen2]

# --8<-- [start:insert_gangster_leader1]
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
# --8<-- [end:insert_gangster_leader1]

# --8<-- [start:insert_gangster_leader2]
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
# --8<-- [end:insert_gangster_leader2]

# --8<-- [start:insert_gangsters]
for i in range_unpack(range(1, 11))
union (
    insert Gangster {
        name:=  "gangster_" ++ <str>i,
        gangster_boss:= hon,
        gangster_rank:= GangsterRank.Nobody,
    }
);
# --8<-- [end:insert_gangsters]

# --8<-- [start:for_loop_insert_landmark]
for loc in {"葵涌碼頭", "三號幹線", "龍鼓灘"}
union (
    insert Landmark{
        name:= loc,
    }
);
# --8<-- [end:for_loop_insert_landmark]

# --8<-- [start:insert_chenlaucontact]
insert ChenLauContact {
    how:= "面對面",
    detail:= "黃sir帶隊進入韓琛毒品交易現場",
    `when`:= year_2002,
    where:= assert_single((select Location filter .name="大廈三樓")),
};
# --8<-- [end:insert_chenlaucontact]

# --8<-- [start:group_police_rank1]
with p:= Police union PoliceSpy union GangsterSpy,
     g:= (group p by .police_rank),
select g {**};
# --8<-- [end:group_police_rank1]

# --8<-- [start:group_police_rank2]
with p:= Police union PoliceSpy union GangsterSpy,
     g:= (group p by .police_rank),
select g {police_rank:= .key.police_rank, 
          counts:= count(.elements)}
order by .police_rank desc;
# --8<-- [end:group_police_rank2]

# --8<-- [start:group_place_1]
with g:= (group Place 
          using name_length:= len(.name)
          by name_length),
select g {name_length:= .key.name_length ,
          counts:= count(.elements),
          names:= .elements.name}
order by .name_length desc;
# --8<-- [end:group_place_1]

# --8<-- [start:group_place_2]
with g:= (group Place 
          using name_length:= len(.name)
          by name_length),
select g {name_length:= .key.name_length ,
          counts:= count(.elements),
          names:= .elements.name}
order by .counts desc;
# --8<-- [end:group_place_2]

# --8<-- [start:insert_scene]
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
# --8<-- [end:insert_scene]