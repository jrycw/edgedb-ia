---
tags:
  - rewrite
  - for loop
  - tuple
  - backlinks
---

# 03 - 黑白顛倒

## Full schema preview
??? "Full schema preview"

    === "start"
        ``` sql title="scenes/scene02/schema.esdl"
        --8<-- "scenes/scene02/schema.esdl"
        ```

    === "1st migration" 
        ``` sql hl_lines="142 154-163 170 189-194" title="scenes/scene03/schema_1st_migration.esdl"
        --8<-- "scenes/scene03/schema_1st_migration.esdl"
        ```

    === "end migration" 
        ``` sql hl_lines="54 122-135" title="scenes/scene03/schema.esdl"
        --8<-- "scenes/scene03/schema.esdl"
        ```
## 劇情提要
<figure markdown>
![scene03](https://m.media-amazon.com/images/M/MV5BZmI3NzIwMjUtNDk2ZC00OWE1LTk0MDktMzc2ODgyMmYxMzUyXkEyXkFqcGdeQXVyOTc5MDI5NjE@._V1_FMjpg_UX450_.jpg){ loading=lazy }
  <figcaption><a href="https://www.imdb.com/title/tt0338564/mediaindex">此劇照引用自IMDb-無間道</a></figcaption>
</figure>

永仁留下多次案底，並曾經被建明逮捕，但也逐漸取得黑社會的信任。建明畢業後則由警員（`PC`）做起，表現優異，獲面試晉陞見習督察（`PI`）的機會。兩人的路就像黑白顛倒一般，誰是好人，誰又是壞人呢？

## EdgeQL query

### `insert`此場景時間1994年
``` sql title="scenes/scene03/query.edgeql"
--8<-- "scenes/scene03/_internal/query.edgeql:insert_year_1994"
```

### `insert`地標警察局
``` sql title="scenes/scene03/query.edgeql"
--8<-- "scenes/scene03/_internal/query.edgeql:insert_police_station"
```

### 建立`alias`及編寫測試`alias`的`function` 
定義一個`year_1994`（1994年）及`police_station`（警察局）的`alias`。
``` sql title="scenes/scene03/schema_1st_migration.esdl"
--8<-- "scenes/scene03/_internal/schema.esdl:alias_year_1994"

--8<-- "scenes/scene03/_internal/schema.esdl:alias_police_station"
```
新增`test_scene03_alias` `function`，並更新`test_alias`。
``` sql title="scenes/scene03/schema_1st_migration.esdl"
--8<-- "scenes/scene03/_internal/schema.esdl:test_alias"

--8<-- "scenes/scene03/_internal/schema.esdl:test_scene03_alias"
```
??? danger "make 1st migration here（`scenes/scene03/schema_1st_migration.esdl`）"
    ``` sql
    did you create alias 'default::police_station'? [y,n,l,c,b,s,q,?]
    > y
    did you create alias 'default::year_1994'? [y,n,l,c,b,s,q,?]
    > y
    did you create function 'default::test_scene03_alias'? [y,n,l,c,b,s,q,?]
    > y
    did you alter function 'default::test_alias'? [y,n,l,c,b,s,q,?]
    > y
    ```

### 測試`test_alias`
``` sql title="scenes/scene03/query.edgeql"
# 1st migration needs to be applied before running this query
--8<-- "scenes/scene03/_internal/query.edgeql:test_alias"
```

### `update` `lau`
假設建明由學校畢業至1994年間，官階為`PC`。
``` sql title="scenes/scene03/query.edgeql"
--8<-- "scenes/scene03/_internal/query.edgeql:update_lau"
```
### `insert` `ChenLauContact`
``` sql title="scenes/scene03/query.edgeql"
--8<-- "scenes/scene03/_internal/query.edgeql:insert_chenlaucontact"
```

### 建立`Archive`及`CriminalRecord`
我們需要一個`object type`來記錄永仁的犯罪記錄。我們選擇建立一個`abstract object type` `Archive`，並建立一個`object type` `CriminalRecord`來`extending` `Archive`。

`CriminalRecord`有四個`property`及一個`multi link`：

* `ref_no` `property`為必填的檔案編號，並使用`constraint exclusive`，確保此編號不會重覆。
* `code` `property`為必填的犯罪代碼。
* `involved` `multi link`為一眾涉案人等。
* `created_at` `property`為檔案建立時間。使用[`rewrite`](https://www.edgedb.com/docs/datamodel/mutation_rewrites)在`insert`時，以[`datetime_of_statement()`](https://www.edgedb.com/docs/stdlib/datetime#function::std::datetime_of_statement)為預設值。此外，我們還加上`readonly := true`的限制，這麼一來就無法修改檔案的建立時間。
* `modified_at` `property`為檔案修改時間。使用`rewrite`在`update`時，自動以`datetime_of_statement()`覆寫。

``` sql title="scenes/scene03/schema.esdl"
--8<-- "scenes/scene03/_internal/schema.esdl:abstract_object_type_Archive"

--8<-- "scenes/scene03/_internal/schema.esdl:object_type_CriminalRecord"
```

??? danger "make end migration here（`scenes/scene03/schema.esdl`）"
    ``` sql
    did you create object type 'default::Archive'? [y,n,l,c,b,s,q,?]
    > y
    did you create object type 'default::CriminalRecord'? [y,n,l,c,b,s,q,?]
    > y
    ```

### `insert` `CriminalRecord`
我們選擇使用[`tuple`](https://www.edgedb.com/docs/stdlib/tuple#type::std::tuple)搭配[`for-loop`](https://www.edgedb.com/docs/edgeql/for#for)來`insert`片中出現的兩次犯罪記錄，這個模式在EdgeDB中稱為[bulk inserts](https://www.edgedb.com/docs/edgeql/for#bulk-inserts)。

* 於`with`區塊中，建立一個`records` `set`，裡面有兩個`tuple`代表兩次犯罪記錄。`tuple`的第一個元素為`ref_no`，而第二個元素為`code`。
* 接著使用`for-loop` + `union` + (`insert` `CriminalRecord`)的語法，來`insert`兩次犯罪記錄。我們可以使用`.0`來取得`tuple`的第一個元素、`.1`來取得`tuple`的第二個元素，依此類推。

``` sql title="scenes/scene03/query.edgeql"
# end migration needs to be applied before running this query
--8<-- "scenes/scene03/_internal/query.edgeql:for_loop_insert_criminalrecord"
```
!!! warning "記得加上`union (...)`"
    剛開始接觸`for-loop`語法時，很容易會忘記加上`union`。此外，`union`後面接的是`()`而非`{}`，這也是一個常會犯錯的地方。 
??? example "也可以使用named tuple的語法"
    ``` sql
    with records:= {(ref_no:= "CCR9314768", code:= "OFFNCE: A.O.A.B.H   "), (ref_no:= "RN992317", code:= "CD-POD   ")},
    for record in records
    union (insert CriminalRecord {
                    ref_no:= record.ref_no, 
                    code:= record.code,
                    involved:= chen,
    });
    ```
??? info "如果`insert`順序很重要"
    由於`set`是無序的，所以`insert`的順序並不能保證。如果想要有確定的`insert`順序，需要搭配`array`與[`range_unpack`](https://www.edgedb.com/docs/stdlib/range#function::std::range_unpack)。
    ``` sql
    with records:= [("CCR9314768", "OFFNCE: A.O.A.B.H   "), ("RN992317", "CD-POD   ")],
        record_len:= len(records),
    for i in range_unpack(range(0, record_len))
    union (insert CriminalRecord {
                    ref_no:= array_get(records, i).0, 
                    code:= array_get(records, i).1, 
                    involved:= chen,
    });
    ```    
    其原理是`array`是有序的，可以使用[`array_get`](https://www.edgedb.com/docs/stdlib/array#function::std::array_get)來索引，而`range_unpack`可以有序地返回`range`內的值。不過，這樣的需求應該不太常見。

### `select` `CriminalRecord {**}`
我們可以使用[`splats`](https://www.edgedb.com/docs/edgeql/select#splats)的語法，來看看兩次`insert`是否成功。
??? question "`select type {*}` vs `select type {**}`"
    * `select type {*}`可以列出一個`type`的所有`property`。
    * `select type {**}`除了可以列出`select type {*}`所列出的，還可以列出`type`所有的`link type`（但只會列出一層深度，不會遞迴全部列出）。

``` sql title="scenes/scene03/query.edgeql"
--8<-- "scenes/scene03/_internal/query.edgeql:select_criminalrecord_2stars_1"
```

```
{
  default::CriminalRecord {
    id: 740a4c4c-bc4b-11ee-b314-afc01e783d2e,
    code: 'OFFNCE: A.O.A.B.H   ',
    created_at: <datetime>'2024-01-26T13:04:35.046364Z',
    modified_at: {},
    ref_no: 'CCR9314768',
    involved: {
      default::PoliceSpy {
        nickname: '仁哥',
        name: '陳永仁',
        eng_name: {},
        id: db49a9aa-bc48-11ee-aae4-4fe16706e7ad,
        classic_lines: {},
      },
    },
  },
  default::CriminalRecord {
    id: 740a56ce-bc4b-11ee-b314-bf9055e83044,
    code: 'CD-POD   ',
    created_at: <datetime>'2024-01-26T13:04:35.046364Z',
    modified_at: {},
    ref_no: 'RN992317',
    involved: {
      default::PoliceSpy {
        nickname: '仁哥',
        name: '陳永仁',
        eng_name: {},
        id: db49a9aa-bc48-11ee-aae4-4fe16706e7ad,
        classic_lines: {},
      },
    },
  },
}
```
從上述結果可以觀察到：

* `created_at`自動於`insert`時，產生檔案建立時間了。
* 因為我們還沒有對檔案`update`，所以`modified_at`為空`set`。
* 我們在輸入`code` `property`時，在其後多加了許多空格，讓我們學習如何`update`吧。

??? info "Timezone"
    不知道您有沒有注意到因為`created_at`與`modified_at`為`datetime`型態，所以其是帶有`timezone`資訊的（預設是`UTC`）。
    或許您會有衝動想要將其轉為香港當地時間，但當時香港仍是英國殖民地，或許所有犯罪記錄會以英國時區的`UTC`儲存在英國伺服器。
    Who knows? 讓我們暫時接受這個設定，即使它可能是個美麗的錯誤。

### `update` `CriminalRecord`
`for-loop`除了可以用在`insert`外，也能夠用在`update`。
由於`code` `property`是`str`型態，經過翻找文件之後，我們發現[`str_trim_end`](https://www.edgedb.com/docs/stdlib/string#function::std::str_trim_end)正好可以滿足需求。
``` sql title="scenes/scene03/query.edgeql"
--8<-- "scenes/scene03/_internal/query.edgeql:for_loop_update_criminalrecord"
```

### 再次`select` `CriminalRecord {**}`
``` sql title="scenes/scene03/query.edgeql"
--8<-- "scenes/scene03/_internal/query.edgeql:select_criminalrecord_2stars_2"
```

```
{
  default::CriminalRecord {
    id: 740a4c4c-bc4b-11ee-b314-afc01e783d2e,
    code: 'OFFNCE: A.O.A.B.H',
    created_at: <datetime>'2024-01-26T13:04:35.046364Z',
    modified_at: <datetime>'2024-01-26T13:05:35.533826Z',
    ref_no: 'CCR9314768',
    involved: {
      default::PoliceSpy {
        nickname: '仁哥',
        name: '陳永仁',
        eng_name: {},
        id: db49a9aa-bc48-11ee-aae4-4fe16706e7ad,
        classic_lines: {},
      },
    },
  },
  default::CriminalRecord {
    id: 740a56ce-bc4b-11ee-b314-bf9055e83044,
    code: 'CD-POD',
    created_at: <datetime>'2024-01-26T13:04:35.046364Z',
    modified_at: <datetime>'2024-01-26T13:05:35.533826Z',
    ref_no: 'RN992317',
    involved: {
      default::PoliceSpy {
        nickname: '仁哥',
        name: '陳永仁',
        eng_name: {},
        id: db49a9aa-bc48-11ee-aae4-4fe16706e7ad,
        classic_lines: {},
      },
    },
  },
}
```
從上述結果可以觀察到：

* `created_at`並沒有變動。
* `modified_at`自動於`update`時更新。
* 使用`str_trim_end`成功去除了`code` `property`後的多餘空格。

### 學習使用`backlinks`
假設現在我們想知道永仁有哪些犯罪記錄，但是卻不想從`CriminalRecord`下手的話，[`backlinks`](https://www.edgedb.com/docs/edgeql/paths#backlinks)是一個不錯的選擇。

由於`CriminalRecord`中的`involved`是個`multi link`，連接了`involved`及`Character`。`backlinks`讓我們可以反向來對這種關係進行query：

* [`[is type]`](https://www.edgedb.com/docs/stdlib/set#operator::isintersect)讓我們指定要尋找哪一個`type`下的`link`。
* `.<link`是指`[is type]`這個`type`下的哪一個`link`。

``` sql title="scenes/scene03/query.edgeql"
--8<-- "scenes/scene03/_internal/query.edgeql:criminalrecord_backlink1"
```

??? example "上面這段query的白話文"
    從`CriminalRecord`的`involved` `link`中，找出跟`chen`有關的`CriminalRecord`，命名為`criminal_records`，並使用`{**}`列出結果。

```
{
  default::PoliceSpy {
    criminal_records: {
      default::CriminalRecord {
        id: 740a4c4c-bc4b-11ee-b314-afc01e783d2e,
        code: 'OFFNCE: A.O.A.B.H',
        created_at: <datetime>'2024-01-26T13:04:35.046364Z',
        modified_at: <datetime>'2024-01-26T13:05:35.533826Z',
        ref_no: 'CCR9314768',
        involved: {
          default::PoliceSpy {
            nickname: '仁哥',
            name: '陳永仁',
            eng_name: {},
            id: db49a9aa-bc48-11ee-aae4-4fe16706e7ad,
            classic_lines: {},
          },
        },
      },
      default::CriminalRecord {
        id: 740a56ce-bc4b-11ee-b314-bf9055e83044,
        code: 'CD-POD',
        created_at: <datetime>'2024-01-26T13:04:35.046364Z',
        modified_at: <datetime>'2024-01-26T13:05:35.533826Z',
        ref_no: 'RN992317',
        involved: {
          default::PoliceSpy {
            nickname: '仁哥',
            name: '陳永仁',
            eng_name: {},
            id: db49a9aa-bc48-11ee-aae4-4fe16706e7ad,
            classic_lines: {},
          },
        },
      },
    },
  },
}
```

如果想知道全部`Character`的`CriminalRecord`，query可以這麼寫：
``` sql title="scenes/scene03/query.edgeql"
--8<-- "scenes/scene03/_internal/query.edgeql:criminalrecord_backlink2"
```
??? tip "加上易辨別的`property`"
    由於現在是對`Character`進行query（不是明確的`chen`了），加上`name`的話會比較好辨別，否則只能看到每個`Character`的`criminal_records`。

```
{
  default::GangsterBoss {name: '韓琛', criminal_records: {}},
  default::Police {name: '黃志誠', criminal_records: {}},
  default::PoliceSpy {
    name: '陳永仁',
    criminal_records: {
      default::CriminalRecord {
        id: 740a4c4c-bc4b-11ee-b314-afc01e783d2e,
        code: 'OFFNCE: A.O.A.B.H',
        created_at: <datetime>'2024-01-26T13:04:35.046364Z',
        modified_at: <datetime>'2024-01-26T13:05:35.533826Z',
        ref_no: 'CCR9314768',
        involved: {
          default::PoliceSpy {
            nickname: '仁哥',
            name: '陳永仁',
            eng_name: {},
            id: db49a9aa-bc48-11ee-aae4-4fe16706e7ad,
            classic_lines: {},
          },
        },
      },
      default::CriminalRecord {
        id: 740a56ce-bc4b-11ee-b314-bf9055e83044,
        code: 'CD-POD',
        created_at: <datetime>'2024-01-26T13:04:35.046364Z',
        modified_at: <datetime>'2024-01-26T13:05:35.533826Z',
        ref_no: 'RN992317',
        involved: {
          default::PoliceSpy {
            nickname: '仁哥',
            name: '陳永仁',
            eng_name: {},
            id: db49a9aa-bc48-11ee-aae4-4fe16706e7ad,
            classic_lines: {},
          },
        },
      },
    },
  },
  default::GangsterSpy {name: '劉建明', criminal_records: {}},
}
```

### `insert`此場景的`Scene`
``` sql title="scenes/scene03/query.edgeql"
--8<-- "scenes/scene03/_internal/query.edgeql:insert_scene"
```

## Query review
??? Success "Query review"
    ``` sql title="scenes/scene03/query.edgeql"
    --8<-- "scenes/scene03/query.edgeql"
    ```

## 無間假設
我們假設無間道內警察只會在同一個地方辦公，即`police_station`這個`alias`。從建明與黃sir的對話來看，大多數警察辦公場景應該是在警察總部。

## 無間吹水
假設建明於1994年仍是散仔（`PC`），其於劇中識別證之更換時間為1999年7月30日，時任高級督察（`SIP`），在四~五年間連升數級，這又是一個如葉校長般的人物呀。