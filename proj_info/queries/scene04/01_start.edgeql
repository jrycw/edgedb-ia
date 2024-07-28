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
