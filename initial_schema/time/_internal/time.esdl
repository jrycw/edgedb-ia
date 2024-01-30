module default {

    # ========== scalar types ========== 
    # --8<-- [start:scalar_type_DayOfWeek]
    scalar type DayOfWeek extending enum<Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday>;
    # --8<-- [end:scalar_type_DayOfWeek]

    # --8<-- [start:scalar_type_FuzzyYear]
    scalar type FuzzyYear extending int64;
    # --8<-- [end:scalar_type_FuzzyYear]

    # --8<-- [start:scalar_type_FuzzyMonth]
    scalar type FuzzyMonth extending int64 {
        constraint expression on (__subject__ >=1 and __subject__ <=12)
    }
    # --8<-- [end:scalar_type_FuzzyMonth]

    # --8<-- [start:scalar_type_FuzzyDay]
    scalar type FuzzyDay extending int64 {
        constraint expression on (__subject__ >=1 and __subject__ <=31)
    }
    # --8<-- [end:scalar_type_FuzzyDay]

    # --8<-- [start:scalar_type_FuzzyHour]
    scalar type FuzzyHour extending int64 {
        constraint expression on (__subject__ >=0 and __subject__ <=23)
    }
    # --8<-- [end:scalar_type_FuzzyHour]

    # --8<-- [start:scalar_type_FuzzyMinute]
    scalar type FuzzyMinute extending int64 {
        constraint expression on (__subject__ >=0 and __subject__ <=59)
    }
    # --8<-- [end:scalar_type_FuzzyMinute]

    # --8<-- [start:scalar_type_FuzzySecond]
    scalar type FuzzySecond extending int64 {
        constraint expression on (__subject__ >=0 and __subject__ <=59)
    }
    # --8<-- [end:scalar_type_FuzzySecond]

    # ========== object types ========== 
    # --8<-- [start:object_type_FuzzyTime]
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
    # --8<-- [end:object_type_FuzzyTime]

}
