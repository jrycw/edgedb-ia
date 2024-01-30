---
tags:
  - constraint
  - trigger
  - exists 
  - assert_exists
---

# 時

??? "Full schema preview"
    ``` sql title="initial_schema/time/time.esdl"
    --8<-- "initial_schema/time/time.esdl"
    ```

## Scalar types
### DayOfWeek
`DayOfWeek`代表一星期內七天。
``` sql
--8<-- "initial_schema/time/_internal/time.esdl:scalar_type_DayOfWeek"
```

### FuzzyYear
`FuzzyYear`直接`extending` `int64`。
``` sql
--8<-- "initial_schema/time/_internal/time.esdl:scalar_type_FuzzyYear"
```

### FuzzyMonth
`FuzzyMonth` `extending` `int64`後，再加上一個`constraint`，限制其值只能為1~12。
``` sql
--8<-- "initial_schema/time/_internal/time.esdl:scalar_type_FuzzyMonth"
```

### FuzzyDay
`FuzzyDay` `extending` `int64`後，再加上一個`constraint`，限制其值只能為1~31。
``` sql
--8<-- "initial_schema/time/_internal/time.esdl:scalar_type_FuzzyDay"
```

### FuzzyHour
`FuzzyHour` `extending` `int64`後，再加上一個`constraint`，限制其值只能為0~23。
``` sql
--8<-- "initial_schema/time/_internal/time.esdl:scalar_type_FuzzyHour"
```

### FuzzyMinute
`FuzzyMinute` `extending` `int64`後，再加上一個`constraint`，限制其值只能為0~59。
``` sql
--8<-- "initial_schema/time/_internal/time.esdl:scalar_type_FuzzyMinute"
```

### FuzzySecond
`FuzzySecond` `extending` `int64`後，再加上一個`constraint`，限制其值只能為0~59。
``` sql
--8<-- "initial_schema/time/_internal/time.esdl:scalar_type_FuzzySecond"
```

## Object types

### FuzzyTime
`FuzzyTime`除了包含前述七個`scalar type`為`property`外，還加了一個`fuzzy_fmt` `property`，一個`trigger`及一個`constraint`。

``` sql
--8<-- "initial_schema/time/_internal/time.esdl:object_type_FuzzyTime"
```
#### fuzzy_fmt
`fuzzy_fmt`為`computed property`，為一特殊的`str`格式來表達每個`FuzzyTime object`。其中`??`是指當該`scalar type`為空的`set`時（即`<str>{}`），所給予的[預設值](https://www.edgedb.com/docs/stdlib/string#date-and-time-formatting-options)。

#### trigger
當同時給定`fuzzy_month`及`fuzzy_day`時，我們可以透過`cal::to_local_date`來驗證這樣的月份與日期，是否為一有效的組合。

逐步拆解各部份語法：

* `fuzzy_month_day_check`為此`trigger`名字，可自行定義。`after`至`for each`中間，輸入想要`trigger`的類型。本例中是想要當對`FuzzyTime`進行`insert`及`update`時，才會觸發`trigger`。
``` sql
trigger fuzzy_month_day_check after insert, update for each
``` 

* `when`為選擇性條件，當其後`expression`為`true`時，才會觸發`trigger`。其中`__new__`是指我們想要`insert`或`update`的`object`。
``` sql
when (exists __new__.fuzzy_month and exists __new__.fuzzy_day) 
```

* `do`為這個`trigger`想要執行的內容。我們這裡使用`assert_exists`搭配`cal::to_local_date`來驗證給定的月份及日期組合是否合理。當沒有給定年份時，使用`??`語法指定為無間道主要劇情時間的2002年。由於我們的`fuzzy_day`已經被`FuzzyDay`限制在1~31之間，所以這個`trigger`可以幫我們去除掉`2/30`、`2/31`、`4/31`、`6/31`、`9/31`、`11/31`等不合理的時間，至於沒有給定年份的`2/29`是無法生成的（因為2002年不是閏年）。如果真的要生成`2/29`這麼特別的日子，需強制加上年份來鑒別其是否為一合理的時間。
``` sql
do ( 
    assert_exists(
        cal::to_local_date(__new__.fuzzy_year ?? 2002, __new__.fuzzy_month, __new__.fuzzy_day),
        ) 
);
```
另外，當您使用略為超過合理時間的日期(如`4/31`)，`cal::to_local_date`報錯訊息會和一般情況不太一樣，會貼心地提示您這個日期剛好超出合理區間。

!!! failure "`cal::to_local_date`報錯訊息"

    === "4/31"
        ```
          edgedb error: InvalidValueError: cal::local_date field value out of range: 2002-04-31
        ```
    === "4/40" 
        ```
          edgedb error: ConstraintViolationError: invalid FuzzyDay
            Detail: invalid scalar type 'default::FuzzyDay'
        ```

#### constraint
針對`fuzzy_fmt` `property`加上`exclusive`後，可以確保當使用`FuzzyTime`時，不會生成一個以上可以表達同一模糊時間的`FuzzyTime object`。