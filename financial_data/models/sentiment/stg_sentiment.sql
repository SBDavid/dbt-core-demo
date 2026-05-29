with source as (

    select * from {{ ref('raw_sentiment') }}

),

parsed as (

    select
        to_date("Date", 'MM-DD-YY') as report_date,
        "Bullish"::numeric as bullish,
        "Neutral"::numeric as neutral,
        "Bearish"::numeric as bearish
    from source

)

select *
from parsed
where report_date is not null
  and bullish is not null
