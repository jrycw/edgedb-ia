---
tags:
  - access policies
  - global
  - ext::pgcrypto
---

# 09 - 真相大白

## Full schema preview
??? "Full schema preview"

    === "start"
        ``` sql title="scenes/scene08/schema.esdl"
        --8<-- "scenes/scene08/schema.esdl"
        ```

    === "end migration" 
        ``` sql hl_lines="2 5-6 124-151 210-226 283 297-333 342 374-378" title="scenes/scene09/schema.esdl"
        --8<-- "scenes/scene09/schema.esdl"
        ```


## 劇情提要

<figure markdown>
![scene09](https://m.media-amazon.com/images/M/MV5BZjczZjQzZGUtNTJiNy00OTNjLTg4NzYtMDUyMmQ3NjEwYTc1L2ltYWdlL2ltYWdlXkEyXkFqcGdeQXVyNDE3OTAyNDU@._V1_FMjpg_UX600_.jpg){ loading=lazy }
  <figcaption><a href="https://www.imdb.com/title/tt0338564/mediaindex">此劇照引用自IMDb-無間道</a></figcaption>
</figure>

 建明得知黃sir將與警方臥底於大廈見面，通知韓琛。韓琛一面派手下到大廈，一面進行毒品交易。黃sir為掩護永仁離開，被韓琛手下丟下樓，寧願殉職而不發一言。黃sir死後，建明聯手永仁於停車場擊斃韓琛，最終兩人於警察局見面。當建明正幫永仁處理臥底檔案時，永仁發現其親手所寫帶有「標」字的信封竟然在建明桌上，醒悟原來建明就是韓琛派至警隊的臥底，立即悄然離開。

## 警隊資安升級計畫
自從黃sir殉職之後，警隊高層了解在趕快找出韓琛臥底的同時，也需要保護好自己派出的臥底，於是決定全面重新檢查一遍資料庫的存取權限。

經過一番資安演練，IT部門也發現平行時空的建明所發現的事情，即是當同時擁有`IsPolice`及`PoliceSpy`的讀取權限時，是可以由`IsPolice`的`id`來找出其在`PoliceSpy`中的`name`。

由於現在能同時存取`IsPolice`及`PoliceSpy`的人數過多，高層決定做出以下變更：

* `PoliceSpy`新增兩個`access policy`：
    * 只有副處長級別以上（`DCP`）可以`insert`、`update`及`delete`。
    * 只有警司級別以上（`SP`）可以`select`。
* 新增一個`PoliceSpyFile`方便各部門協同操作，只有警司級別以上（`SP`）可以執行全部操作。
* 於非內網登入系統時，不提供`REPL`操作。關於臥底資料僅提供一個`list_police_spy_names`的endpoint，且只有當操作者驗證為警司級別以上（`SP`）且密碼正確的情況下，才能得到全部警察臥底的名字。

## EdgeQL query
### 建立 `global` `current_user_id`
`current_user_id`是一個`global scalar`，讓我們在全域中都可以存取這個值。
``` sql title="scenes/scene09/schema.esdl"
--8<-- "scenes/scene09/_internal/schema.esdl:global_type_current_user_id"
```
可以透過`set`這個指令來給定其值，如：
``` sql
set global current_user_id:=<uuid>"ccc7a858-bd17-11ee-b4be-9f69662124af";
```
或透過`reset`將其回復為預設值，如：
``` sql
reset global current_user_id;
```
由於我們沒有給定預設值，所以如果執行上述query時，會將`global current_user_id`變為空的`<uuid>{}`。

!!! warning "`global`為關鍵字"
    存取`global scalar`時，`global`關鍵字不可省略。

### 更新`PoliceSpy`
`PoliceSpy`新增兩個`access policy`：
``` sql title="scenes/scene09/schema.esdl"
--8<-- "scenes/scene09/_internal/schema.esdl:object_type_PoliceSpy"
```
我們在`Envelope`已經學習過`access policy`，這裡比較不一樣的是`using`內比較複雜，我們舉第一個`access policy`為例來看：

* 在`with`區塊內，確認`global current_user_id`現在所指定的`id`的確在`IsPolice`中。
* 接著在`select`中使用`if cond then {} else {}`的語法來判斷需要執行的query。我們用的判斷式是`exists police_officer`：

    * 如果`police_officer`存在的話，我們執行`police_officer.police_rank ?? PoliceRank.PC >= PoliceRank.DCP`。這段query的意思是判斷所找到`police_officer`的`police_rank`是否高於`PoliceRank.DCP`，如果是的話，回傳`true`，否則回傳`false`。其中`??`是當`police_officer.police_rank`為空`set`時的預設值，我們預設其為官階最小的`PoliceRank.PC`。
    * 如果`police_officer`不存在的話，回傳`false`。

這麼一來，我們滿足了第一個需求。

### 建立`PoliceSpyFile`
`PoliceSpyFile` `extending` `Archive`而來，有一個`link`、一個`property`及一個`access policy`：

* `colleagues`是`multi link`指向`PoliceSpy`。
* `classified_info` `property`為一`str`，代表所儲存的機密資訊。
* `access policy`的寫法與`PoliceSpy`類似，但這邊是警司級別以上（`SP`）可以執行全部操作。

``` sql title="scenes/scene09/schema.esdl"
--8<-- "scenes/scene09/_internal/schema.esdl:object_type_PoliceSpyFile"
```
??? tip "新增`PoliceSpyFile`的妙用"
    警司級別以上（`SP`）可以對`PoliceSpyFile`進行全部操作，包括`select` `colleagues`，這有可能會選取到多個`PoliceSpy`。但要對這些`PoliceSpy`進行`update`或`delete`依然需要為副處長級別以上（`DCP`）。
    
    `PoliceSpyFile`可以想成一個專案簡報，當您具備足夠權限的時候，可以對這個簡報做任何操作，包括引用專案檔案（但如果權限不足的話，將無法更新或刪除專案檔案）。

這麼一來，我們滿足了第二個需求。

### 編寫`list_police_spy_names`
`list_police_spy_names`大多數情況應該會被某種web framework寫出來的程式所呼叫（例如`Python`的[`FastAPI`](https://github.com/tiangolo/fastapi)或`Rust`的[`Axum`](https://github.com/tokio-rs/axum)）。

假如您有一個`/policespy-names`的endpoint，可以用`GET`來取得所有`PolicySpy` `name`的`JSON`格式，那麼處理這個endpoint的`view function`很有可能可以借助我們所寫的`list_police_spy_names`。

`list_police_spy_names`接收一個為`str`的`code`參數，並返回`JSON`格式：

* 在`with`區塊，透過`validate_password`做驗證。如果通過的話，則返回所有`PoliceSpyFile`，否則返回空`set`（即`<PoliceSpyFile>{}`）。
* 在`with`區塊，透過`array_agg`將`police_spy_file.colleagues.name`轉為`array`，並存為`names`。
* 最後利用[`json_object_pack`](https://www.edgedb.com/docs/stdlib/json#function::std::json_object_pack)及`<json>(names)`的`casting`功能返回`JSON`格式。

``` sql title="scenes/scene09/schema.esdl"
--8<-- "scenes/scene09/_internal/schema.esdl:list_police_spy_names"
```

要完成`validate_password` `function`，還需要搭配使用[`ext::pgcrypto`](https://www.edgedb.com/docs/stdlib/pgcrypto)、 `morse_code_of_undercover`及`get_stored_encrypted_password`，我們繼續看下去。

#### 使用`ext::pgcrypto`
``` sql title="scenes/scene09/schema.esdl"
--8<-- "scenes/scene09/_internal/schema.esdl:extension_pgcrypto"
```
??? tip "`Auth extension`"
    如果您的app有驗證需求的話，可以試試EdgeDB4.0推出的[`Auth extension`](https://www.edgedb.com/docs/guides/auth/index)。

#### 建立`alias` `morse_code_of_undercover`
劇中永仁臥底檔案的密碼就是`臥底的摩斯密碼`。

根據網路上的搜尋結果，摩斯密碼大多是使用`-`，但劇中卻是使用`_`。讓我們尊重原著，使用內建的[str_replace()](https://www.edgedb.com/docs/stdlib/string#function::std::str_replace)將臥底的摩斯密碼中的`-`換成`_`，並存成`alias`方便使用。
``` sql title="scenes/scene09/schema.esdl"
--8<-- "scenes/scene09/_internal/schema.esdl:alias_morse_code_of_undercover"
```
!!! warning "不要將機密資訊存為`alias`"
    實務上，不應該將機密資訊存為`alias`。我們這麼做只是方便稍後展示`validate_password`及`list_police_spy_names`的效果。

#### 編寫測試`alias`的`function`
新增`test_scene09_alias` `function`，並更新`test_alias`。
``` sql title="scenes/scene09/schema.esdl"
--8<-- "scenes/scene09/_internal/schema.esdl:test_alias"

--8<-- "scenes/scene09/_internal/schema.esdl:test_scene09_alias"
```

#### 編寫`get_stored_encrypted_password`
`get_stored_encrypted_password`模擬自資料庫中取出`hashed`過的加密密碼（雖然在這邊它看起來只是每次被呼叫時，計算`morse_code_of_undercover`的hash值）。
``` sql title="scenes/scene09/schema.esdl"
--8<-- "scenes/scene09/_internal/schema.esdl:function_get_stored_encrypted_password"
```

#### 編寫`validate_password`
最後我們參考官方文件中的[範例](https://www.edgedb.com/docs/stdlib/pgcrypto#function::ext::pgcrypto::crypt)，使用`ext::pgcrypto::crypt()`來計算所輸入的密碼（`salt`為`hashed`過的加密密碼），是否會等於`hashed`過的加密密碼本身。如果是的話，代表我們輸入的是正確密碼，返回`true`，否則則返回`false`。
``` sql title="scenes/scene09/schema.esdl"
--8<-- "scenes/scene09/_internal/schema.esdl:function_validate_password"
```

至此，我們滿足了第三個需求。
??? danger "make end migration here（`scenes/scene09/schema.esdl`）"
    ``` sql
    did you create extension 'pgcrypto'? [y,n,l,c,b,s,q,?]
    > y
    did you create alias 'default::morse_code_of_undercover'? [y,n,l,c,b,s,q,?]
    > y
    did you create function 'default::get_stored_encrypted_password'? [y,n,l,c,b,s,q,?]
    > y
    did you create function 'default::test_scene09_alias'? [y,n,l,c,b,s,q,?]
    > y
    did you create function 'default::validate_password'? [y,n,l,c,b,s,q,?]
    > y
    did you create global 'default::current_user_id'? [y,n,l,c,b,s,q,?]
    > y
    did you create object type 'default::PoliceSpyFile'? [y,n,l,c,b,s,q,?]
    > y
    did you create function 'default::list_police_spy_names'? [y,n,l,c,b,s,q,?]
    > y
    did you alter function 'default::test_alias'? [y,n,l,c,b,s,q,?]
    > y
    did you alter object type 'default::PoliceSpy'? [y,n,l,c,b,s,q,?]
    > y
    ```

!!! warning "讓人又愛又恨的`Access policy`？"
    由於我們添加了兩個`access policy`到`PoliceSpy`，從現在開始每次`select` `PoliceSpy`時，都要時刻注意`global current_user_id`所屬的`object`是否有足夠權限。

### 測試
#### 測試`test_alias`
由於`test_alias`中的`test_scene09_alias`含有`chen`（`PoliceSpy`）的測試，為了能夠`select`到`chen`來進行測試，我們從`Police`中隨意挑選一個`PoliceRank`為`SP`的`object`，將此`object`的`id`指定給`global current_user_id`（由於目前`SP`等級的警察只有黃sir一個，所以這個query就是將`global current_user_id`設為黃sir的`id`）。測試完成後，再執行`reset global current_user_id`回復為預設值。
``` sql title="scenes/scene09/query.edgeql"
# end migration needs to be applied before running this query
--8<-- "scenes/scene09/_internal/query.edgeql:test_alias"
```

#### 測試`validate_password`
如果輸入正確的密碼，`validate_password`會回傳`true`，否則回傳`false`。
``` sql title="scenes/scene09/query.edgeql"
--8<-- "scenes/scene09/_internal/query.edgeql:test_validate_password"
```

#### 測試`PoliceSpy`、`PoliceSpyFile`及`list_police_spy_names`

##### 如果`PoliceRank`為`PoliceRank.SP`
與`test_alias`一樣，我們將`global current_user_id`設為黃sir的`id`。
``` sql title="scenes/scene09/query.edgeql"
--8<-- "scenes/scene09/_internal/query.edgeql:test_police_rank_SP_sec1"
```
接著進行`PoliceSpy`各項操作測試：

* `insert`會得到`AccessPolicyError`。
* `select`可以正常執行。
* `update`及`delete`會得到空`set`。

這樣的結果符合需求一的部份要求。
``` sql title="scenes/scene09/query.edgeql"
--8<-- "scenes/scene09/_internal/query.edgeql:test_police_rank_SP_sec2"
```

再來進行`PoliceSpyFile`各項操作測試及`list_police_spy_names`功能測試：

* `PoliceSpyFile`的各項功能皆能成功操作。
* `list_police_spy_names`在密碼正確的情況下，回傳含有資訊的`JSON`資料，否則回傳空的`JSON`資料。

這樣的結果符合需求二及需求三。
``` sql title="scenes/scene09/query.edgeql"
--8<-- "scenes/scene09/_internal/query.edgeql:test_police_rank_SP_sec3"
```

回復`global current_user_id`為預設值。
``` sql title="scenes/scene09/query.edgeql"
--8<-- "scenes/scene09/_internal/query.edgeql:test_police_rank_SP_sec4"
```

##### 如果`PoliceRank`為`PoliceRank.DCP`
由於資料庫中還沒有`PoliceRank`為`DCP`的`Police object`，所以我們先`insert`一個，再將其`id`指定給`global current_user_id`。
``` sql title="scenes/scene09/query.edgeql"
--8<-- "scenes/scene09/_internal/query.edgeql:test_police_rank_DCP_sec1"
```
接著進行`PoliceSpy`各項操作測試，皆能成功操作。

這樣的結果加上`PoliceRank`為`PoliceRank.SP`的測試，符合需求一的全部要求。
``` sql title="scenes/scene09/query.edgeql"
--8<-- "scenes/scene09/_internal/query.edgeql:test_police_rank_DCP_sec2"
```

再來進行`PoliceSpyFile`各項操作測試及`list_police_spy_names`功能測試：

* `PoliceSpyFile`的各項功能皆能成功操作。
* `list_police_spy_names`在密碼正確的情況下，回傳含有資訊的`JSON`資料，否則回傳空的`JSON`資料。

這樣的結果符合需求二及需求三。
``` sql title="scenes/scene09/query.edgeql"
--8<-- "scenes/scene09/_internal/query.edgeql:test_police_rank_DCP_sec3"
```

### `insert` `ChenLauContact`
``` sql title="scenes/scene09/query.edgeql"
--8<-- "scenes/scene09/_internal/query.edgeql:insert_chenlaucontact1"

--8<-- "scenes/scene09/_internal/query.edgeql:insert_chenlaucontact2"
```

### `insert`此場景的`scene`
``` sql title="scenes/scene09/query.edgeql"
--8<-- "scenes/scene09/_internal/query.edgeql:insert_scene"
```

### 最後清理
刪除`PoliceRank`為`DCP`的測試用`Police object`，並回復`global current_user_id`為預設值。
``` sql title="scenes/scene09/query.edgeql"
--8<-- "scenes/scene09/_internal/query.edgeql:delete_DCP"

--8<-- "scenes/scene09/_internal/query.edgeql:reset_global"
```

## Query review
??? Success "Query review"
    ``` sql title="scenes/scene09/query.edgeql"
    --8<-- "scenes/scene09/query.edgeql"
    ```

## 無間假設
我們假設劇中只有一個天台`Location object`。

## 無間吹水
建明要刪掉永仁臥底檔案時，鏡頭內所帶到的資訊及其臥底時間，多處都與三部曲劇情不相吻合。