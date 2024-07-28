select test_alias();

insert Scene {
    title:= "韓琛初現",
    detail:= "韓琛準備派遣多個身家較為清白的小弟臥底至香港警隊，包括建明。" ++
             "他向小弟們講述著自己的過去，並說自己不相信算命先生所說的" ++
             "「一將功成萬骨枯」。他認為出來混的，未來的路怎麼走應該由自己決定。",
    remarks:= "1.假設此場景為1992年。",  
    who:= {hon, lau},
    `when`:= year_1992,
    where:= (insert Location {name:= "佛堂"}) ,   
    references:= [("維基百科-無間道", "https://zh.wikipedia.org/zh-tw/%E7%84%A1%E9%96%93%E9%81%93"),
                  ("香港警察職級", "https://zh.wikipedia.org/zh-tw/%E9%A6%99%E6%B8%AF%E8%AD%A6%E5%AF%9F%E8%81%B7%E7%B4%9A")]
};