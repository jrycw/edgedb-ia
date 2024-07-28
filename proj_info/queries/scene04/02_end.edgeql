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