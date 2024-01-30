---
tags:
  - sequence
  - index
  - array
  - tuple
---

# 事

??? "Full schema preview"
    ``` sql title="initial_schema/entity/entity.esdl"
    --8<-- "initial_schema/entity/entity.esdl"
    ```

## Scalar types
### SceneNumber
`SceneNumber` `extending` `sequence`而來，作為場景的計數器。需要留意的是[每一個`sequence`可以被多個`property`呼叫，共享同一個計數器](https://www.edgedb.com/docs/stdlib/sequence#type::std::sequence)。如果單一`property`需要獨立的計數器，需要個別`extending` `sequence`生成特定的`sequence`。


``` sql
--8<-- "initial_schema/entity/_internal/entity.esdl:scalar_type_SceneNumber"
```
## Abstract Object types
### Event
`Event`有一個`detail` `property`及三個`multi` `link`用來協助記錄相關的人時地。由於`when`是`EdgeDB`語法的關鍵字，所以必須使用加上backtick的\`when\`。

``` sql
--8<-- "initial_schema/entity/_internal/entity.esdl:abstract_object_type_Event"
```

## Object types
### Scene
`Scene` `extending` `Event`而來，用來記錄各場景資訊，其有四個`property`：

* `title` `property`為標題。
* `remarks` `property`為註解。
* `references` `property`為參考資料連結。
* `scene_number` `property`為自動產生編號的計數器。
    * `constraint exclusive`確保不會有重覆的編號。
    * [`sequence_next()`](https://www.edgedb.com/docs/stdlib/sequence#function::std::sequence_next)作為`scene_number`的`default`，可以在每次生成新`Scene`時，自動產生編號。其中`introspect`是不可省略的關鍵字，原因是`sequence_next()`接收的參數必須是`ScalarType`。詳細的說明可以參考[Easy EdgeDB chapter13](https://www.edgedb.com/easy-edgedb/chapter13#the-sequence-type)。

此外，由於我們可能會常順向或逆向存取`Scene`，所以替`scene_number`加上了`index`。

``` sql
--8<-- "initial_schema/entity/_internal/entity.esdl:object_type_Scene"
```