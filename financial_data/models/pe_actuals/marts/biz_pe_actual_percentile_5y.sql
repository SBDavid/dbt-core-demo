with base as (

    select * from {{ ref('biz_pe_actual') }}

),

-- For each row, compute percent_rank of pe_actual within the 5-year window
-- ending on that row's own report_date (rolling, not anchored to today).
-- percent_rank = rows with pe_actual strictly less than current / (total rows - 1)
rolling_percentile as (

    select
        a.report_date,
        a.pe_actual,
        count(*) filter (
            where b.pe_actual < a.pe_actual
        )::numeric
        / nullif(count(*) - 1, 0) as pe_actual_percentile_5y
    from base a
    join base b
        on b.report_date between a.report_date - interval '5 years' and a.report_date
    group by a.report_date, a.pe_actual

),

latest_10 as (

    select *
    from base
    order by report_date desc
    limit 10

)

select
    p.report_date,
    l.price,
    l.pe_actual,
    round(p.pe_actual_percentile_5y, 4) as pe_actual_percentile_5y
from rolling_percentile p
inner join latest_10 l using (report_date)
order by p.report_date
