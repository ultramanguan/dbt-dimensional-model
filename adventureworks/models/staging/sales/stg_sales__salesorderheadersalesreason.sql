select
    salesorderid as sales_order_id,
    salesreasonid as sales_reason_id,
    modifieddate as modified_date
from {{ ref('salesorderheadersalesreason') }}
