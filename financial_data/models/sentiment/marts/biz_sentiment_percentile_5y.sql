with base as (

    select * from {{ ref('fct_sentiment') }}

),

-- For each row, compute percent_rank of mean_average within the 5-year window
-- ending on that row's own report_date (rolling, not anchored to today).
-- percent_rank = rows with mean_average strictly less than current / (total rows - 1)
rolling_percentile as (

    select
        a.report_date,
        a.bull_bear_spread,
        count(*) filter (
            where b.bull_bear_spread < a.bull_bear_spread
        )::numeric
        / nullif(count(*) - 1, 0) as bull_bear_spread_percentile_5y
    from base a
    join base b
        on b.report_date between a.report_date - interval '5 years' and a.report_date
    group by a.report_date, a.bull_bear_spread

),

latest_100 as (

    select *
    from base
    order by report_date desc
    limit 100

)

select
    p.report_date,
    l.bullish,
    l.neutral,
    l.bearish,
    l.bull_bear_spread,
    round(p.bull_bear_spread_percentile_5y, 4) as bull_bear_spread_percentile_5y
from rolling_percentile p
inner join latest_100 l using (report_date)
order by p.report_date
