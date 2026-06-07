with staged as (

    select * from {{ ref('stg_eps_actuals') }}

),

enriched as (

    select
        date_year,
        date_quarter,
        eps_actuals,
        sum(eps_actuals) over (
            order by date_year, date_quarter
            rows between 3 preceding and current row
        ) as eps_actuals_ttm
    from staged

)

select *
from enriched
order by date_year, date_quarter
