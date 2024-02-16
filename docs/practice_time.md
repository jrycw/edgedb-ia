# 練習

!!! question "練習1"
    請寫一段query列出每個場景的`scene_number`、`title`及 `title`的長度（命名為`title_len`），並對`title_len`及`scene_number`作升冪排序。
??? info "練習1參考解答" 
    ``` sql
    select Scene {
        scene_number, 
        title, 
        title_len:= len(.title)} 
    order by (.title_len, .scene_number);
    ```
    ```
    {
        default::Scene {scene_number: 1, title: '韓琛初現', title_len: 4},
        default::Scene {scene_number: 3, title: '黑白顛倒', title_len: 4},
        default::Scene {scene_number: 7, title: '互猜底牌', title_len: 4},
        default::Scene {scene_number: 8, title: '誰是內鬼', title_len: 4},
        default::Scene {scene_number: 9, title: '真相大白', title_len: 4},
        default::Scene {scene_number: 2, title: '我想跟他換', title_len: 5},
        default::Scene {scene_number: 4, title: '被遺忘的時光', title_len: 6},
        default::Scene {scene_number: 10, title: '我想做個好人', title_len: 6},
        default::Scene {scene_number: 5, title: '三年之後又三年', title_len: 7},
        default::Scene {scene_number: 6, title: '有內鬼終止交易', title_len: 7},
    }
    ```

!!! question "練習2"
    請寫一個名為`is_higher_policerank`的`function`，其接收`id1`及`id2`兩個`<uuid>`型態的變數。當`id1`所屬`object`的`police_rank`高於`id2`所屬`object`的`police_rank`時，返回`true`，否則為`false`。此外：

    * 當`id1`及`id2`並非有效的`uuid`型態時，應該`raise InvalidValueError`。
    * 當`id1`及`id2`所屬`object`沒有具有`police_rank` `property`時，應該`raise CardinalityViolationError`。

??? info "練習2參考解答" 
    ``` sql
    function is_higher_policerank(id1: uuid, id2: uuid) -> bool
    using (     
        with p1:= (select <IsPolice>id1),
             p2:= (select <IsPolice>id2),
        select p1.police_rank ?? PoliceRank.Protected > 
               p2.police_rank ?? PoliceRank.Protected
    );
    ```