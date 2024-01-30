---
tags:
  - access policies
  - ext::pg_trgm
---

# 08 - 誰是內鬼

## Full schema preview
??? "Full schema preview"

    === "start"
        ``` sql title="scenes/scene07/schema.esdl"
        --8<-- "scenes/scene07/schema.esdl"
        ```

    === "1st migration" 
        ``` sql hl_lines="58-72" title="scenes/scene08/schema_1st_migration.esdl"
        --8<-- "scenes/scene08/schema_1st_migration.esdl"
        ```

    === "end migration" 
        ``` sql hl_lines="1" title="scenes/scene08/schema.esdl"
        --8<-- "scenes/scene08/schema.esdl"
        ```

## 劇情提要

<figure markdown>
![scene08](https://m.media-amazon.com/images/M/MV5BZGMwZTM4NTQtZjc3NS00NmFmLWEzNzktODk2NDQ4ZWNlMzZiXkEyXkFqcGdeQXVyMTI3MDk3MzQ@._V1_FMjpg_UX1280_.jpg){ loading=lazy }
  <figcaption><a href="https://www.imdb.com/title/tt0338564/mediaindex">此劇照引用自IMDb-無間道</a></figcaption>
</figure>

毒品交易失敗後，韓琛確信身邊有警察臥底。依照建明要求，將所有手下的個人資料裝在信封中，於電影院L13位置交給建明。永仁偷偷在後觀察並尾隨建明離開，欲看清其模樣，不料手機突然響起，因而錯失良機。而建明也隱約感覺到有人跟蹤，隱於牆後查看但未發現人跡。另一方面，警隊高層也懷疑韓琛安插了臥底，於是將建明調至內務部並在O記辦公，專門調查此事。建明依照韓琛所給資料於警隊資料庫中進行搜尋，卻無發現。於此同時，韓琛試探了身邊幾個親近手下，包括永仁與傻強。

## EdgeQL query

### 建立`Envelope`
由於信封在本劇後半段是一個重要的物件，除了裡面有參與韓琛毒品交易手下的資料外，更特別的是信封上有一個永仁親手寫的「標」字。於是我們想為信封建立一個`object type`，但同時希望這麼特別的信封只能被生成一次，也就是只能`insert`一個`Envelope object`。

我們準備借助EdgeDB的[`access policy`](https://www.edgedb.com/docs/datamodel/access_policies#access-policies)來完成這個需求，其有特殊的[`resolution order`](https://www.edgedb.com/docs/datamodel/access_policies#resolution-order)：

* 當`object type`上沒有施加任何`access policy`時，這個`object type`可以被讀取及變動。
* 當`object type`上有施加任何`access policy`時，會拆成三個步驟來決定允許操作的範圍：

    * 首先，所有操作先變為`deny`。
    * 接著，允許標示有`allow`的操作。
    * 最後，排除標示有`deny`的操作。
  
依照上述原理，我們可以建立`Envelope`的schema，其有一個`property`及兩個`access policy`：

* `name` `property`為永仁所寫的錯別字「標」，並設定`readonly`為`true`。代表當給予預設值後，無法變更此`property`。
* 第一個`policy`命名為`allow_select_insert_delete`，允許進行`select`、 `insert`及`delete`。
* 第二個`policy`命名為`only_one_envelope_exists`，使用`using (exists Envelope)`作為判斷條件，當資料庫中已經有存在`Envelope object`時，拒絕`insert`，並給定客製化的報錯訊息`Only one Envelope can be existed.`。

``` sql title="scenes/scene08/schema_1st_migration.esdl"
--8<-- "scenes/scene08/_internal/schema.esdl:object_type_Envelope"
```

??? tip "`readonly` vs `update police`"
    * `readonly`是用在`property`上的`constraint`，`update police`是適用在整個`object type`上。不過在我們這個例子中，因為沒有`allow` `update`，所以`Envelope`是不能`update`的，因此如果將`readonly`刪除也可以。此外，如果在這個例子中執行`update`query的話，EdgeDB並不會報錯，只會返回一個空`set`。

??? example "`access policy`的延伸應用"
    既然`access policy`可以讓我們限制`insert`的次數，這麼一來我們也可以延伸應用到對照警察職級表，來限制各職級的人數，例如只能`insert`一名處長（`CP`）級長官。

??? danger "make 1st migration here（`scenes/scene08/schema_1st_migration.esdl`）"
    ``` sql
    did you create object type 'default::Envelope'? [y,n,l,c,b,s,q,?]
    > y
    ```

### `insert` `Envelope`
執行下面query可以成功`insert`一個`Envelope object`。
``` sql title="scenes/scene08/query.edgeql"
--8<-- "scenes/scene08/_internal/query.edgeql:insert_envelope"
```
但是如果想再`insert`一個`Envelope object`的話，則會報錯如下：
!!! failure "報錯訊息"
    ```
    edgedb error: AccessPolicyError: access policy violation on insert of default::Envelope (Only one Envelope can be existed.)
    ```

我們的客製化錯誤訊息成功被印出。

### `update` `lau`
建明受上級指示調至內務部並在O記辦公，調查韓琛臥底。
``` sql title="scenes/scene08/query.edgeql"
--8<-- "scenes/scene08/_internal/query.edgeql:update_lau"
```

### 使用`ext::pg_trgm`
建明拿到信封後，想利用警隊的資料庫系統查詢，參與毒品交易手下們的名字有沒有在其中。此時他可以利用EdgeDB的[`ext::pg_trgm`](https://www.edgedb.com/docs/stdlib/pg_trgm)`extension`來查詢。
``` sql title="scenes/scene08/schema.esdl"
--8<-- "scenes/scene08/_internal/schema.esdl:extension_pg_trgm"
```
!!! warning "`extension`不可置於`module`內"
    留意`using extension module;`的位置，不可以置於任何`module`內。

??? danger "make end migration here（`scenes/scene08/schema.esdl`）"
    ``` sql
    did you create extension 'pg_trgm'? [y,n,l,c,b,s,q,?]
    > y
    ```

### 學習使用`ext::pg_trgm`

??? tip "如果需要的是full text search"
    可以試試內建的[`fts模組`](https://www.edgedb.com/docs/stdlib/fts)。但是我自己在使用`fts::index`後做migration，常常會失敗。可能是我還沒掌握到正確使用方式或是版本功能尚未穩定。
    

#### `word_similar()`
首先建明使用[`ext::pg_trgm::word_similar()`](https://www.edgedb.com/docs/stdlib/pg_trgm#function::ext::pg_trgm::word_similar)來進行查詢。這個`function`會計算第一個參數與第二個參數的任意部份相似的程度，並依據最高的分數是否超過預先設定的[門檻值](https://www.edgedb.com/docs/stdlib/pg_trgm#ref-ext-pgtrgm-config)，來回傳`bool`值。

``` sql title="scenes/scene08/query.edgeql"
--8<-- "scenes/scene08/_internal/query.edgeql:word_similar1"
```
```
{false}
```

這段query看起來有點複雜，我們逐個拆解：

* 在`with`區塊中，利用[`array_agg`](https://www.edgedb.com/docs/stdlib/array#function::std::array_agg)將`Police.name`這個`set`變為`array`。接著利用[`array_join`](https://www.edgedb.com/docs/stdlib/array#function::std::array_join)將`array`中每一個`element`（`str`型態）用`, `連接起來，命名為`names`。
* 在`with`區塊中，將預設`module`由`default`轉為`ext::pg_trgm`。
* 因為轉變了預設`module`，所以可以直接使用`word_similar()`查詢。

由於`陳永仁`這個名字的確沒有出現在`Police.name`中（`陳永仁`是`PoliceSpy`），所以建明得到`false`。

#### `word_similarity()`
如果建明不死心，想知道最高的分數實際上是多少的話，可以使用[`ext::pg_trgm::word_similarity()`](https://www.edgedb.com/docs/stdlib/pg_trgm#function::ext::pg_trgm::word_similarity)。
``` sql title="scenes/scene08/query.edgeql"
--8<-- "scenes/scene08/_internal/query.edgeql:word_similarity1"
```
```
{0}
```
最終建明得到了最低分的0分，這下他徹底死心了。

### 平時時空的建明
#### `word_similar()`
假設平時時空的建明，得知警隊除了平常可以接觸的資料庫外，還有一個機密資料庫，所有臥底檔案都在其中，而他已設法取得權限。
因為擁有存取`IsPolice`及`PoliceSpy`兩個`object type`的權限，他將可以進行下列query：
``` sql title="scenes/scene08/query.edgeql"
--8<-- "scenes/scene08/_internal/query.edgeql:word_similar2"
```
```
{true}
```
逐步拆解這段query：

* 在`with`區塊中，尋找`IsPolice`中哪些人的`police_rank`是`PoliceRank.Protected`並命名為`is_police_spy`，此時他僅能得到`IsPolice`中的資訊（即`id`、`police_rank`、`dept`及`is_officer`而已）。
* 在`with`區塊中，尋找`PoliceSpy`中哪些人的`id`在`is_police_spy`中並命名為`police_spy`。
* 在`with`區塊中，使用`array_agg`將`police_spy.name`及`police_spy.name`合成一個`array`，接著使用`array_join`將這個`array`以`, `連接起來，
並命名為`names`。
* 在`with`區塊中，將預設`module`由`default`轉為`ext::pg_trgm`。
* 因為轉變了預設`module`，所以可以直接使用`word_similar()`查詢。

這一次平時時空的建明得到`true`，成功找出永仁。

#### `word_similarity()`
如果建明使用`word_similarity`，其query會像是：
``` sql title="scenes/scene08/query.edgeql"
--8<-- "scenes/scene08/_internal/query.edgeql:word_similarity2"
```
```
{1}
```

建明會得到1分的最高分，一樣成功找出永仁。

此外，我們假設建明將`陳永仁`誤植為`陳永仨`，其query會像是：
``` sql title="scenes/scene08/query.edgeql"
--8<-- "scenes/scene08/_internal/query.edgeql:word_similarity3"
```
```
{0.5}
```

這一次建明得到不低的0.5分，他將會以`陳永仨`為線索之一，繼續追查下去。

### `with`區塊注意事項

#### `with module`相當於轉換預設`module`
下面這段query是錯誤的。
``` sql
# ❌
with module ext::pg_trgm,
       names:= array_join(array_agg(Police.name), ", "), 
select word_similar("陳永仁", names);
```
其報錯訊息為：
```
error: InvalidReferenceError: object type or alias 'ext::pg_trgm::Police' does not exist
```
因為此時`module`已經由`default`轉為`ext::pg_trgm`，而EdgeDB於`ext::pg_trgm`中找不到`Police`，所以報錯。

下列這個使用`default::Police.name`的query則可成功執行：
``` sql
# ✅
with module ext::pg_trgm,
       names:= array_join(array_agg(default::Police.name), ", "), 
select word_similar("陳永仁", names);
```
#### Free objects
[`Free objects`](https://www.edgedb.com/docs/edgeql/select#free-objects)讓我們可以在`with`區塊內，使用前面定義的變數。
舉下面這個query來說：
``` sql
--8<-- "scenes/scene08/_internal/query.edgeql:word_similarity2"
```

* `police_spy`引用了前面定義的`is_police_spy`。
* `names`引用了前面定義的`police_spy`。


### `insert`此場景的`scene`
``` sql title="scenes/scene08/query.edgeql"
--8<-- "scenes/scene08/_internal/query.edgeql:insert_scene"
```

## Query review
??? Success "Query review"
    ``` sql title="scenes/scene08/query.edgeql"
    --8<-- "scenes/scene08/query.edgeql"
    ```

## 無間吹水
黃sir於劇末的墓碑往生日期為2002年11月23日，而其識別證上更換日期卻為2008年7月31日。