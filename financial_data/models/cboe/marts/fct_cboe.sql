with staged as (

    select * from {{ ref('stg_cboe') }}

),

latest as (

    select max(report_date) as report_date
    from staged

),

filtered as (

    select
        s.report_date,
        s.equity_put_call_ratio,
        s.equity_call_put_ratio
    from staged s
    cross join latest l
    where s.report_date >= date '2020-01-01'
      and (
          extract(isodow from s.report_date) = 5
          or s.report_date = l.report_date
      )

)

select *
from filtered
order by report_date
