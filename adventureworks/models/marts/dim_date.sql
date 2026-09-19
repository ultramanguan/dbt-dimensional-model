with stg_date as (
    select * from {{ ref('stg_date__date') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['stg_date.date_day']) }} as date_key,
    *
from stg_date
