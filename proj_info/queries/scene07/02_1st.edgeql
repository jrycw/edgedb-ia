insert Store {name:="龍鼓灘"};

insert Beverage {
    name:= "熱奶茶",
    produced_by:= assert_single((select Store filter .name="龍鼓灘")),
    consumed_by:= lau,
    `when`:= (insert FuzzyTime {fuzzy_hour:=15, fuzzy_minute:=15}), #三點三
    where:= police_station,
};

insert Beverage {
    name:= "綠茶",
    consumed_by:= lau,
    `when`:= (insert FuzzyTime {fuzzy_hour:=20, fuzzy_minute:=15}),
    where:= assert_single((select Location filter .name="大廈三樓")),
};

insert Beverage {
    name:= "凍檸茶",
    produced_by:= assert_single((select Store filter .name="龍鼓灘")),
    consumed_by:= hon,
    `when`:= (insert FuzzyTime {fuzzy_hour:=23, fuzzy_minute:=15}),
    where:= police_station,
};

select Beverage {name} filter .consumed_by=lau;

select lau {name, nickname, beverages:= .<consumed_by[is Beverage] {name}};

select lau {name, nickname, beverages:= .<consumed_by[is Beverage] {name, where : {name}}};