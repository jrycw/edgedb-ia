---
tags:
  - nested inserts
  - overloaded
---

# 02 - 我想跟他換

## Full schema preview
??? "Full schema preview"

    === "start"
        ``` sql title="scenes/scene01/schema.esdl"
        --8<-- "scenes/scene01/schema.esdl"
        ```

    === "1st migration" 
        ``` sql hl_lines="134-135 152 164-169" title="scenes/scene02/schema_1st_migration.esdl"
        --8<-- "scenes/scene02/schema_1st_migration.esdl"
        ```

    === "end migration" 
        ``` sql hl_lines="120-123" title="scenes/scene02/schema.esdl"
        --8<-- "scenes/scene02/schema.esdl"
        ```
## 劇情提要
<figure markdown>
![scene02](https://m.media-amazon.com/images/M/MV5BOWM2Zjc5NjEtOTRjNS00M2VhLTkyNmUtMmU0Yjc3MDMzOWQ2XkEyXkFqcGdeQXVyMjQwMjk0NjI@._V1_FMjpg_UX597_.jpg){ loading=lazy }
  <figcaption><a href="https://www.imdb.com/title/tt0338564/mediaindex">此劇照引用自IMDb-無間道</a></figcaption>
</figure>

葉校長與黃sir準備於警校新生中，挑選適合的新人臥底至黑社會。永仁天資優異，觀察入微，為臥底的不二人選。兩人指示永仁假裝鬧事並趁機將其趕出警校，而建明此時剛好入學，看著永仁背影喃喃自語道：「我想跟他換」。或許建明從一開始就真的想做個好人？


## EdgeQL query
### `insert`陳永仁及其少年時期演員余文樂
練習使用`nested inserts`來同時`insert`陳永仁及演員余文樂。
``` sql title="scenes/scene02/query.edgeql"
--8<-- "scenes/scene02/_internal/query.edgeql:insert_chen"
```

### `insert`黃志誠及其演員黃秋生
練習使用`nested inserts`來同時`insert`黃志誠及演員黃秋生。
``` sql title="scenes/scene02/query.edgeql"
--8<-- "scenes/scene02/_internal/query.edgeql:insert_wong"
```

### 建立`alias`及編寫測試`alias`的`function` 
建立一個`chen`（陳永仁）及`wong`（黃志誠）的`alias`。
``` sql title="scenes/scene02/schema_1st_migration.esdl"
--8<-- "scenes/scene02/_internal/schema.esdl:alias_chen"
--8<-- "scenes/scene02/_internal/schema.esdl:alias_wong"
```
新增`test_scene02_alias` `function`，並更新`test_alias`。
``` sql title="scenes/scene02/schema_1st_migration.esdl"
--8<-- "scenes/scene02/_internal/schema.esdl:test_alias"

--8<-- "scenes/scene02/_internal/schema.esdl:test_scene02_alias"
```
??? danger "make 1st migration here（`scenes/scene02/schema_1st_migration.esdl`）"
    ``` sql
    did you create alias 'default::chen'? [y,n,l,c,b,s,q,?]
    > y
    did you create alias 'default::wong'? [y,n,l,c,b,s,q,?]
    > y
    did you create function 'default::test_scene02_alias'? [y,n,l,c,b,s,q,?]
    > y
    did you alter function 'default::test_alias'? [y,n,l,c,b,s,q,?]
    > y
    ```

### 測試`test_alias`
``` sql title="scenes/scene02/query.edgeql"
# 1st migration needs to be applied before running this query
--8<-- "scenes/scene02/_internal/query.edgeql:test_alias"
```

### 建立`ChenLauContact`
由於建明與永仁於警校門口就已見過彼此，這勾起我們的好奇心，想知道兩人究竟於劇中見面或聯絡了幾次？
於是我們選擇建立一個`ChenLauContact`的`object type`來記錄。
`ChenLauContact` `extending` `Event`而來：

* 新增一個`how` `property`來描述聯絡方式。
* `overloaded`了`who`這個`multi link`，給予預設值`{chen, lau}`。

``` sql title="scenes/scene02/schema.esdl"
--8<-- "scenes/scene02/_internal/schema.esdl:object_type_ChenLauContact"
```
??? danger "make end migration here（`scenes/scene02/schema.esdl`）"
    ``` sql
    did you create object type 'default::ChenLauContact'? [y,n,l,c,b,s,q,?]
    > y
    ```

### `insert` `ChenLauContact`
``` sql title="scenes/scene02/query.edgeql"
# end migration needs to be applied before running this query
--8<-- "scenes/scene02/_internal/query.edgeql:insert_chenlaucontact"
```

### `insert`此場景的`Scene`

``` sql title="scenes/scene02/query.edgeql"
--8<-- "scenes/scene02/_internal/query.edgeql:insert_scene"
```

## Query review
??? Success "Query review"
    ``` sql title="scenes/scene02/query.edgeql"
    --8<-- "scenes/scene02/query.edgeql"
    ```

## 無間吹水
葉校長於1991年，年約42歲，且已擔任警校校長十年（由無間道Ⅱ得知）。參考[維基百科](https://zh.wikipedia.org/wiki/%E9%A6%99%E6%B8%AF%E8%AD%A6%E5%AF%9F%E5%AD%B8%E9%99%A2)所述，現在香港警察學院校長的官階約為助理處長。即使是前身的警察訓練學校，校長官階也應最少為警司級別以上。這麼一來，就代表葉校長32歲時，已經身居高位，升職的速度堪比坐火箭一般。相比之下，劇中黃志誠於2002年時，年約46歲，也僅擔任警司。