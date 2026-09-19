with stg_salesorderheader as (
    select distinct credit_card_id
    from {{ ref('stg_sales__salesorderheader') }}
    where credit_card_id is not null
),

stg_creditcard as (
    select *
    from {{ ref('stg_sales__creditcard') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['stg_salesorderheader.credit_card_id']) }} as creditcard_key,
    stg_salesorderheader.credit_card_id,
    stg_creditcard.card_type
from stg_salesorderheader
left join stg_creditcard on stg_salesorderheader.credit_card_id = stg_creditcard.credit_card_id
