with staged as (

    select * from {{ ref('stg_sentiment') }}

),

enriched as (

    select
        report_date,
        bullish,
        neutral,
        bearish,
        bullish - bearish as bull_bear_spread,
        case
            when bullish - bearish > 0.15 then 'bullish'
            when bullish - bearish < -0.15 then 'bearish'
            else 'neutral'
        end as sentiment_zone
    from staged
    order by report_date

)

select *
from enriched
