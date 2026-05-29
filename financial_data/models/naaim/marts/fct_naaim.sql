with staged as (

    select * from {{ ref('stg_naaim') }}

),

enriched as (

    select
        report_date,
        mean_average,
        most_bearish_response,
        quart_1_25_at_below,
        quart_2_median,
        quart_3_25_at_above,
        most_bullish_response,
        standard_deviation,
        naaim_number,
        sp500_close,
        case
            when naaim_number < 50 then 'bearish'
            when naaim_number <= 100 then 'long'
            else 'leveraged_long'
        end as exposure_zone,
        lag(naaim_number) over (order by report_date) as prior_naaim_number,
        lag(sp500_close) over (order by report_date) as prior_sp500_close,
        naaim_number - lag(naaim_number) over (order by report_date) as naaim_wow_change,
        sp500_close - lag(sp500_close) over (order by report_date) as sp500_wow_change
    from staged
    order by report_date

)

select *
from enriched
