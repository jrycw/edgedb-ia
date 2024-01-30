---
tags:
  - migration
  - uuid
---

# 10 - 我想做個好人

## Full schema preview
??? "Full schema preview"

    === "start"
        ``` sql title="scenes/scene09/schema.esdl"
        --8<-- "scenes/scene08/schema.esdl"
        ```

    === "end migration" 
        ``` sql hl_lines="104" title="scenes/scene10/schema.esdl"
        --8<-- "scenes/scene10/schema.esdl"
        ```

## 劇情提要

<figure markdown>
![scene13](https://m.media-amazon.com/images/M/MV5BOTI0ZDRjMmItYjAxOC00OTdkLTk4NTgtZmI5MmE5OGI3ZDE2XkEyXkFqcGdeQXVyMjQwMjk0NjI@._V1_FMjpg_UX796_.jpg){ loading=lazy }
  <figcaption><a href="https://www.imdb.com/title/tt0338564/mediaindex">此劇照引用自IMDb-無間道</a></figcaption>
</figure>

建明與永仁於天台相見，不料國平也趕到。永仁事先已報警，想持槍壓著建明到樓下交予警方。不料，於進電梯時被國平擊斃，原來他也是韓琛安裝於警隊的臥底。國平向建明表明身份，希望之後一起合作。但最終建明選擇於電梯中殺死國平，並營造永仁與國平雙雙死於槍戰的假象。事後，心兒於葉校長遺物中發現永仁臥底檔案，恢復其警察身份，並由建明代表行禮。

## 重要提醒 
!!! warning "`global` `current_user_id`"
    需要特別注意`global` `current_user_id`所屬`object`的`PoliceRank`是否合乎`access policy`!

## EdgeQL query

### 設定`global` `current_user_id`
由於本場景需要多次`update` `chen`。為方便操作，我們`insert`一個`PoliceRank`為`DCP`的`Police object`，並將其`id`指定給`global current_user_id`。
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:set_global"
```

### `update` `chen`
更新永仁的經典台詞。
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:update_chen1"
```

### `update` `lau`
更新建明的經典台詞。
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:update_lau1"
```

### `insert` `ChenLauContact`
這是本劇中，兩人最後一次聯絡了。
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:insert_chenlaucontact"
```
### `insert`真．林國平
真沒想到，國平竟然也是韓琛的臥底，第一次看到這段時，真是驚訝呀！

可是這麼一來，國平就不應該是`Police`而是`PoliceSpy`囉？我們應該刪掉`國平 Police object`，並新增一個`國平 PoliceSpy object`嗎？

這樣的話，之前`國平 Police object`的相關記錄都會被刪除（例如：`CIBTeamTreat`），這樣合理嗎？又或者我們要重新去確認所有跟`國平 Police object`有關的`object`將其替換為`國平 PoliceSpy object`？

該怎麼做其實沒有標準的答案，不過一個比較常見的方法是使用`soft delete`。使用一個類似`is_active`的`property`來表達該`object`的存取狀態，而不真正將其從資料庫中刪除。畢竟在最後一幕之前，我們的確不知道國平是臥底，`國平 Police object`是一個合適的表達。

最後我們`insert`國平的`PoliceSpy object`如下：
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:insert_big_b_as_police_spy"
```


### 感情線
在緊湊的臥底對決中，其實導演與編劇也穿插了一些感情戲份，讓我們一起來看看吧。

#### Mary & 建明
我們`insert`Mary，並指定其為建明的`lover`。
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:insert_mary"

--8<-- "scenes/scene10/_internal/query.edgeql:update_lau2"
```

#### 心兒 & 永仁
我們`insert`李心兒，並指定其為永仁的`lover`。
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:insert_li"

--8<-- "scenes/scene10/_internal/query.edgeql:update_chen2"
```

#### May & 永仁
現在我們面臨了一個有趣的情形，永仁看起來有兩個`lover`，但是我們的初始schema只設計了一個`single link`的`lover`。我們現在需要將這個`single link`的`lover`轉變為`multi link`的`lovers`。這其中其實包含了兩步的變更，第一步是將`lover`重新命名為`lovers`，第二步是將`lovers`由`single link`改為`multi link`。

您可以選擇做兩次`migration`，但其實EdgeDB相當聰明，大部份時間能夠猜中我們的意圖，讓我們試試用一步的`migration`來完成這個變化吧。我們變更`Character`如下：
``` sql title="scenes/scene10/schema.esdl"
--8<-- "scenes/scene10/_internal/schema.esdl:Character_lover_to_lovers"
```
接著於命令列執行`edgedb migration create`。
!!! danger "make end migration here（`scenes/scene10/schema.esdl`）"
  ``` sql
  did you drop link 'lover' of object type 'default::Character'? [y,n,l,c,b,s,q,?]
  > n
  did you rename link 'lover' of object type 'default::Character' to 'lovers'? [y,n,l,c,b,s,q,?]
  > y
  did you convert link 'lovers' of object type 'default::Character' to 'multi' cardinality? [y,n,l,c,b,s,q,?]
  > y
  ```
留意第一個選項我們選擇了`n`，於是EdgeDB試著詢問我們。如果不是要`drop`的話，是否是要`rename`。如果是要`rename`的話，是否由`single link`改為`multi link`。如此一來，我們原來於`lover`中所指向的`object`，在於命令列執行`edgedb migrate`後也會一併帶到`lovers`。

如果第一個選項我們選擇了`y`，EdgeDB會認為我們想先`drop`掉`lover`，然候加上一個`multi link`的`lovers`。如此一來`lovers`將會是空`set`，我們需要在於命令列執行完`edgedb migrate`後，手動將原來`lover`所指向的`object`加進來。

**由這個例子可以知道，`migration`時不一定只能選擇`y`，應該視當下需求來決定。**

最後我們`insert`May，並將May加入到`chen`的`lovers`。
``` sql title="scenes/scene10/query.edgeql"
# end migration needs to be applied before running this query
--8<-- "scenes/scene10/_internal/query.edgeql:insert_may"

--8<-- "scenes/scene10/_internal/query.edgeql:update_chen3"
```
我們可以用下面query確認`chen`的`lovers`內確實有心兒及May。
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:check_chen_lovers"
```
```
{'李心兒', 'May'}
```

### `insert`此場景的`scene`
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:insert_scene"
```

### `uuid`選取`object`的技巧
假設我們想選擇一開始建立的`PoliceRank`為`DCP`的`Police object`，該怎麼寫query呢？
最簡單的方法應該是`filter .name="test_DCP"`了吧，像是：
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:select_dcp_1"
```
此時，假設我們只有該`object` `str`型態的`id`的話，又該怎麼選取呢，您可能會寫出以下query：
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:select_dcp_2"
```
但是除了這種**經典**的寫法外，EdgeDB還提供了這種寫法：
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:select_dcp_3"
```
`pid`此時為`str`型態的`uuid`，我們可以在前面使用`<Police><uuid>`來`casting`而取得`object`。
??? warning "Shape construction"
    當想要使用上述寫法並搭配`shape construction`時，需加上`()`，例如：
    ``` sql title="正確語法"
    # ✅
    --8<-- "scenes/scene10/_internal/query.edgeql:select_dcp_shape"
    ```
    而下面這兩種寫法是不被允許的：
    === "錯誤語法1"
        ``` sql
        # ❌
        with pid:= <str>(select Police filter .name="test_DCP").id,
        select <Police><uuid>pid {*};
        ```
    === "錯誤語法2"
        ``` sql
        # ❌
        with pid:= <str>(select Police filter .name="test_DCP").id,
        select {*} <Police><uuid>pid;
        ```

另外，如果您已經有一個`id` `set`，也可以進行類似的操作，例如：
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:select_dcp_4"
```
### 最後清理
讓我們用上述新技巧來刪除本場景一開始建立的`PoliceRank`為`DCP`的`Police object`，並`reset` `global` `current_user_id`。
``` sql title="scenes/scene10/query.edgeql"
--8<-- "scenes/scene10/_internal/query.edgeql:delete_dcp"

--8<-- "scenes/scene10/_internal/query.edgeql:reset_global"
```

## Query review
??? Success "Query review"
    ``` sql title="scenes/scene10/query.edgeql"
    --8<-- "scenes/scene10/query.edgeql"
    ```

## 無間吹水
根據訪談，於拍攝時間只有華仔與編劇導演等少部份人知道，國平也是韓琛所派臥底，甚至連飾演國平的林家棟都是到最後一幕快開拍前才知道。當時他擔心前面的戲份是不是有演得不合劇情的地方，華仔說沒問題，他要的就是這種反差感。