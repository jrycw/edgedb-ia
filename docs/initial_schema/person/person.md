---
tags:
  - abstract object type
  - computed property
  - overloaded
  - constraint
---

# 人

??? "Full schema preview"
    ``` sql title="initial_schema/person/person.esdl"
    --8<-- "initial_schema/person/person.esdl"
    ```

## Scalar types
### PoliceRank
`PoliceRank`共有十七個階級，其中十五個階級為依據[維基百科](https://zh.wikipedia.org/zh-tw/%E9%A6%99%E6%B8%AF%E8%AD%A6%E5%AF%9F%E8%81%B7%E7%B4%9A)所定義。剩餘兩個階級分別為`Protected`（臥底）及`Cadet`（警校學生）。
``` sql
--8<-- "initial_schema/person/_internal/person.esdl:scalar_type_PoliceRank"
```

### GangsterRank
`GangsterRank`共有三個階級。
``` sql
--8<-- "initial_schema/person/_internal/person.esdl:scalar_type_GangsterRank"
```

## Abstract object types
### Person 
`Person`作為一個抽象的人物`abstract object type`，目的是希望能夠被真實世界的演員（`Actor`）以及劇中角色（`Character`）所`extending`。不論是演員或角色，有三個`property`是兩者皆具備的：

* `name` `property`為一必填的`property`，為演員或劇中角色名字。
* `nickname` `property`記錄綽號。
* `eng_name` `property`記錄英文名字。

``` sql
--8<-- "initial_schema/person/_internal/person.esdl:abstract_object_type_Person"
```

### IsPolice 
`IsPolice`有三個`property`：

* `police_rank` `property`代表警察官階，預設為警校學生（`PoliceRank.Cadet`）。
* `dept` `property`代表警察部門。
* `is_officer` `property`是一`computed property`（留意`is_officer`後使用的是`:=`，不是`:`），會根據`police_rank`是否為較高階級，來顯示`true`或`false`（`enum`的值是可以比較的，所以這邊可以使用`>=`）。

``` sql
--8<-- "initial_schema/person/_internal/person.esdl:abstract_object_type_IsPolice"
```

### IsGangster

`IsGangster`有一個`property`及一個`link`：

* `gangster_rank` `property`代表黑社會階級，預設為小弟（`GangsterRank.Nobody`）。
* `gangster_boss` `link`代表此角色的老大。

``` sql
--8<-- "initial_schema/person/_internal/person.esdl:abstract_object_type_IsGangster"
```

### IsSpy
`IsSpy`同時`extending` `IsPolice`及`IsGangster`用來表示臥底。
```sql
--8<-- "initial_schema/person/_internal/person.esdl:abstract_object_type_IsSpy"
```

## Object types

### Character
`Character` `extending` `Person`用來表示劇中角色，有一個`property`與兩個`link`：

* `classic_lines` `property`為一`array<str>`，用來記錄角色於劇中的名言。
* `lover` `link`為劇中角色的戀人。
* `actors` `multi link`為飾演劇中角色的演員（使用`multi`，因為一個角色可能由一個以上演員詮釋）。

```sql
--8<-- "initial_schema/person/_internal/person.esdl:object_type_Person"
```

### Actor
`Actor` `extending` `Person`用來表示演員。
```sql
--8<-- "initial_schema/person/_internal/person.esdl:object_type_Actor"
```

### Police
`Police`同時`extending` `Character`及`IsPolice`用來表示警察。
```sql
--8<-- "initial_schema/person/_internal/person.esdl:object_type_Police"
```

### Gangster
`Gangster`同時`extending` `Character`及`IsGangster`用來表示黑社會。
```sql
--8<-- "initial_schema/person/_internal/person.esdl:object_type_Gangster"
```

### GangsterBoss
`GangsterBoss` `extending` `Gangster`而來。
```sql
--8<-- "initial_schema/person/_internal/person.esdl:object_type_GangsterBoss"
```

`GangsterBoss`也算是`Gangster`，只不過其`gangster_rank`位階較其它黑社會成員高。為了表示這一特性，我們使用`overloaded` `gangster_rank`來加上兩個限制：

* 預設其`gangster_rank`為`GangsterRank.Boss`：
``` sql
default:= GangsterRank.Boss;
```

* 無論是`insert`或`update` `GangsterBoss`，其`gangster_rank`都只能指定為`GangsterRank.Boss`：
    ``` sql
    constraint expression on (__subject__ = GangsterRank.Boss);
    ```
    `constraint expression on` 可接受一個`expression`來返回`true`或`false`，如果返回的是`true`的話，才能允許相關操作。而[`__subject__`](https://www.edgedb.com/docs/datamodel/constraints)代表此處將受限制的值（一個`GangsterRank scalar`）。

此外，我們針對`GangsterBoss`這個`object type`也加上一個`constraint`來限制自己不能是自己的`gangster_boss`。其中`.gangster_boss`的`.`代表引用的是自身的`gangster_boss` `property`（定義於`Gangster`中），而`__subject__`則代表自己（一個`GangsterBoss object`）。
``` sql
constraint expression on (__subject__ != .gangster_boss) { 
    errmessage := "The boss can't be his/her own boss.";
}
```

### PoliceSpy
`PoliceSpy`同時`extending` `Character`及`IsSpy`，為警方派至黑社會之臥底。
```sql
--8<-- "initial_schema/person/_internal/person.esdl:object_type_PoliceSpy"
```

### GangsterSpy
`GangsterSpy`同時`extending` `Character`及`IsSpy`，為黑社會派至警方之臥底。
```sql
--8<-- "initial_schema/person/_internal/person.esdl:object_type_GangsterSpy"
```
