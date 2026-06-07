with source as (

    select * from {{ ref('raw_sp_500_price') }}

),

parsed as (

    select
        to_date("Date", 'MM/DD/YYYY') as report_date,
        replace("Price"::text, ',', '')::numeric as price,
        replace("Open"::text, ',', '')::numeric as open,
        replace("High"::text, ',', '')::numeric as high,
        replace("Low"::text, ',', '')::numeric as low
    from source

)

select *
from parsed
where report_date is not null
  and price is not null
