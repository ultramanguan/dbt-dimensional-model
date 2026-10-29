{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='sales_key',
        cluster_by=['order_date'],
        on_schema_change='append_new_columns'
    )
}}

with stg_salesorderheader as (
    select
        sales_order_id,
        customer_id,
        credit_card_id,
        ship_to_address_id,
        order_status,
        order_date,
        modified_date as header_modified_date
    from {{ ref('stg_sales__salesorderheader') }}
),

stg_salesorderdetail as (
    select
        sales_order_id,
        sales_order_detail_id,
        product_id,
        order_qty,
        unit_price,
        unit_price * order_qty as revenue,
        modified_date as detail_modified_date
    from {{ ref('stg_sales__salesorderdetail') }}
),

dim_customer as (
    select
        customer_id,
        customer_key,
        valid_from,
        valid_to
    from {{ ref('dim_customer') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['stg_salesorderdetail.sales_order_id', 'sales_order_detail_id']) }} as sales_key,
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_key,
    dim_customer.customer_key,
    {{ dbt_utils.generate_surrogate_key(['credit_card_id']) }} as creditcard_key,
    {{ dbt_utils.generate_surrogate_key(['ship_to_address_id']) }} as ship_address_key,
    {{ dbt_utils.generate_surrogate_key(['order_status']) }} as order_status_key,
    {{ dbt_utils.generate_surrogate_key(['order_date']) }} as order_date_key,
    stg_salesorderheader.order_date,
    greatest(stg_salesorderheader.header_modified_date, stg_salesorderdetail.detail_modified_date) as modified_date,
    stg_salesorderdetail.sales_order_id,
    stg_salesorderdetail.sales_order_detail_id,
    stg_salesorderdetail.unit_price,
    stg_salesorderdetail.order_qty,
    stg_salesorderdetail.revenue
from stg_salesorderdetail
inner join stg_salesorderheader on stg_salesorderdetail.sales_order_id = stg_salesorderheader.sales_order_id
-- point-in-time lookup: the customer version that was valid on the order date
left join dim_customer
    on stg_salesorderheader.customer_id = dim_customer.customer_id
    and stg_salesorderheader.order_date >= dim_customer.valid_from
    and (stg_salesorderheader.order_date < dim_customer.valid_to or dim_customer.valid_to is null)
{% if is_incremental() %}
-- only reprocess rows changed since the last run, minus a lookback window for late updates
where greatest(stg_salesorderheader.header_modified_date, stg_salesorderdetail.detail_modified_date)
    >= (select dateadd(day, -{{ var('fct_sales_lookback_days', 3) }}, max(modified_date)) from {{ this }})
{% endif %}
