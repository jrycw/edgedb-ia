module default {
    
    # ========== scalar types ========== 
    # --8<-- [start:scalar_type_PoliceRank]
    scalar type PoliceRank extending enum<Protected, Cadet, PC, SPC, SGT, SSGT, PI, IP, SIP, CIP, SP, SSP, CSP, ACP, SACP, DCP, CP>;
    # --8<-- [end:scalar_type_PoliceRank]

    # --8<-- [start:scalar_type_GangsterRank]
    scalar type GangsterRank extending enum<Nobody, Leader, Boss>;
    # --8<-- [end:scalar_type_GangsterRank]

    # ========== abstract object types ========== 
    # --8<-- [start:abstract_object_type_Person]
    abstract type Person {
        required name: str;
        nickname: str;
        eng_name: str;
    }
    # --8<-- [end:abstract_object_type_Person]

    # --8<-- [start:abstract_object_type_IsPolice]
    abstract type IsPolice {
        police_rank: PoliceRank{
            default:= PoliceRank.Cadet;
        };
        dept: str;
        is_officer:= .police_rank >= PoliceRank.PI;
    }
    # --8<-- [end:abstract_object_type_IsPolice]

    # --8<-- [start:abstract_object_type_IsGangster]
    abstract type IsGangster {
        gangster_rank: GangsterRank {
            default:= GangsterRank.Nobody;
        };
        gangster_boss: GangsterBoss;
    }
    # --8<-- [end:abstract_object_type_IsGangster]

    # --8<-- [start:abstract_object_type_IsSpy]
    abstract type IsSpy extending IsPolice, IsGangster;
    # --8<-- [end:abstract_object_type_IsSpy]

    # ========== object types ========== 
    # --8<-- [start:object_type_Person]
    type Character extending Person {
        classic_lines: array<str>;
        lover: Character;
        multi actors: Actor;
    }
    # --8<-- [end:object_type_Person]

    # --8<-- [start:object_type_Actor]
    type Actor extending Person;
    # --8<-- [end:object_type_Actor]

    # --8<-- [start:object_type_Police]
    type Police extending Character, IsPolice;
    # --8<-- [end:object_type_Police]

    # --8<-- [start:object_type_Gangster]
    type Gangster extending Character, IsGangster;
    # --8<-- [end:object_type_Gangster]

    # --8<-- [start:object_type_GangsterBoss]  
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
    # --8<-- [end:object_type_GangsterBoss]  

    # --8<-- [start:object_type_PoliceSpy]  
    type PoliceSpy extending Character, IsSpy;
    # --8<-- [end:object_type_PoliceSpy]  

    # --8<-- [start:object_type_GangsterSpy]  
    type GangsterSpy extending Character, IsSpy {
        overloaded police_rank: PoliceRank {
            default:= PoliceRank.Protected;
        }
    };
    # --8<-- [end:object_type_GangsterSpy]  

}
