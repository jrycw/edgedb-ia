---
tags:
  - update inserts
  - function
---

# 04 - 被遺忘的時光

## Full schema preview
??? "Full schema preview"

    === "start"
        ``` sql title="scenes/scene03/schema.esdl"
        --8<-- "scenes/scene03/schema.esdl"
        ```

    === "end migration" 
        ``` sql hl_lines="182-192 225-239" title="scenes/scene04/schema.esdl"
        --8<-- "scenes/scene04/schema.esdl"
        ```

## 劇情提要
<figure markdown>
![scene04](https://m.media-amazon.com/images/M/MV5BYzlkZGJlZTYtNmMzZS00MmQ4LTg2OGItZjU3OTE0NmFhYWY5XkEyXkFqcGdeQXVyMTI3MDk3MzQ@._V1_FMjpg_UX1280_.jpg){ loading=lazy }
  <figcaption><a href="https://www.imdb.com/title/tt0338564/mediaindex">此劇照引用自IMDb-無間道</a></figcaption>
</figure>

臥底近十年後，建明與永仁在Hi-Fi鋪相遇。建明請永仁推薦設備，並一起試聽了`被遺忘的時光`。試聽過程中，建明請永仁換了一條音源線，歌聲立刻變得更加立體，好像真人就在眼前唱歌一般。畢竟這首歌建明聽過太多次，有太多懷念的過去（詳情請見無間道Ⅱ）。

## EdgeQL query

### `insert`此場景時間2002年11月28日
``` sql title="scenes/scene04/query.edgeql"
--8<-- "scenes/scene04/_internal/query.edgeql:insert_2002_11_28"
```

### `insert`店家Hi-Fi鋪
``` sql title="scenes/scene04/query.edgeql"
--8<-- "scenes/scene04/_internal/query.edgeql:insert_hi_fi_store"
```

### `update` `lau`
增加飾演建明十年後的演員劉德華至`lau`的`actors` `multi link`中（留意這邊使用的是`+=`）。

和`nested inserts`有點像，我們不需要先`insert`劉德華，再`update` `lau`，直接於`update`時`insert`即可。
``` sql title="scenes/scene04/query.edgeql"
--8<-- "scenes/scene04/_internal/query.edgeql:update_lau"
```

### `update` `chen`
`chen`的`update`可以同時：

* 將經典台詞「高音甜、中音準、低音勁。一句講哂，通透啦即係。」指定給`classic_lines` `property`（留意這邊使用的是`:=`）。
* 增加飾演永仁十年後的演員梁朝偉至`chen`的`actors` `multi link`中（留意這邊使用的是`+=`）。

``` sql title="scenes/scene04/query.edgeql"
--8<-- "scenes/scene04/_internal/query.edgeql:update_chen"
```

### `insert` `ChenLauContact`
``` sql title="scenes/scene04/query.edgeql"
--8<-- "scenes/scene04/_internal/query.edgeql:insert_chenlaucontact"
```

### 編寫`is_hi_fi_store_open`
如果我們想要知道Hi-Fi鋪是否處於營業時間，可以寫一個`is_hi_fi_store_open`的`function`來判斷。

假設Hi-Fi鋪每天的營業時間為11:00~22:00，但：

* 每星期三公休。
* 13:00~14:00及19:00~20:00為休息時間。

!!! tip "`range` vs `multiranges`"
    判斷某個數字是否在單一區間內，可以使用[`range()`](https://www.edgedb.com/docs/stdlib/range)。但如果有多個區間的話，則可以搭配[`multirange()`](https://www.edgedb.com/docs/stdlib/range#multiranges)來處理。


`is_hi_fi_store_open` `function`接收兩個變數，一個是`dow`（`DayOfWeek`型態）代表星期幾造訪，另一個是`visit_hour`（`int64`型態）代表幾點造訪，回傳值則為`bool`型態。

我們將營業時間拆成`11~13`、`14~19`及`20~22`三個`range`並包成一個`array`後，傳給一個`multirange`，並在`with`區塊中將其命名為`open_hours`。

接著判斷`dow`是否不是星期三，且`visit_hour`是否在`open_hours`區間內（使用[`contains`](https://www.edgedb.com/docs/stdlib/generic#function::std::contains)）。如果是的話，代表該時間為店家營業時間，回傳`true`；否則即為休息時間，回傳`false`。

``` sql title="scenes/scene04/schema.esdl"
--8<-- "scenes/scene04/_internal/schema.esdl:function_is_hi_fi_store_open"
```

### 編寫`test_hi_fi_store_open`及`test_hi_fi_store_close`
搭配[`all`](https://www.edgedb.com/docs/stdlib/set#function::std::all)和[`not`](https://www.edgedb.com/docs/stdlib/bool#operator::not)可以編寫`test_hi_fi_store_open`及`test_hi_fi_store_close`來確認`is_hi_fi_store_open`是否可以準確依照傳入時間，回傳正確的`bool`值。

``` sql title="scenes/scene04/schema.esdl"
--8<-- "scenes/scene04/_internal/schema.esdl:function_test_hi_fi_store_open"

--8<-- "scenes/scene04/_internal/schema.esdl:function_test_hi_fi_store_close"
```

??? danger "make end migration here（`scenes/scene04/schema.esdl`）"
    ``` sql
    did you create function 'default::is_hi_fi_store_open'? [y,n,l,c,b,s,q,?]
    > y
    did you create function 'default::test_hi_fi_store_close'? [y,n,l,c,b,s,q,?]
    > y
    did you create function 'default::test_hi_fi_store_open'? [y,n,l,c,b,s,q,?]
    > y
    ```

### 測試`test_hi_fi_store_open`及`test_hi_fi_store_close`
``` sql title="scenes/scene04/query.edgeql"
--8<-- "scenes/scene04/_internal/query.edgeql:test_hi_fi_store_open"
--8<-- "scenes/scene04/_internal/query.edgeql:test_hi_fi_store_close"
```


### `insert`此場景的`scene`
``` sql title="scenes/scene04/query.edgeql"
--8<-- "scenes/scene04/_internal/query.edgeql:insert_scene"
```

## Query review
??? Success "Query review"
    ``` sql title="scenes/scene04/query.edgeql"
    --8<-- "scenes/scene04/query.edgeql"
    ```

## 無間吹水
永仁幫建明刷卡的單據日期為2002年11月28日，但永仁於劇末的墓碑往生日期為2002年11月27日，這個問題20年來留給觀眾許多討論空間。有人說這是因為墓碑日期為陰曆，有人則說這是導演與編劇特地想表達「無間輪迴」之意。但根據2022年4K修復版上映時的訪問，似乎這只是一個單純的道具準備疏失。