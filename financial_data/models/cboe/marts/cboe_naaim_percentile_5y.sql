with base as (

    select * from {{ ref('fct_cboe') }}

),

-- For each row, compute percent_rank of equity_call_put_ratio within the 5-year window
-- ending on that row's own report_date (rolling, not anchored to today).
-- percent_rank = rows with equity_call_put_ratio strictly less than current / (total rows - 1)
rolling_percentile as (

    select
        a.report_date,
        a.equity_call_put_ratio,
        count(*) filter (
            where b.equity_call_put_ratio < a.equity_call_put_ratio
        )::numeric
        / nullif(count(*) - 1, 0) as equity_call_put_ratio_percentile_5y
    from base a
    join base b
        on b.report_date between a.report_date - interval '5 years' and a.report_date
    group by a.report_date, a.equity_call_put_ratio

),

latest_100 as (

    select report_date
    , equity_put_call_ratio, equity_call_put_ratio
    from base
    order by report_date desc
    limit 100

)

select
    p.report_date,
    l.equity_put_call_ratio,
    l.equity_call_put_ratio,
    round(p.equity_call_put_ratio_percentile_5y, 4) as equity_call_put_ratio_percentile_5y
from rolling_percentile p
inner join latest_100 l using (report_date)
order by p.report_date
