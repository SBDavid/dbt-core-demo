with staged as (

    select * from {{ ref('stg_cboe') }}

),

filtered as (

    select
        report_date,
        equity_put_call_ratio,
        equity_call_put_ratio
    from staged
    where report_date >= date '2020-01-01'
      and extract(isodow from report_date) = 5

)

select *
from filtered
order by report_date
