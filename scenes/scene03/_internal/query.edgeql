# --8<-- [start:insert_year_1994]
insert FuzzyTime {fuzzy_year:= 1994};
# --8<-- [end:insert_year_1994]

# --8<-- [start:insert_police_station]
insert Landmark {name:= "警察局"};
# --8<-- [end:insert_police_station]

# --8<-- [start:test_alias]
select test_alias();
# --8<-- [end:test_alias]

# --8<-- [start:update_lau]
update lau set { 
    police_rank:= PoliceRank.PC
};
# --8<-- [end:update_lau]

# --8<-- [start:insert_chenlaucontact]
insert ChenLauContact {
    how:= "面對面",
    detail:= "建明逮捕永仁並在警局替其做筆錄。",
    `when`:= year_1994,
    where:= police_station,
};
# --8<-- [end:insert_chenlaucontact]

# --8<-- [start:for_loop_insert_criminalrecord]
with records:= {("CCR9314768", "OFFNCE: A.O.A.B.H   "), ("RN992317", "CD-POD   ")},
for record in records
union (insert CriminalRecord {
                ref_no:= record.0, 
                code:= record.1,
                involved:= chen,
});
# --8<-- [end:for_loop_insert_criminalrecord]

# --8<-- [start:for_loop_insert_criminalrecord2]
# with records:= {(ref_no:= "CCR9314768", code:= "OFFNCE: A.O.A.B.H   "), (ref_no:= "RN992317", code:= "CD-POD   ")},
# for record in records
# union (insert CriminalRecord {
#                 ref_no:= record.ref_no, 
#                 code:= record.code,
#                 involved:= chen,
# });
# --8<-- [end:for_loop_insert_criminalrecord2]

# --8<-- [start:for_loop_insert_criminalrecord_ordered]
# with records:= [("CCR9314768", "OFFNCE: A.O.A.B.H   "), ("RN992317", "CD-POD   ")],
#      record_len:= len(records),
# for i in range_unpack(range(0, record_len))
# union (insert CriminalRecord {
#                 ref_no:= array_get(records, i).0, 
#                 code:= array_get(records, i).1, 
#                 involved:= chen,
# });
# --8<-- [end:for_loop_insert_criminalrecord_ordered]

# --8<-- [start:select_criminalrecord_2stars_1]
select CriminalRecord {**};
# --8<-- [end:select_criminalrecord_2stars_1]

# --8<-- [start:for_loop_update_criminalrecord]
for record in CriminalRecord
union (
    update record
    set {
        code:= str_trim_end(.code)
    }
);
# --8<-- [end:for_loop_update_criminalrecord]

# --8<-- [start:select_criminalrecord_2stars_2]
select CriminalRecord {**};
# --8<-- [end:select_criminalrecord_2stars_2]

# --8<-- [start:criminalrecord_backlink1]
select chen {criminal_records:= .<involved[is CriminalRecord] {**}};
# --8<-- [end:criminalrecord_backlink1]

# --8<-- [start:criminalrecord_backlink2]
select Character {name, criminal_records:= .<involved[is CriminalRecord] {**}};
# --8<-- [end:criminalrecord_backlink2]

# --8<-- [start:insert_scene]
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
# --8<-- [end:insert_scene]