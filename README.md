# edgedb-ia
## 緣起
這個project的概念源自[Easy EdgeDB](https://www.edgedb.com/easy-edgedb)。書內用吸血鬼為主題，帶領讀者一步步跟著故事，使用EdgeDB來模擬，是一份相當好的學習資源。

在閱讀完Easy EdgeDB之後，因為太喜歡這種學習方式，所以我決定找一部很喜歡的電影，[無間道系列第一集](https://zh.wikipedia.org/zh-tw/%E7%84%A1%E9%96%93%E9%81%93)，以類似的技巧來練習EdgeDB。

如果您在尋找EdgeDB的中文教材，相信這個project應該能帶給您些許收獲。

## Initial schema
``` elm
module default {

    # scalar types
    scalar type PoliceRank extending enum<Protected, Cadet, PC, SPC, SGT, SSGT, PI, IP, SIP, CIP,
                                          SP, SSP, CSP, ACP, SACP, DCP, CP>;
    scalar type GangsterRank extending enum<Nobody, Leader, Boss>;
    scalar type DayOfWeek extending enum<Monday, Tuesday, Wednesday, Thursday, Friday,
                                         Saturday, Sunday>;

    scalar type FuzzyYear extending int64;
    scalar type FuzzyMonth extending int64 {
                constraint expression on (__subject__ >=1 and __subject__ <=12)
    }
    scalar type FuzzyDay extending int64 {
                constraint expression on (__subject__ >=1 and __subject__ <=31)
    }
    scalar type FuzzyHour extending int64 {
                constraint expression on (__subject__ >=0 and __subject__ <=23)
    }
    scalar type FuzzyMinute extending int64 {
                constraint expression on (__subject__ >=0 and __subject__ <=59)
    }
    scalar type FuzzySecond extending int64 {
                constraint expression on (__subject__ >=0 and __subject__ <=59)
    }

    scalar type SceneNumber extending sequence;

    # abstract object types
    abstract type Person {
        required name: str;
        nickname: str;
        eng_name: str;
    }

    abstract type IsPolice {
        police_rank: PoliceRank{
            default:= PoliceRank.Cadet;
        };
        dept: str;
        is_officer:= .police_rank >= PoliceRank.PI;
    }

    abstract type IsGangster {
        gangster_rank: GangsterRank {
            default:= GangsterRank.Nobody;
        };
        gangster_boss: GangsterBoss;
    }

    abstract type IsSpy extending IsPolice, IsGangster;

    abstract type Place {
        required name: str {
            delegated constraint exclusive;
        };
    }

    abstract type Event {
        detail: str;
        multi who: Character;
        multi `when`: FuzzyTime;
        multi where: Place;
    }

    # object types
    type Character extending Person {
        classic_lines: array<str>;
        lover: Character;
        multi actors: Actor;
    }

    type Actor extending Person;
    type Police extending Character, IsPolice;
    type Gangster extending Character, IsGangster;

    type GangsterBoss extending Gangster {
        overloaded gangster_rank: GangsterRank {
            default:= GangsterRank.Boss;
            constraint expression on (__subject__ = GangsterRank.Boss);
        };

        # excluding self
        constraint expression on (__subject__ != .gangster_boss) { 
            errmessage := "The boss can't be his/her own boss.";
        }
    }

    type PoliceSpy extending Character, IsSpy;
    type GangsterSpy extending Character, IsSpy;

    type Landmark extending Place;
    type Location extending Place;
    type Store extending Place;

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

    type Scene extending Event {
        title: str;
        remarks: str;
        references: array<tuple<str, str>>;
        required scene_number: SceneNumber {
            constraint exclusive;
            default := sequence_next(introspect SceneNumber);
        }
        index on (.scene_number);
    }

}
```
## Final schema
``` elm
using extension pg_trgm;
using extension pgcrypto;

module default {
    # global types
    global current_user_id: uuid;

    # scalar types
    scalar type PoliceRank extending enum<Protected, Cadet, PC, SPC, SGT, SSGT, PI, IP, SIP, CIP,
                                          SP, SSP, CSP, ACP, SACP, DCP, CP>;
    scalar type GangsterRank extending enum<Nobody, Leader, Boss>;
    scalar type DayOfWeek extending enum<Monday, Tuesday, Wednesday, Thursday, Friday,
                                         Saturday, Sunday>;

    scalar type FuzzyYear extending int64;
    scalar type FuzzyMonth extending int64 {
                constraint expression on (__subject__ >=1 and __subject__ <=12)
    }
    scalar type FuzzyDay extending int64 {
                constraint expression on (__subject__ >=1 and __subject__ <=31)
    }
    scalar type FuzzyHour extending int64 {
                constraint expression on (__subject__ >=0 and __subject__ <=23)
    }
    scalar type FuzzyMinute extending int64 {
                constraint expression on (__subject__ >=0 and __subject__ <=59)
    }
    scalar type FuzzySecond extending int64 {
                constraint expression on (__subject__ >=0 and __subject__ <=59)
    }

    scalar type SceneNumber extending sequence;
    scalar type TeamTreatNumber extending sequence; 

    # abstract object types
    abstract type Person {
        required name: str;
        nickname: str;
        eng_name: str;
    }

    abstract type IsPolice {
        police_rank: PoliceRank{
            default:= PoliceRank.Cadet;
        };
        dept: str;
        is_officer:= .police_rank >= PoliceRank.PI;
    }
    
    abstract type IsGangster {
        gangster_rank: GangsterRank {
            default:= GangsterRank.Nobody;
        };
        gangster_boss: GangsterBoss;
    }

    abstract type IsSpy extending IsPolice, IsGangster;

    abstract type Place {
        required name: str {
            delegated constraint exclusive;
        };
    }

    abstract type Event {
        detail: str;
        multi who: Character;
        multi `when`: FuzzyTime;
        multi where: Place;
    }

    abstract type Archive;

    # object types
    type Envelope {
        name: str {
            default:= "標";
            readonly:= true
        };
        access policy allow_select_insert_delete
            allow select, insert, delete;

        access policy only_one_envelope_exists
            deny insert
            using (exists Envelope)
            {
                errmessage := 'Only one Envelope can be existed.'
            };
    }

    type Beverage {
        required name: str;
        produced_by: Store;
        consumed_by: Character;
        `when`: FuzzyTime;
        where: Place;
    }

    type CIBTeamTreat {
        required team_treat_number: TeamTreatNumber {
            constraint exclusive;
            default := sequence_next(introspect TeamTreatNumber);
        }
        multi colleagues: Police {
            default:= (select Police filter .dept="刑事情報科(CIB)");
            readonly := true;
            point: int64 {
                default:= <int64>math::ceil(random()*10)
            }
        };
        team_treat:= max(.colleagues@point) >= 9
    }

    type Character extending Person {
        classic_lines: array<str>;
        multi lovers: Character;
        multi actors: Actor;
    }

    type Actor extending Person;
    type Police extending Character, IsPolice;
    type Gangster extending Character, IsGangster;

    type GangsterBoss extending Gangster {
        overloaded gangster_rank: GangsterRank {
            default:= GangsterRank.Boss;
            constraint expression on (__subject__ = GangsterRank.Boss);
        };

        # excluding self
        constraint expression on (__subject__ != .gangster_boss) { 
            errmessage := "The boss can't be his/her own boss.";
        }
    }

    type PoliceSpy extending Character, IsSpy {
        access policy authorized_allow_insert_update_delete
            allow insert, update, delete
            using (with police_officer:= (select IsPolice filter .id = global current_user_id),
                select if exists police_officer then (
                        police_officer.police_rank ?? PoliceRank.PC >= PoliceRank.DCP
                    ) else (
                        false
                    )                                                                                                                  
            )
            {
                errmessage := "PoliceRank required: PoliceRank.DCP"
            };

        access policy authorized_allow_select
            allow select
            using (with police_officer:= (select IsPolice filter .id = global current_user_id),
                select if exists police_officer then (
                        police_officer.police_rank ?? PoliceRank.PC >= PoliceRank.SP
                    ) else (
                        false
                    )                                                                                                                  
            )
            {
                errmessage := "PoliceRank required: PoliceRank.SP"
            };

    };
    
    type GangsterSpy extending Character, IsSpy;

    type Landmark extending Place;
    type Location extending Place;
    type Store extending Place;

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

    type CriminalRecord extending Archive {
        required ref_no: str {
            constraint exclusive;
        };
        required code: str;
        multi involved: Character;
        created_at: datetime {
            readonly := true;
            rewrite insert using (datetime_of_statement())
        }
        modified_at: datetime {
            rewrite update using (datetime_of_statement())
        }
    }

    type PoliceSpyFile extending Archive {
        multi colleagues: PoliceSpy;
        classified_info: str; 

        access policy authorized_allow_all
            allow all
            using (with police_officer:= (select IsPolice filter .id = global current_user_id),
                select if exists police_officer then (
                        police_officer.police_rank ?? PoliceRank.PC >= PoliceRank.SP
                    ) else (
                        false
                    )                                                                                                                  
            )
        {
            errmessage := "PoliceRank required: PoliceRank.SP"
        };
    }

    type ChenLauContact extending Event {
        how: str;
        overloaded who: Character {default:= {chen, lau}}
    }

    type Scene extending Event {
        title: str;
        remarks: str;
        references: array<tuple<str, str>>;
        required scene_number: SceneNumber {
            constraint exclusive;
            default := sequence_next(introspect SceneNumber);
        }
        index on (.scene_number);
    }

    # alias
    alias hon:= assert_exists(assert_single((select GangsterBoss filter .name = "韓琛")));
    alias lau:= assert_exists(assert_single((select GangsterSpy filter .name = "劉建明")));
    alias chen:= assert_exists(assert_single((select PoliceSpy filter .name = "陳永仁")));
    alias wong:= assert_exists(assert_single((select Police filter .name = "黃志誠")));

    alias police_station:= assert_exists(assert_single((select Landmark filter .name="警察局")));

    alias year_1992:= assert_exists(assert_single((select FuzzyTime 
                                        filter .fuzzy_year = 1992 
                                        and .fuzzy_month ?= <FuzzyMonth>{}
                                        and .fuzzy_day ?= <FuzzyDay>{}
                                        and .fuzzy_hour ?= <FuzzyHour>{}
                                        and .fuzzy_minute ?= <FuzzyMinute>{}
                                        and .fuzzy_second ?= <FuzzySecond>{}   
                                        and .fuzzy_dow ?= <DayOfWeek>{}
                    ))
    );
    alias year_1994:= assert_exists(assert_single((select FuzzyTime 
                                        filter .fuzzy_year = 1994 
                                        and .fuzzy_month ?= <FuzzyMonth>{}
                                        and .fuzzy_day ?= <FuzzyDay>{}
                                        and .fuzzy_hour ?= <FuzzyHour>{}
                                        and .fuzzy_minute ?= <FuzzyMinute>{}
                                        and .fuzzy_second ?= <FuzzySecond>{}   
                                        and .fuzzy_dow ?= <DayOfWeek>{}
                    ))
    );
    alias year_2002:= assert_exists(assert_single((select FuzzyTime 
                                        filter .fuzzy_year = 2002 
                                        and .fuzzy_month ?= <FuzzyMonth>{}
                                        and .fuzzy_day ?= <FuzzyDay>{}
                                        and .fuzzy_hour ?= <FuzzyHour>{}
                                        and .fuzzy_minute ?= <FuzzyMinute>{}
                                        and .fuzzy_second ?= <FuzzySecond>{}   
                                        and .fuzzy_dow ?= <DayOfWeek>{}
                    ))
    );

    # undercover
    alias morse_code_of_undercover:= str_replace("..- -. -.. . .-. -.-. --- ...- . .-.", "-", "_");

    # functions
    function is_hi_fi_store_open(dow: DayOfWeek, visit_hour: int64) -> bool
    #
    # The store will open 11:00~22:00 everyday, except:
    # will close on Wednesdays.
    # will close during 13:00~14:00 and 19:00~20:00 everyday.
    #
    using (
        with open_hours:= multirange([range(11, 13), range(14, 19), range(20, 22)])
        select dow != DayOfWeek.Wednesday and contains(open_hours, visit_hour)
    );

    function get_stored_encrypted_password() -> str
    #
    # This function simulates retrieving the underlying stored encrypted password.
    #
    using (
        with code:= morse_code_of_undercover,
             module ext::pgcrypto, 
        select crypt(code, gen_salt())
    );

    function validate_password(code: str) -> bool
    #
    # https://www.edgedb.com/docs/stdlib/pgcrypto
    # 
    # Usage:
    # db> select validate_password(morse_code_of_undercover);
    #
    using (
        with hash:= get_stored_encrypted_password(),
             module ext::pgcrypto,
        select crypt(code, hash) = hash
    );

    function list_police_spy_names(code: str) -> json
    #
    # Noted that PoliceSpyFile is secured by the defined access policies.
    # Usage:
    # db> select list_police_spy_names(morse_code_of_undercover);
    # or 
    # wrapped in an api enpoint
    #
    using (
        with police_spy_file:= PoliceSpyFile if validate_password(code)
                               else <PoliceSpyFile>{},
             names:= array_agg(police_spy_file.colleagues.name),
        select json_object_pack({("names", <json>(names))})
    );

    # tests
    function test_alias() -> bool
    using (all({
            test_scene01_alias(),
            test_scene02_alias(),
            test_scene03_alias(),
            test_scene05_alias(),
            test_scene09_alias(),
        })
    );

    function test_scene01_alias() -> bool
    using (all({
            (exists hon),          
            (exists lau),
            (exists year_1992),   
        })
    );

    function test_scene02_alias() -> bool
    using (all({
            (exists chen),          
            (exists wong), 
        })
    );

    function test_scene03_alias() -> bool
    using (all({
            (exists year_1994),   
            (exists police_station),   
        })
    );

    function test_scene05_alias() -> bool
    using (all({
            (exists year_1994),
        })
    );

    function test_scene09_alias() -> bool
    using (all({
            (exists morse_code_of_undercover),
        })
    );

    function test_hi_fi_store_open() -> bool
    using (all({
          is_hi_fi_store_open(DayOfWeek.Monday, 12),
          is_hi_fi_store_open(DayOfWeek.Friday, 15),
          is_hi_fi_store_open(DayOfWeek.Saturday, 21),
        })
    );

    function test_hi_fi_store_close() -> bool 
    using (not all({
          is_hi_fi_store_open(DayOfWeek.Wednesday, 12),
          is_hi_fi_store_open(DayOfWeek.Thursday, 13),
          is_hi_fi_store_open(DayOfWeek.Sunday, 19),
        })
    );

}
```
