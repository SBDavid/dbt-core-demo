with base as (

    select * from {{ ref('fct_naaim') }}

),

-- For each row, compute percent_rank of mean_average within the 5-year window
-- ending on that row's own report_date (rolling, not anchored to today).
-- percent_rank = rows with mean_average strictly less than current / (total rows - 1)
rolling_percentile as (

    select
        a.report_date,
        a.mean_average,
        count(*) filter (
            where b.mean_average < a.mean_average
        )::numeric
        / nullif(count(*) - 1, 0) as mean_average_percentile_5y
    from base a
    join base b
        on b.report_date between a.report_date - interval '5 years' and a.report_date
    group by a.report_date, a.mean_average

),

latest_100 as (

    select report_date
    from base
    order by report_date desc
    limit 100

)

select
    p.report_date,
    p.mean_average,
    round(p.mean_average_percentile_5y, 4) as mean_average_percentile_5y
from rolling_percentile p
inner join latest_100 l using (report_date)
order by p.report_date desc
