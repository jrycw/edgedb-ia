# scalar types
scalar type PoliceRank extending enum<Protected, Cadet, PC, SPC, SGT, SSGT, PI, IP, SIP, CIP, SP, SSP, CSP, ACP, SACP, DCP, CP>;
scalar type GangsterRank extending enum<Nobody, Leader, Boss>;

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