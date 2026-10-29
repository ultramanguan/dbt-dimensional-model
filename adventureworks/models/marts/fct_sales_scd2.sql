-- Point-in-time sales fact: each order line is joined to the version of the customer
-- that was valid on the order date. Customers with no person record (e.g. store accounts)
-- or orders placed before the person record existed get a null customer_scd2_key.
with stg_salesorderheader as (
    select
        sales_order_id,
        customer_id,
        order_date
    from {{ ref('stg_sales__salesorderheader') }}
),

stg_salesorderdetail as (
    select
        sales_order_id,
        sales_order_detail_id,
        order_qty,
        unit_price,
        unit_price * order_qty as revenue
    from {{ ref('stg_sales__salesorderdetail') }}
),

dim_customer_scd2 as (
    select
        customer_scd2_key,
        customer_id,
        valid_from,
        valid_to
    from {{ ref('dim_customer_scd2') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['stg_salesorderdetail.sales_order_id', 'stg_salesorderdetail.sales_order_detail_id']) }} as sales_key,
    dim_customer_scd2.customer_scd2_key,
    stg_salesorderheader.customer_id,
    stg_salesorderheader.order_date,
    stg_salesorderdetail.sales_order_id,
    stg_salesorderdetail.sales_order_detail_id,
    stg_salesorderdetail.unit_price,
    stg_salesorderdetail.order_qty,
    stg_salesorderdetail.revenue
from stg_salesorderdetail
inner join stg_salesorderheader on stg_salesorderdetail.sales_order_id = stg_salesorderheader.sales_order_id
left join dim_customer_scd2
    on stg_salesorderheader.customer_id = dim_customer_scd2.customer_id
    and stg_salesorderheader.order_date >= dim_customer_scd2.valid_from
    and (stg_salesorderheader.order_date < dim_customer_scd2.valid_to or dim_customer_scd2.valid_to is null)
