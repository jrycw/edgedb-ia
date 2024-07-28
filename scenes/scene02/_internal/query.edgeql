# --8<-- [start:insert_chen]
insert PoliceSpy {
      name:="陳永仁",
      nickname:= "仁哥",
      gangster_boss:= hon,
      actors := (insert Actor {
                  name:= "余文樂",
                  eng_name:= "Shawn",
                  nickname:= "六叔",
      }),
};
# --8<-- [end:insert_chen]

# --8<-- [start:insert_wong]
insert Police {
      name:= "黃志誠",
      nickname:= "黃sir",
      police_rank:= PoliceRank.SIP, 
      actors := (insert Actor {
                  name:= "黃秋生",
                  eng_name:= "Anthony",
                  nickname:= "大飛哥",
      }),
};
# --8<-- [end:insert_wong]

# --8<-- [start:test_alias]
select test_alias();
# --8<-- [end:test_alias]

# --8<-- [start:insert_chenlaucontact]
insert ChenLauContact {
      how:= "面對面",
      detail:= "永仁假裝鬧事被趕出警校時，與建明在門口有一面之緣。",
      `when`:= year_1992,
      where:= (insert Landmark {name:= "警校"}),
};
# --8<-- [end:insert_chenlaucontact]

# --8<-- [start:insert_scene]
insert Scene {
      title:= "我想跟他換",
      detail:= "葉校長與黃sir準備於警校新生中，挑選適合的新人臥底至黑社會。" ++
               "永仁天資優異，觀察入微，為臥底的不二人選。兩人指示永仁假裝鬧" ++
               "事並趁機將其趕出警校，而建明此時剛好入學，看著永仁背影喃喃自" ++
               "語道：「我想跟他換」。或許建明從一開始就真的想做個好人？",
      remarks:= "1.假設黃Sir於1992年官階為`SIP`。",     
      who:= {wong, chen, lau},
      `when`:= year_1992,
      where:= (select Landmark filter .name="警校"),    
};
# --8<-- [end:insert_scene]