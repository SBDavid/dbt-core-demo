with staged as (

    select * from {{ ref('stg_sp_500_price') }}

)

select *
from staged