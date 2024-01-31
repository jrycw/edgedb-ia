# --8<-- [start:insert_envelope]
insert Envelope;
# --8<-- [end:insert_envelope]

# --8<-- [start:update_lau]
update lau 
set {
    dept:= "投訴及內部調查科", 
};
# --8<-- [end:update_lau]

# --8<-- [start:word_similar1]
with names:= array_join(array_agg(Police.name), " "), 
       module ext::pg_trgm,
select word_similar("陳永仁", names);
# --8<-- [end:word_similar1]

# --8<-- [start:word_similarity1]
with names:= array_join(array_agg(Police.name), " "), 
       module ext::pg_trgm,
select word_similarity("陳永仁", names);
# --8<-- [end:word_similarity1]

# --8<-- [start:word_similar2]
with is_police_spy:= (select IsPolice filter .police_rank=PoliceRank.Protected),
     police_spy:= (select PoliceSpy filter .id in is_police_spy.id),
     names:= array_join(array_agg(Police.name union police_spy.name), " "), 
     module ext::pg_trgm,
select word_similar("陳永仁", names);
# --8<-- [end:word_similar2]

# --8<-- [start:word_similarity2]
with is_police_spy:= (select IsPolice filter .police_rank=PoliceRank.Protected),
     police_spy:= (select PoliceSpy filter .id in is_police_spy.id),
     names:= array_join(array_agg(Police.name union police_spy.name), " "), 
     module ext::pg_trgm,
select word_similarity("陳永仁", names);
# --8<-- [end:word_similarity2]

# --8<-- [start:word_similarity3]
with is_police_spy:= (select IsPolice filter .police_rank=PoliceRank.Protected),
     police_spy:= (select PoliceSpy filter .id in is_police_spy.id),
     names:= array_join(array_agg(Police.name union police_spy.name), " "), 
     module ext::pg_trgm,
select word_similarity("陳永仨", names);
# --8<-- [end:word_similarity3]

# --8<-- [start:insert_scene]
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
# --8<-- [end:insert_scene]