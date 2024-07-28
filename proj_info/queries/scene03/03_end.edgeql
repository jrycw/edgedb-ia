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