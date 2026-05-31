with source as (

    select * from {{ ref('raw_cboe') }}

),

parsed as (

    select
        to_date(date, 'YYYY-MM-DD') as report_date,
        equity_put_call_ratio::numeric as equity_put_call_ratio,
        1 / equity_put_call_ratio::numeric as equity_call_put_ratio
    from source
    where equity_put_call_ratio != '0.0000'

)

select *
from parsed
where report_date is not null
  and equity_put_call_ratio is not null
