# scalar types
scalar type DayOfWeek extending enum<Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday>;
scalar type FuzzyYear extending int64;
scalar type FuzzyMonth extending int64 {constraint expression on (__subject__ >=1 and __subject__ <=12)}
scalar type FuzzyDay extending int64 {constraint expression on (__subject__ >=1 and __subject__ <=31)}
scalar type FuzzyHour extending int64 {constraint expression on (__subject__ >=0 and __subject__ <=23)}
scalar type FuzzyMinute extending int64 {constraint expression on (__subject__ >=0 and __subject__ <=59)}
scalar type FuzzySecond extending int64 {constraint expression on (__subject__ >=0 and __subject__ <=59)}


# object types
type FuzzyTime {
    fuzzy_year: FuzzyYear;
    fuzzy_month: FuzzyMonth;
    fuzzy_day: FuzzyDay;
    fuzzy_hour: FuzzyHour;
    fuzzy_minute: FuzzyMinute;
    fuzzy_second: FuzzySecond;
    fuzzy_dow: DayOfWeek; 
    fuzzy_fmt:= (
        with Y:= <str>.fuzzy_year ?? "YYYY",
                m:= <str>.fuzzy_month ?? "MM",
                m:= m if len(m) > 1 else "0" ++ m,
                d:= <str>.fuzzy_day ?? "DD",
                d:= d if len(d) > 1 else "0" ++ d,
                H:= <str>.fuzzy_hour ?? "HH24",
                H:= H if len(H) > 1 else "0" ++ H,
                M:= <str>.fuzzy_minute ?? "MI",
                M:= M if len(M) > 1 else "0" ++ M,
                S:= <str>.fuzzy_second ?? "SS",
                S:= S if len(S) > 1 else "0" ++ S,
                dow:= <str>.fuzzy_dow ?? "ID", 
        select Y ++ "/" ++ m ++ "/" ++ d ++ "_" ++
                H ++ ":" ++ M ++ ":" ++ S ++ "_" ++
                dow       
    );

    trigger fuzzy_month_day_check after insert, update for each 
    when (exists __new__.fuzzy_month and exists __new__.fuzzy_day) 
    do ( 
        assert_exists(
            cal::to_local_date(__new__.fuzzy_year ?? 2002, __new__.fuzzy_month, __new__.fuzzy_day),
            ) 
    );
    constraint exclusive on (.fuzzy_fmt);
}


