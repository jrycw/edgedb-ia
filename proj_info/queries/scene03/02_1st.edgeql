select test_alias();

update lau set { 
    police_rank:= PoliceRank.PC
};

insert ChenLauContact {
    how:= "面對面",
    detail:= "建明逮捕永仁並在警局替其做筆錄。",
    `when`:= year_1994,
    where:= police_station,
};