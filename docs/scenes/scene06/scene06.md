---
tags:
  - for loop
  - group
---

# 06 - 有內鬼終止交易

## Full schema preview
!!! danger "本場景無須migration"

??? "Full schema preview"

    === "start"
        ``` sql title="scenes/scene05/schema.esdl"
        --8<-- "scenes/scene05/schema.esdl"
        ```

    === "end migration" 
        ``` sql title="scenes/scene06/schema.esdl"
        --8<-- "scenes/scene06/schema.esdl"
        ```

## 劇情提要

<figure markdown>
![scene06](https://m.media-amazon.com/images/M/MV5BZjM4MmIxZTktMjM5Ny00MDgyLWIxNmEtNDU5ZTBhNjE2M2Y5XkEyXkFqcGdeQXVyNDE3OTAyNDU@._V1_FMjpg_UX600_.jpg){ loading=lazy }
  <figcaption><a href="https://www.imdb.com/title/tt0338564/mediaindex">此劇照引用自IMDb-無間道</a></figcaption>
</figure>

O記聯合CIB準備於今晚韓琛與泰國佬交易可卡因（古柯鹼）時，來個人贓並獲。建明知道後，假裝打電話給家人，通知韓琛。韓琛一直監聽警方頻道，並指示迪路和傻強四處亂晃，不要前往交易地點。過程中，永仁一直以摩斯密碼與黃sir聯絡。黃sir在得知韓琛監聽頻道後，隨即轉換頻道，並使用舊頻道發出今晚行動取消的指令。韓琛信以為真，指示迪路和傻強可以前往龍鼓灘交易。正當交易完成，黃sir準備先逮捕迪路和傻強將毒品扣下，再衝進屋逮捕韓琛之際，建仁使用簡訊傳送「有內鬼，終止交易」到韓琛所在位置附近的所有手機。

## EdgeQL query

### `insert`地點大廈三樓
``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:insert_building_3f"
```

### `update` `wong`
黃sir為有組織罪案及三合會調查科（O記）的警司（`SP`），`update`其相關`property`。
``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:update_wong"
```

### `insert`數名O記警察
`insert`黃sir麾下警察。
``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:insert_policemen1"
```

### `update` `lau`
建明為刑事情報科（CIB）的高級督察（`SIP`），`update`其相關`property`。
``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:update_lau"
```

### `insert`數名CIB警察
`insert`建明麾下警察。
``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:insert_big_b"

--8<-- "scenes/scene06/_internal/query.edgeql:insert_2_SGT"

--8<-- "scenes/scene06/_internal/query.edgeql:insert_policemen2"
```

### `insert`數名韓琛小弟
`insert`數名韓琛小弟，包括兩個小`leader`迪路與傻強。
``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:insert_gangster_leader1"

--8<-- "scenes/scene06/_internal/query.edgeql:insert_gangster_leader2"

--8<-- "scenes/scene06/_internal/query.edgeql:insert_gangsters"
```

### `insert`數個提及的地標
``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:for_loop_insert_landmark"
```

### `insert` `ChenLauContact`
``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:insert_chenlaucontact"
```

### 學習使用`group` - 情境1
讓我們假想一下自己是編劇。這個場景的人物相比前面多了不少，我們必須確認從警察的視角來看，各個階級的人力配置合不合理，此時[`group`](https://www.edgedb.com/docs/reference/edgeql/group)會是一個不錯的工具。`group`以後的操作，大多需要用到它的`key`、`grouping`及`elements`。

首先我們做以下嘗試：

* 於`with`區塊選取`Police`、`PoliceSpy`及`GangsterSpy`（建明及永仁也都是警察）命名為`p`。
* 於`with`區塊`group p`並依照`police_rank`來分類，結果命名為`g`。
* 最後使用`{**}`顯示`g`的細節。

``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:group_police_rank1"
```
??? info "Deep fetching"
    在熟悉上面這段query的時候，或許您會很想只顯示`key`裡面的`police_rank`及`elements`裡面的`name`，卻發現不知道怎麼達成。您可能會做以下嘗試：
    ``` sql
    #❌
    with p:= Police union PoliceSpy union GangsterSpy,
         g:= (group p by .police_rank),
    select g {key {police_rank}, 
              elements {name}};
    ```
    但正確的語法是需要加上`:`：
    ``` sql
    #✅
    with p:= Police union PoliceSpy union GangsterSpy,
         g:= (group p by .police_rank),
    select g {key: {police_rank}, 
              elements: {name}};
    ```
    ```
    {
      {key: {police_rank: Protected}, elements: {default::PoliceSpy {name: '陳永仁'}}},
      {
        key: {police_rank: SPC},
        elements: {
          default::Police {name: 'police_1'},
          default::Police {name: 'police_2'},
          default::Police {name: 'police_3'},
          default::Police {name: 'police_4'},
          default::Police {name: 'police_5'},
          default::Police {name: 'police_6'},
          default::Police {name: 'police_7'},
          default::Police {name: 'police_8'},
          default::Police {name: 'police_9'},
          default::Police {name: 'police_10'},
          default::Police {name: 'police_11'},
          default::Police {name: 'police_12'},
          default::Police {name: 'police_13'},
        },
      },
      {key: {police_rank: SGT}, elements: {default::Police {name: '大象'}, default::Police {name: '孖八'}}},
      {key: {police_rank: SSGT}, elements: {default::Police {name: '林國平'}}},
      {key: {police_rank: SIP}, elements: {default::GangsterSpy {name: '劉建明'}}},
      {key: {police_rank: SP}, elements: {default::Police {name: '黃志誠'}}},
    }
    ```
    這也是一個我們經常會突然**失憶**的地方，分享給大家做為參考。

但這麼一來，結果會非常長，我們舉黃sir為例，因為`SP`級別只有他一人。
```
  ...
  {
    id: 10d5423b-15cf-4c4d-89ca-e39b4bfa9902,
    grouping: {'police_rank'},
    key: {id: 46542b84-47fb-44b8-bdfd-2bc34e924eee, police_rank: SP},
    elements: {
      default::Police {
        is_officer: true,
        classic_lines: ['你25號生日嘛!25仔!'],
        eng_name: {},
        name: '黃志誠',
        nickname: '黃sir',
        dept: '有組織罪案及三合會調查科(O記)',
        police_rank: SP,
        id: db630896-bc48-11ee-aae4-df71814b08b4,
      },
    },
  },
  ...
```
之所以會得到這麼長的結果是因為使用了`{**}`，但是我們的目的僅是想知道各個階級的人數，所以可以做下列修改：

* 利用`group`的`key`可以得到`police_rank`（因為這個`property`就是我們在`by`時使用的），並在`g{ }`中命名為`police_rank`。
* 利用`group`的`elements`得到該分類中每一個`object`（即`Police`或`PoliceSpy`或`GangsterSpy`），接著使用`count`來計算其數量，並在`g{ }`中命名為`counts`。
* 最後，由於`police_rank`是一個`enum`，所以可以使用`order by`對其進行排序，並加上`desc`，這麼一來就會改成官階較大的排在前面。

``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:group_police_rank2"
```
```
{
  {police_rank: SP, counts: 1},
  {police_rank: SIP, counts: 1},
  {police_rank: SSGT, counts: 1},
  {police_rank: SGT, counts: 2},
  {police_rank: SPC, counts: 13},
  {police_rank: Protected, counts: 1},
}
```
這麼一來就可以看出：

* 高階長官`SP`及`SIP`各一位
* 比較有工作經驗的`SSGT`一位及`SGT`兩位。
* 主要執勤探員`SPC`十三位。
* 臥底探員一位。

編劇此時可以依據這個結果，來請教相關專業人士這樣的人力配置是否合理。

### 學習使用`group` - 情境2
假設片場工作人員在休息時間聊到，不知道劇中出現的地名：

* 最長的有多長呢？
* 哪一個長度又是出現最多次的呢？

此時又是可以好好運用`group`的機會囉。因為這次不像上面一樣，有內建的`police_rank`可以使用，所以需要使用`using`來組合出想要如何分類的操作。

針對第一個問題：

* 首先對`name` `property`使用`len`，並取名為`name_length`，這樣就可以將其放在`by`之後來分類。
* 利用`group`的`key`得到剛剛定義的`name_length`，並在`g{ }`中命名為`name_length`。
* 利用`group`的`elements`得到該分類中每一個`Place`，接著使用`count`來計算其數量，並在`g{ }`中命名為`counts`。
* 利用`group`的`elements`得到`name` `property`，並在`g{ }`中命名為`names`。
* 最後使用`order by`對`name_length`進行排序，並加上`desc`，這麼一來長度較長的地名就會顯示在前面了。

``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:group_place_1"
```
```
{
  {name_length: 6, counts: 1, names: {'Hi-Fi鋪'}},
  {name_length: 4, counts: 3, names: {'大廈三樓', '葵涌碼頭', '三號幹線'}},
  {name_length: 3, counts: 2, names: {'警察局', '龍鼓灘'}},
  {name_length: 2, counts: 3, names: {'佛堂', '天台', '警校'}},
}
```
結果發現長度最長的地名是Hi-Fi鋪，長度為6。

針對第二個問題，只需將`order by`的目標改為`counts`即可。
``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:group_place_2"
```
```
{
  {name_length: 4, counts: 3, names: {'大廈三樓', '葵涌碼頭', '三號幹線'}},
  {name_length: 2, counts: 3, names: {'佛堂', '天台', '警校'}},
  {name_length: 3, counts: 2, names: {'警察局', '龍鼓灘'}},
  {name_length: 6, counts: 1, names: {'Hi-Fi鋪'}},
}
```

結果發現地名長度為4及2的組別都出現三次。

### `insert`此場景的`Scene`
這裡選擇人物時，其實也可以像前面一樣使用`Police`及`Gangster`。但這麼一來，就是假設要選取全部的`Police`及`Gangster`，如果之後我們修改了前面幾個場景的query，在現在這種人物比較多的場景會難以偵錯（您可以假想`Scene`被極度簡化，只包含重要演員，但配角及台前幕後許多工作人員都未計入）。

所以我們這邊示範使用`with`搭配`filter`，限縮選取範圍。
``` sql title="scenes/scene06/query.edgeql"
--8<-- "scenes/scene06/_internal/query.edgeql:insert_scene"
```

## Query review
??? Success "Query review"
    ``` sql title="scenes/scene06/query.edgeql"
    --8<-- "scenes/scene06/query.edgeql"
    ```

## 無間假設
* 建明與黃sir的職級稍後才會提及，我們提前於此與部門一起`update`。
* 建明的小組成員其實於前一幕假扮律師時已經出現，我們省略該場景，改於此處 `insert`。
* 假設`大象`與`孖八`的兩人的本名也是`大象`與`孖八`。

## 無間吹水
* 建明傳送的簡訊原文是「有內鬼，終止交易」，但最終於路人手機上顯示的是「有內鬼終止交易」，少了一個逗號。
* 本片開頭韓琛提到以前在屯門做代客泊車的工作，可以得知其為屯門當地人或是與該地淵緣深厚，所以毒品交易地點選擇附近的龍鼓灘也甚為合理。
* 本場景有O記及CIB部門，卻沒有毒品調查科（MB）參與，有點令人費解。