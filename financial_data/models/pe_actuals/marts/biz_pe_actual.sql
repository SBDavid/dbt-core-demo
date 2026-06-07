with price_filtered as (

    select
        report_date,
        price
    from {{ ref('fct_sp_500_price') }}
    where report_date >= (
        select max(report_date) - interval '5 years'
        from {{ ref('fct_sp_500_price') }}
    )

),

price_with_quarter as (

    select
        report_date,
        price,
        extract(year from report_date)::int as date_year,
        ceil(extract(month from report_date) / 3.0)::int as date_quarter,
        extract(year from report_date)::int * 4
            + ceil(extract(month from report_date) / 3.0)::int as quarter_seq
    from price_filtered

),

eps as (

    select
        date_year,
        date_quarter,
        eps_actuals_ttm,
        date_year * 4 + date_quarter as quarter_seq
    from {{ ref('fct_eps_actuals_ttm') }}

)

select
    p.report_date,
    p.price,
    e.date_year as eps_date_year,
    e.date_quarter as eps_date_quarter,
    e.eps_actuals_ttm,
    p.price / e.eps_actuals_ttm as pe_actual
from price_with_quarter p
left join lateral (
    select
        date_year,
        date_quarter,
        eps_actuals_ttm
    from eps
    where quarter_seq <= p.quarter_seq
    order by quarter_seq desc
    limit 1
) e on true
where e.eps_actuals_ttm is not null
order by p.report_date
