# --8<-- [start:insert_year_2002]
insert FuzzyTime {fuzzy_year:= 2002};
# --8<-- [end:insert_year_2002]

# --8<-- [start:test_alias]
select test_alias();
# --8<-- [end:test_alias]

# --8<-- [start:update_chen]
update chen 
set {
    classic_lines := .classic_lines ++ 
            ["你話三年。三年之後又三年，三年之後又三年！十年都嚟緊頭啦老細！",
             "收嗲啦！呢句嘢我聽咗九千幾次啦！"],
};
# --8<-- [end:update_chen]

# --8<-- [start:update_wong]
update wong 
set {
    classic_lines := ["你25號生日嘛!25仔!"],
};
# --8<-- [end:update_wong]

# --8<-- [start:datetime_creation]
select <datetime>"1992-12-01T00:00:00+08";
select to_datetime("1992-12-01T00:00:00+08");
select to_datetime(1992, 12, 1, 0, 0, 0, "Asia/hong_kong");
select to_datetime(<cal::local_datetime>"1992-12-01T00:00:00", "Asia/hong_kong");
# --8<-- [end:datetime_creation]

# --8<-- [start:relative_duration_creation]
select <cal::relative_duration>"9 years 10 months";
# --8<-- [end:relative_duration_creation]

# --8<-- [start:datetime_result]
select <datetime>"1992-12-01T00:00:00+08" + <cal::relative_duration>"9 years 10 months";
# --8<-- [end:datetime_result]

# --8<-- [start:datetime_result_local]
with t:=(select <datetime>"1992-12-01T00:00:00+08" + <cal::relative_duration>"9 years 10 months")
select cal::to_local_datetime(t, "Asia/hong_kong");
# --8<-- [end:datetime_result_local]

# --8<-- [start:local_datetime_result]
select <cal::local_datetime>"1992-12-01T00:00:00" + <cal::relative_duration>"9 years 10 months";
# --8<-- [end:local_datetime_result]

# --8<-- [start:cal_bday_diff]
select <cal::local_date>"2002-10-25" - <cal::local_date>"2002-10-01";
# --8<-- [end:cal_bday_diff]

# --8<-- [start:insert_scene]
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
# --8<-- [end:insert_scene]