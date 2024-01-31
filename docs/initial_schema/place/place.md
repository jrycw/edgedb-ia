---
tags:
  - required
  - delegated
---

# 地

??? "Full schema preview"
    ``` sql title="initial_schema/place/place.esdl"
    --8<-- "initial_schema/place/place.esdl"
    ```

## Abstract object types
`Place`為一抽象概念的`abstract object type`，只有一個必填的`name` `property`。其有一個`delegated constraint exclusive`的`constraint`，這與`constraint exclusive`不同。如果加上`delegated`，代表`exclusive`是會施加在後續各個`extending` `Place`的`object type`上。

舉例來說，假如`Landmark`和`Location`都`extending` `Place`，而我們想生成一個名叫`有間客棧`的`object`。

* 使用`delegated constraint exclusive`，可以讓我們**同時生成**一個`name`為`有間客棧`的`Landmark`及一個`name`為`有間客棧`的`Location`。

* 使用`constraint exclusive`，只能生成一個`name`為`有間客棧`的`Landmark`**或**一個`name`為`有間客棧`的`Location`。


### Place 
``` sql
--8<-- "initial_schema/place/_internal/place.esdl:abstract_object_type_Place"
```

## Object types
### Landmark 
`Landmark`用來代表知名度較高的地標。
``` sql
--8<-- "initial_schema/place/_internal/place.esdl:object_type_Landmark"
```

### Location 
`Location`用來代表一般地點。
``` sql
--8<-- "initial_schema/place/_internal/place.esdl:object_type_Location"
```

### Store 
`Store`用來代表店鋪。
``` sql
--8<-- "initial_schema/place/_internal/place.esdl:object_type_Store"
```