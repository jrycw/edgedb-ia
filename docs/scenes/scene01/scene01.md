---
tags:
  - alias
  - function
---

# 01 - 韓琛初現

## Full schema preview
??? "Full schema preview"

    === "start"
        ``` sql title="scenes/scene01/initial_schema.esdl"
        --8<-- "scenes/scene01/initial_schema.esdl"
        ```

    === "end migration" 
        ``` sql hl_lines="135-162" title="scenes/scene01/schema.esdl"
        --8<-- "scenes/scene01/schema.esdl"
        ```
## 劇情提要
<figure markdown>
![scene01](https://m.media-amazon.com/images/M/MV5BOTI2ZmYzM2ItNWZkZC00MDFiLWFkMDctOGNmNWY4NWEyMWRjXkEyXkFqcGdeQXVyOTc5MDI5NjE@._V1_FMjpg_UX450_.jpg){ loading=lazy }
  <figcaption><a href="https://www.imdb.com/title/tt0374339/mediaindex">此劇照引用自IMDb-無間道Ⅲ終極無間</a></figcaption>
</figure>

韓琛準備派遣多個身家較為清白的小弟臥底至香港警隊，包括建明。他向小弟們講述著自己的過去，並說自己不相信算命先生所說的「一將功成萬骨枯」。他認為出來混的，未來的路怎麼走應該由自己決定。

## EdgeQL query

###
!!! danger "make start migration here（`scenes/scene01/initial_schema.esdl`）"
    在開始進行所有query前，我們需要先告知EdgeDB初始的schema。

    * 如果您是在命令列，需要輸入`edgedb migration create`後，再輸入`edgedb migrate`。
    * 如果您是在`EdgeDB REPL`，可以使用更便捷的`\migration create`及`\migrate`指令。

### `insert`此場景時間1992年
``` sql title="scenes/scene01/query.edgeql"
--8<-- "scenes/scene01/_internal/query.edgeql:insert_year_1992"
```

### `insert`韓琛及其演員曾志偉

``` sql title="scenes/scene01/query.edgeql"
--8<-- "scenes/scene01/_internal/query.edgeql:insert_hon"
```

韓琛於開頭就說出「一將功成萬骨枯」的經典句，我們將此句收錄在`classic_lines` `property`中。

此外，雖然`actors`為`multi link`，可以包括多個演員。但是我們可以使用[`assert_single()`](https://www.edgedb.com/docs/stdlib/set#function::std::assert_single)來確保最多只會接收到一個曾志偉`Actor object`。這麼一來，如果資料庫內已經有兩個`Actor object`的`name`都叫曾志偉時，這個query就會報錯。

另一種作法是觀察想選擇的`object`是否有`constraint exclusive`的`property`可以作為`filter`。如果有的話，即代表我們最多只會選擇到一個`object`，此時就不需要額外使用`assert_single()`了。這裡由於`Actor object`沒有`constraint exclusive`的`property`，所以無法使用這個作法。

### `insert`劉建明及其少年時期演員陳冠希
語法與前面類似，留意`filter`時也可用`in {}`的寫法。
``` sql title="scenes/scene01/query.edgeql"
--8<-- "scenes/scene01/_internal/query.edgeql:insert_lau"
```

### 建立`alias`
由於每次都要使用`(select ... filter ... .xxx=ooo)`的語法來選擇`object`頗為麻煩，針對常用到的`object`，可以直接在schema中建立`alias`，方便取用。我們這邊定義了一個`hon`（韓琛）、`lau`（劉建明）及`year_1992`（1992年）的`alias`。
``` sql title="scenes/scene01/schema.esdl"
--8<-- "scenes/scene01/_internal/schema.esdl:alias_hon"
--8<-- "scenes/scene01/_internal/schema.esdl:alias_lau"

--8<-- "scenes/scene01/_internal/schema.esdl:alias_year_1992"
```
於`year_1992`中，我們用到了[?=](https://www.edgedb.com/docs/stdlib/generic#operator::coaleq)`operator`。`?=`除了像[`=`](https://www.edgedb.com/docs/stdlib/generic#operator::eq)可以比較兩個`set`外，還可以比較空`set`。當兩個`set`都為空時，會返回`true`。當有些`property`可以為空`set`時，`?=`是個非常好用的工具。
!!! warning "空`set`需要型別"
    空`set`前別忘了加上型別來`casting`。
??? example "alias year_1992的另一種寫法"
    也可以使用`fuzzy_fmt`這個`computed property`來做為`filter`的條件。
    ``` sql
    alias year_1992:= assert_exists(assert_single((select FuzzyTime filter .fuzzy_fmt="1992/MM/DD_HH24:MI:SS_ID")));
    ```
    這種寫法比較快速，是我實際寫query會用的方法。但在定義schema時，我反而比較喜歡原先那種直接了當的寫法。


### 編寫測試`alias`的`function` 
您可能有留意到，我們在`alias`前都加上了[`assert_exists()`](https://www.edgedb.com/docs/stdlib/set#function::std::assert_exists)及`assert_single()`，這樣可以確保每個`alias`**只會返回剛好一個`object`**。我自己會習慣寫一個名為`test_alias`的[`function`](https://www.edgedb.com/docs/datamodel/functions)來做測試：
``` sql title="scenes/scene01/schema.esdl"
--8<-- "scenes/scene01/_internal/schema.esdl:test_alias"

--8<-- "scenes/scene01/_internal/schema.esdl:test_scene01_alias"
```
!!! warning "`function`的語法"
    習慣寫Python的朋友，常常會在定義`function`時，在`()`後加上`:`。
`test_alias`中會包含多個場景的sub-test（如`test_scene01_alias`），當每一個場景的`sub-test`都返回`true`時，[`all`](https://www.edgedb.com/docs/stdlib/set#function::std::all)會返回`true`，否則會報錯。而我們利用[`exists`](https://www.edgedb.com/docs/stdlib/set#operator::exists)檢查各場景中的`alias`是否存在，如果全部都存在的話，`all`會返回`true`，否則會報錯。

!!! failure "報錯訊息"
    ```
    edgedb error: CardinalityViolationError: assert_exists violation: expression returned an empty set
    ```

這麼一來當我們在操作資料庫時，可以隨時透過`test_alias`來確認每一個`alias`，是否都如預期地返回了剛好一個`object`。

??? danger "make end migration here（`scenes/scene01/schema.esdl`）"
    ``` sql
    did you create alias 'default::hon'? [y,n,l,c,b,s,q,?]
    > y
    did you create alias 'default::lau'? [y,n,l,c,b,s,q,?]
    > y
    did you create alias 'default::year_1992'? [y,n,l,c,b,s,q,?]
    > y
    did you create function 'default::test_scene01_alias'? [y,n,l,c,b,s,q,?]
    > y
    did you create function 'default::test_alias'? [y,n,l,c,b,s,q,?]
    > y
    ```

### 測試`test_alias`
``` sql title="scenes/scene01/query.edgeql"
# end migration needs to be applied before running this query
--8<-- "scenes/scene01/_internal/query.edgeql:test_alias"
```

### `insert`此場景的`Scene`
因為剛剛已經透過`test_alias`測試了所有`alias`，所以這裡我們可以放心使用。值得注意的是，我們在`insert`這個`scene`時，除了同時`insert` `佛堂`這個`Location` `object`外，也同時將其指定為`where` `multi link`的值。這樣的模式在`EdgeQL`稱為[nested inserts](https://www.edgedb.com/docs/edgeql/insert#nested-inserts)，是相當常見且實用的。

``` sql title="scenes/scene01/query.edgeql"
--8<-- "scenes/scene01/_internal/query.edgeql:insert_scene"
```

## Query review
??? Success "Query review"
    ``` sql title="scenes/scene01/query.edgeql"
    --8<-- "scenes/scene01/query.edgeql"
    ```

## 無間假設
理論上，我們應該處理建明由`Gangster object`轉變到`GangsterSpy object`的過程，但這對於`scene01`來說，可能太過複雜，所以在此處直接`insert`建明為`GangsterSpy object`。同理，我們將於`scene02`直接`insert`永仁為`PoliceSpy object`，而不處理其由`Police object`轉變到`PoliceSpy object`的過程。

## 無間吹水
佛堂前六個骨灰罈暗指當年韓琛死於屯門的六個兄弟。他藉祭拜為由，於一眾小弟面前展現其「仁義之風」。

