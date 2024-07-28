---
tags:
  - delegated 
  - backlink
  - link property
---

# 07 - 互猜底牌

## Full schema preview

??? "Full schema preview"

    === "start"
        ``` sql title="scenes/scene06/schema.esdl"
        --8<-- "scenes/scene06/schema.esdl"
        ```

    === "1st migration" 
        ``` sql hl_lines="57-63" title="scenes/scene07/schema_1st_migration.esdl"
        --8<-- "scenes/scene07/schema_1st_migration.esdl"
        ```

    === "end migration" 
        ``` sql hl_lines="16 66-79" title="scenes/scene07/schema.esdl"
        --8<-- "scenes/scene07/schema.esdl"
        ```


## 劇情提要

<figure markdown>
![scene07](https://m.media-amazon.com/images/M/MV5BNDQ5MDJjY2UtODBiNi00NTU1LTlhM2YtZmVkOWIzMzE5ZDQ3XkEyXkFqcGdeQXVyOTc5MDI5NjE@._V1_FMjpg_UX1920_.jpg){ loading=lazy }
  <figcaption><a href="https://www.imdb.com/title/tt0338564/mediaindex">此劇照引用自IMDb-無間道</a></figcaption>
</figure>

韓琛千鈞一髮之際收到建明簡訊，緊急打給迪路與傻強，將與泰國佬交易的可卡因丟進海裡。黃sir見行動失敗，只得暫時將韓琛及其手下帶回警察局。黃sir確認證據不足以起訴韓琛後，帶隊來到韓琛用餐的房間。黃sir藉機嘲諷韓琛，雖然這次無法逮捕他，但已令他損受幾千萬。韓琛聽後，瞬間翻臉將桌上食物往黃sir座位掃去。兩人言談間針鋒相對，互相猜測著對方安排在己方的臥底是誰。最後，韓琛囂張地帶著手下們大步離去。

## EdgeQL query

### 建立`Beverage`
全劇至此已是第三次喝飲料了，不禁讓我們想要建立一個`Beverage`來記錄所有人喝過的飲料。

`Beverage`有一個`property`和四個`link`：

* `name` `property`為必填的飲料名。
* `produced_by` `link`為生產廠家。
* `consumed_by` `link`為被誰所喝。
* `when` `link`為何時被喝。
* `where` `link`為在哪裡被喝。

``` sql title="scenes/scene07/schema_1st_migration.esdl"
--8<-- "scenes/scene07/_internal/schema.esdl:object_type_Beverage"
```
??? danger "make 1st migration here（`scenes/scene07/schema_1st_migration.esdl`）"
    ``` sql
    did you create object type 'default::Beverage'? [y,n,l,c,b,s,q,?]
    > y
    ```

### `insert`店家龍鼓灘
在開始進行`Beverage`相關操作前，我們先`insert`一個龍鼓灘`Store object`，代表一家名為龍鼓灘茶餐廳。
``` sql title="scenes/scene07/query.edgeql"
--8<-- "scenes/scene07/_internal/query.edgeql:insert_store_but_having_same_name_as_landmark"
```

如果您還記得的話，上一個場景我們也有名為一個龍鼓灘的`Landmark object`。由於`Store`及`Landmark`都是`extending`自`Place`，讓我們回顧一下`Place`的schema：
``` sql title="scenes/scene07/schema.esdl"
--8<-- "scenes/scene07/_internal/schema.esdl:abstract_object_type_Place"
```
由於`Place`的`name` `property`使用了`delegated constraint exclusive`，所以`Store`及`Landmark`各自都可以建立自己的龍鼓灘。

但是如果想再`insert`一個龍鼓灘`Store object`的話，則會報錯如下：

!!! failure "報錯訊息"
    ```
    edgedb error: ConstraintViolationError: name violates exclusivity constraint
    Detail: property 'name' of object type 'default::Store' violates exclusivity constraint
    ```

### `insert` `Beverage`
有喝飲料的角色太多了，讓我們`insert`三種飲料代表就好。

第一種是熱奶茶，為建明於下午茶時間喝的，為龍鼓灘茶餐廳出品。
??? info "三點三"
    粵語中形容分鐘時，習慣將六十分鐘分作十二份，每個數字對應五分鐘，所以下午三點三即代表15:15。
``` sql title="scenes/scene07/query.edgeql"
--8<-- "scenes/scene07/_internal/query.edgeql:insert_hot_milk_tea"
```

第二種是保特瓶裝綠茶，為建明在緝毒過程中請國平拿給他的。我們假設此時為20:15。
??? info "綠茶"
    由於這似乎是華仔代言的牌子，所以我們就不給定`produced_by`，來幫忙打廣告了。有趣的是，劇中還有一幕，建明打電話請同事跟蹤黃sir時，他又喝了一次同牌子的綠茶。此外，在無間道Ⅲ也會多次看到這個牌子，像是開頭建明與國平聊天時，永仁與黃sir見面的便利商店背景或是警察局的飲料販賣機等。

``` sql title="scenes/scene07/query.edgeql"
--8<-- "scenes/scene07/_internal/query.edgeql:insert_green_tea"
```

第三種是韓琛在警局被拘留時所喝的飲料，我們假設為龍鼓灘茶餐廳出品的凍檸茶並假設此時為23:15。
``` sql title="scenes/scene07/query.edgeql"
--8<-- "scenes/scene07/_internal/query.edgeql:insert_iced_lemon_tea"
```

### 再次熟悉`backlink`
假如我們想知道建明喝了哪些飲料，可以這麼做：
``` sql title="scenes/scene07/query.edgeql"
--8<-- "scenes/scene07/_internal/query.edgeql:select_Beverage_and_filter"
```
```
{default::Beverage {name: '熱奶茶'}, default::Beverage {name: '綠茶'}}
```
但是如果除了所喝的飲料，您又同時想顯示出建明的其它資訊，這時候可以使用`backlink`來做：
``` sql title="scenes/scene07/query.edgeql"
--8<-- "scenes/scene07/_internal/query.edgeql:Beverage_backlinks1"
```
```
{
  default::GangsterSpy {
    name: '劉建明',
    nickname: '劉仔',
    beverages: {default::Beverage {name: '熱奶茶'}, default::Beverage {name: '綠茶'}},
  },
}
```
??? tip "Deep fetching for backlinks"
    別忘了在`backlink`中也可以使用`shape`，像是這邊的`{name}`，來選取想要的`property`或`link`。
    
    也就是說您可以寫出像是下面這段有趣的query：
    ``` sql title="scenes/scene07/query.edgeql"
    --8<-- "scenes/scene07/_internal/query.edgeql:Beverage_backlinks2"
    ```
    ```
    {
      default::GangsterSpy {
        name: '劉建明',
        nickname: '劉仔',
        beverages: {
          default::Beverage {name: '熱奶茶', where: default::Landmark {name: '警察局'}},
          default::Beverage {name: '綠茶', where: default::Location {name: '大廈三樓'}},
        },
      },
    }
    ```
    這相當於同時列出：
    
    * 建明的`name` `property`。
    * 建明的`nickname` `property`。
    * 建明所喝的飲料及喝飲料的地點。

??? question "何時使用`backlink`？"
    當您想取得被`aaa`所`bbb`的`ccc`時，例如被建明（`aaa`）所喝掉（`bbb`）的飲料（`ccc`）時。此時對`aaa`使用`select`，`ccc`通常可以以`backlinks`的語法一起出現在`select`的`{}`內。

### 建立`TeamTreatNumber`及`CIBTeamTreat`
假如CIB部門有一個傳統，當全組人需要一起留下加班處理特殊案件時，部門內除長官外的每一個同事都可以在抽獎箱裡抽出一顆球（抽完後球會放回箱內）。箱內總共有1~10十顆球，上面貼有號碼，只要有人抽到的號碼是9或10的話，就會由部門長官買單請吃一頓下午茶。由於每次操作這個活動都需要花費不少時間，所以有組員提議請我們使用EdgeDB來簡化流程。身為無間道和EdgeDB的雙重愛好者，我們當然是義不容辭啦!

首先建立`TeamTreatNumber`，其是由`extending` `sequence`而來，作為每次活動的計數器。
``` sql title="scenes/scene07/schema.esdl"
--8<-- "scenes/scene07/_internal/schema.esdl:scalar_type_TeamTreatNumber"
```

接著建立`CIBTeamTreat`如下：
``` sql title="scenes/scene07/schema.esdl"
--8<-- "scenes/scene07/_internal/schema.esdl:object_type_CIBTeamTreat"
```
`CIBTeamTreat`有兩個`property`和一個`link`，我們逐個來看。

#### `team_treat_number`
`team_treat_number`為一`property`，其使用`TeamTreatNumber`為記數器，和`Scene`的`scene_number`一樣都是自動產生不重覆的編號。

#### `colleagues`
`colleagues`是一個`Police`的`multi link`，其預設選擇CIB部門的所有警察，這符合我們的需求，因為長官不須參加抽獎（記得建明是`PoliceSpy`嗎？）。接著我們加上`readonly`為`true`的限制，防止大家抽完獎之後耍賴偷改。

最後我們新增一個`int64`的`point`，這是一個[`link property`](https://www.edgedb.com/docs/datamodel/links#link-properties)，顧名思義其為一個`colleagues` `link`的`property`。這個`link property`並不能由`Police`來存取（雖然它現在正在`Police`的`{}`中），它只能夠在我們針對`CIBTeamTreat`query時存取。我們使用內建的[`math::ceil()`](https://www.edgedb.com/docs/stdlib/math#function::math::ceil)及[`random()`](https://www.edgedb.com/docs/stdlib/numbers#function::std::random)來給予CIB部門所有警察一個1~10的預設值，模擬抽獎過程（每個警察都會抽一次，且不會全部都是同一個數字）。

#### `team_treat`
`team_treat`為一`computed property`（留意這邊使用的是`:=`），其會返回一個`bool`值。存取`link property`需要使用特殊的`@`符號，所以`.colleagues@point`相當於動態取得該`CIBTeamTreat`內`colleagues` `multi link`內的所有`point`。我們使用內建的[`max()`](https://www.edgedb.com/docs/stdlib/set#function::std::max)來看看這些`point`內的最大值是否會大於或等於9。


??? danger "make end migration here（`scenes/scene07/schema.esdl`）"
    ``` sql
    did you create scalar type 'default::TeamTreatNumber'? [y,n,l,c,b,s,q,?]
    > y
    did you create object type 'default::CIBTeamTreat'? [y,n,l,c,b,s,q,?]
    > y
    ```

### `insert` `CIBTeamTreat`
讓我們來試試這個抽獎系統吧。下面的query每次都會`insert`一個`CIBTeamTreat`，並返回其`team_treat`之值。如果是`true`的話，代表建明需要請客。
``` sql title="scenes/scene07/query.edgeql"
--8<-- "scenes/scene07/_internal/query.edgeql:CIBTeamTreat1"
```

??? question "為什麼不寫成function呢？" 
    您可能會想將抽獎系統寫為`function`，像是：
    ``` sql
    # ❌
    function draw() -> CIBTeamTreat
    using (select(insert CIBTeamTreat));
    ```
    但是如果執行`edgedb migration create`會報錯如下：
    ```
    error: data-modifying statements are not allowed in function bodies
    ```
    原來`function`內是不能對資料庫進行變動的，包括`insert`、`update`及`delete`。

當然，有時候因為太久沒長官請客，大家會懷疑系統是不是出錯了，那麼可以由下面這個query來列出所有人抽到的數字。
``` sql title="scenes/scene07/query.edgeql"
--8<-- "scenes/scene07/_internal/query.edgeql:CIBTeamTreat2"
```
```
{default::CIBTeamTreat {team_treat_number: 2, team_treat: false, points: {8, 1, 1, 4, 6, 2}}}
```
最後，同事們間可能互相調侃誰最**帶賽**，此時可以用下面的query列出每個人的名字及其抽到的數字。
``` sql title="scenes/scene07/query.edgeql"
--8<-- "scenes/scene07/_internal/query.edgeql:CIBTeamTreat3"
```
```
{
  default::CIBTeamTreat {
    team_treat_number: 3,
    team_treat: true,
    colleagues: {
      default::Police {name: '林國平', @point: 1},
      default::Police {name: '大象', @point: 10},
      default::Police {name: '孖八', @point: 2},
      default::Police {name: 'police_11', @point: 7},
      default::Police {name: 'police_12', @point: 1},
      default::Police {name: 'police_13', @point: 7},
    },
  },
}
```
例如像第三次抽獎，國平和名為`police_12`的同事都只抽到1，不過還好大象抽到10，最後大家還是有免費下午茶吃。

現在開始，每次的抽獎記錄都會是一個`CIBTeamTreat object`。這些記錄累積起來可以有許多應用，例如每年年末，大家可以找出誰是最常幫大家贏得下午茶的人（最常拿9或10分），一起請他吃頓飯。`link property`是不是一個很酷的功能呀!

`link property`有一些語法如果不常使用，的確容易忘記。為此EdgeDB貼心準備了[cheatsheet](https://www.edgedb.com/docs/guides/cheatsheet/link_properties)供大家參考。

### `update` `hon`
話說這個場景好像充滿著飲料，讓我們回來繼續關心琛哥，`update`他離開警察局前對黃sir說的經典台詞到`classic_lines`。
``` sql title="scenes/scene07/query.edgeql"
--8<-- "scenes/scene07/_internal/query.edgeql:update_hon"
```

### `insert` `ChenLauContact`
``` sql title="scenes/scene07/query.edgeql"
--8<-- "scenes/scene07/_internal/query.edgeql:insert_chenlaucontact"
```

### `insert`此場景的`Scene`
``` sql title="scenes/scene07/query.edgeql"
--8<-- "scenes/scene07/_internal/query.edgeql:insert_scene"
```

## Query review
??? Success "Query review"
    ``` sql title="scenes/scene07/query.edgeql"
    --8<-- "scenes/scene07/query.edgeql"
    ```

## 無間吹水
根據訪談，曾志偉橫掃桌上飯菜的經典戲碼，黃秋生事先並不知情。但他根據自己的經驗判斷，曾志偉必定會這樣做，目的是使自己大吃一驚。於是他在演戲時，已經做好往後退的準備，因為不想穿著湯湯水水的衣服繼續演戲。