with source as (

    select * from {{ ref('raw_eps_actuals') }}

),

parsed as (

    select
        date_year::int as date_year,
        date_quarter::int as date_quarter,
        eps_actuals::numeric as eps_actuals
    from source

)

select *
from parsed
where date_year is not null
  and date_quarter is not null
  and eps_actuals is not null
