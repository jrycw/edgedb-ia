# --8<-- [start:function_is_hi_fi_store_open]
function is_hi_fi_store_open(dow: DayOfWeek, visit_hour: int64) -> bool
using (
    with open_hours:= multirange([range(11, 13), range(14, 19), range(20, 22)])
    select dow != DayOfWeek.Wednesday and contains(open_hours, visit_hour)
);
# --8<-- [end:function_is_hi_fi_store_open]

# --8<-- [start:function_test_hi_fi_store_open]
function test_hi_fi_store_open() -> bool
using (all({
        is_hi_fi_store_open(DayOfWeek.Monday, 12),
        is_hi_fi_store_open(DayOfWeek.Friday, 15),
        is_hi_fi_store_open(DayOfWeek.Saturday, 21),
    })
);
# --8<-- [end:function_test_hi_fi_store_open]

# --8<-- [start:function_test_hi_fi_store_close]
function test_hi_fi_store_close() -> bool 
using (not all({
        is_hi_fi_store_open(DayOfWeek.Wednesday, 12),
        is_hi_fi_store_open(DayOfWeek.Thursday, 13),
        is_hi_fi_store_open(DayOfWeek.Sunday, 19),
    })
);
# --8<-- [end:function_test_hi_fi_store_close]