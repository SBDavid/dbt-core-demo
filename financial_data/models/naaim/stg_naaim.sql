with source as (

    select * from {{ ref('raw_naaim') }}

),

parsed as (

    select
        case
            when date ~ '月'
                then to_date(
                    '20' || (regexp_match(date, '-(\d+)$'))[1]
                    || '-'
                    || lpad((regexp_match(date, '-(\d+)月-'))[1], 2, '0')
                    || '-'
                    || lpad((regexp_match(date, '^(\d+)-'))[1], 2, '0'),
                    'YYYY-MM-DD'
                )
            else to_date(date, 'MM/DD/YY')
        end as report_date,
        mean_average::numeric as mean_average,
        most_bearish_response::numeric as most_bearish_response,
        quart_1_25_at_below::numeric as quart_1_25_at_below,
        quart_2_median::numeric as quart_2_median,
        quart_3_25_at_above::numeric as quart_3_25_at_above,
        most_bullish_response::numeric as most_bullish_response,
        standard_deviation::numeric as standard_deviation,
        naaim_number::numeric as naaim_number,
        sp_500::numeric as sp500_close
    from source

)

select *
from parsed
where report_date is not null
