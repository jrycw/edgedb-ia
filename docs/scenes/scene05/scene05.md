---
tags:
  - datetime 
  - cal::relative_duration
---
# 05 - 三年之後又三年

## Full schema preview
??? "Full schema preview"

    === "start"
        ``` sql title="scenes/scene04/schema.esdl"
        --8<-- "scenes/scene04/schema.esdl"
        ```

    === "end migration" 
        ``` sql hl_lines="181-190 210 236-240" title="scenes/scene05/schema.esdl"
        --8<-- "scenes/scene05/schema.esdl"
        ```

## 劇情提要
<figure markdown>
![scene05](https://m.media-amazon.com/images/M/MV5BMjcyYzNhZDUtN2EwYy00NzA3LTkwNzEtYzc2MTAzOThhZmRmXkEyXkFqcGdeQXVyMTI3MDk3MzQ@._V1_FMjpg_UX1280_.jpg){ loading=lazy }
  <figcaption><a href="https://www.imdb.com/title/tt0338564/mediaindex">此劇照引用自IMDb-無間道</a></figcaption>
</figure>

永仁與黃sir相約於天台交換情報，韓琛將於這星期進行毒品交易，地點未知。黃sir則說他費盡心力將永仁傷人的案子由坐牢改成看心理醫生，交待永仁要照做。永仁則抱怨自己被黃sir騙了，說好只當三年臥底，結果現在都快十年了，不知道何時才能恢復警察身份。十年間發生了太多事，永仁看著黃sir送的手錶，他有時候真的不知道該用什麼心態面對黃sir（詳情請見無間道Ⅱ及無間道Ⅲ）。

## EdgeQL query

### `insert`此場景時間2002年
``` sql title="scenes/scene05/query.edgeql"
--8<-- "scenes/scene05/_internal/query.edgeql:insert_year_2002"
```

### 建立`alias`及編寫測試`alias`的`function` 
定義一個`year_2002`（2002年）的`alias`。
``` sql title="scenes/scene05/schema.esdl"
--8<-- "scenes/scene05/_internal/schema.esdl:alias_year_2002"
```
新增`test_scene05_alias` `function`，並更新`test_alias`。
``` sql title="scenes/scene05/schema.esdl"
--8<-- "scenes/scene05/_internal/schema.esdl:test_alias"

--8<-- "scenes/scene05/_internal/schema.esdl:test_scene05_alias"
```
??? danger "make end migration here（`scenes/scene05/schema.esdl`）"
    ``` sql
    did you create alias 'default::year_2002'? [y,n,l,c,b,s,q,?]
    > y
    did you create function 'default::test_scene05_alias'? [y,n,l,c,b,s,q,?]
    > y
    did you alter function 'default::test_alias'? [y,n,l,c,b,s,q,?]
    > y 
    ```

### 測試`test_alias`
``` sql title="scenes/scene05/query.edgeql"
# end migration needs to be applied before running this query
--8<-- "scenes/scene05/_internal/query.edgeql:test_alias"
```

### `update` `chen`
這裡永仁連說了兩句經典台詞，讓我們把它們都加在`classic_lines` `property`中（留意這邊使用的語法是`classic_lines := .classic_lines ++ array<str>`）。
``` sql title="scenes/scene05/query.edgeql"
--8<-- "scenes/scene05/_internal/query.edgeql:update_chen"
```

### `datetime`的模糊加減法
假如我們想幫永仁算一下他所說的「三年之後又三年，三年之後又三年！十年都嚟緊頭啦」，大概是多久的話，可以使用[`cal::relative_duration()`](https://www.edgedb.com/docs/stdlib/datetime#type::cal::relative_duration)。

我們假設永仁從1992年12月1日0時0分0秒，正式開始臥底工作。

首先我們需要將這個時間轉換為`datetime`型態。您可以選擇使用`<datetime>`來`casting`或是使用[`to_datetime()`](https://www.edgedb.com/docs/stdlib/datetime#function::std::to_datetime)來轉換。
??? tip "`Casting` vs `function`"
    初學的朋友可能會搞混這兩個方法。此時可以查看[`datetime`](https://www.edgedb.com/docs/stdlib/datetime)文件，通常沒有`()`的像是`datetime`或是`cal::local_datetime`，這代表是一種型態，可以於其後加上適當的`str`來`casting`。而像是有`to`開頭且有`()`的
    `to_datetime()`或是`cal::to_local_datetime()`，則代表`function`，需要參考其所提供的各種簽名來使用。EdgeDB可以針對同一個`function`名定義多次，接收不同的參數，像是`to_datetime()`就提供六種可以呼叫的簽名，這種特性稱為`function overloaded`。

``` sql title="scenes/scene05/query.edgeql"
--8<-- "scenes/scene05/_internal/query.edgeql:datetime_creation"
```
```
{<datetime>'1992-11-30T16:00:00Z'}
```

接下來利用`cal::relative_duration`來`casting`一個接近十年時間的`str`，假設為9年10個月。沒錯，`cal::relative_duration`可以接受像`9 years 10 months`這麼人性化的輸入!
``` sql title="scenes/scene05/query.edgeql"
--8<-- "scenes/scene05/_internal/query.edgeql:relative_duration_creation"
```
```
{<cal::relative_duration>'P9Y10M'}
```
接著我們將1992年12月1日0時0分0秒的`datetime`加上9年10個月的`relative_duration`：
``` sql title="scenes/scene05/query.edgeql"
--8<-- "scenes/scene05/_internal/query.edgeql:datetime_result"
```
```
{<datetime>'2002-09-30T16:00:00Z'}
```
最後將結果的`datetime`型態轉變為`local_datetime`型態：
``` sql title="scenes/scene05/query.edgeql"
--8<-- "scenes/scene05/_internal/query.edgeql:datetime_result_local"
```
```
{<cal::local_datetime>'2002-10-01T00:00:00'}
```
現在我們終於知道永仁與黃sir於本場景見面的時間，大概為2002年10月，這個計算大致符合劇中的時間線。

### `local_datetime`的模糊加減法
`datetime`的計算看起來比較複雜，因為牽扯到`timezone`。如果您想要計算的是`local_datetime`的話，那麼可以輕鬆不少。
``` sql title="scenes/scene05/query.edgeql"
--8<-- "scenes/scene05/_internal/query.edgeql:local_datetime_result"
```
```
{<cal::local_datetime>'2002-10-01T00:00:00'}
```

### `update` `wong`
將黃sir的經典台詞指定給`classic_lines` `property`（留意這邊使用的是`:=`）。
``` sql title="scenes/scene05/query.edgeql"
--8<-- "scenes/scene05/_internal/query.edgeql:update_wong"
```
??? info "25仔"
    25仔在粵語中即為`反骨仔`或`臥底`之意。黃sir此舉乃是在嘲諷永仁。

### `local_date`的模糊加減法
假設黃sir想幫永仁算一下，離永仁25號生日還有幾天，可以使用[`cal::local_date`](https://www.edgedb.com/docs/stdlib/datetime#type::cal::local_date)這麼算：
``` sql title="scenes/scene05/query.edgeql"
--8<-- "scenes/scene05/_internal/query.edgeql:cal_bday_diff"
```
```
{<cal::date_duration>'P24D'}
```
可以得知，大概還有24天。

??? info "永仁生日"
    永仁於劇末的墓碑出生日期為1966年10月25日。


### `insert`此場景的`Scene`
``` sql title="scenes/scene05/query.edgeql"
--8<-- "scenes/scene05/_internal/query.edgeql:insert_scene"
```

## Query review
??? Success "Query review"
    ``` sql title="scenes/scene05/query.edgeql"
    --8<-- "scenes/scene05/query.edgeql"
    ```

## 無間吹水
有一種說法是黃sir特別喜歡送人手錶。除了於天台送了永仁手錶外，無間道Ⅱ中Mary姐的手錶也是黃sir所送。所以當建明詢問Mary姐其所戴手錶是否為韓琛所送，她並沒有正面回應。