# --8<-- [start:insert_2002_11_28]
insert FuzzyTime {fuzzy_year:= 2002, fuzzy_month:=11, fuzzy_day:=28};
# --8<-- [end:insert_2002_11_28]

# --8<-- [start:insert_hi_fi_store]
insert Store {name:="Hi-Fi鋪"};
# --8<-- [end:insert_hi_fi_store]

# --8<-- [start:update_lau]
update lau 
set {
    actors+= (insert Actor {
            name:="劉德華",
            eng_name:= "Andy",
            nickname:= "華仔",
   })
};
# --8<-- [end:update_lau]

# --8<-- [start:update_chen]
update chen 
set {
    classic_lines := ["高音甜、中音準、低音勁。一句講哂，通透啦即係。"],
    actors+= (insert Actor {
            name:="梁朝偉",
            eng_name:= "Tony",
            nickname:= "偉仔",
   })
};
# --8<-- [end:update_chen]

# --8<-- [start:insert_chenlaucontact]
insert ChenLauContact {
    how:= "面對面",
    detail:= "臥底近十年後，建明與永仁在Hi-Fi鋪相遇，一起試聽了`被遺忘的時光", 
    `when`:=  assert_single((select FuzzyTime filter .fuzzy_fmt="2002/11/28_HH24:MI:SS_ID")),
    where:= assert_single((select Store filter .name="Hi-Fi鋪")),
};
# --8<-- [end:insert_chenlaucontact]

# --8<-- [start:test_hi_fi_store_open]
select test_hi_fi_store_open(); # {true}
# --8<-- [end:test_hi_fi_store_open]

# --8<-- [start:test_hi_fi_store_close]
select test_hi_fi_store_close(); # {true}
# --8<-- [end:test_hi_fi_store_close]

# --8<-- [start:insert_scene]
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
# --8<-- [end:insert_scene]