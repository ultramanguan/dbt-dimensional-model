select
    salesorderid as sales_order_id,
    salesorderdetailid as sales_order_detail_id,
    productid as product_id,
    specialofferid as special_offer_id,
    orderqty as order_qty,
    unitprice as unit_price,
    unitpricediscount as unit_price_discount,
    rowguid as row_guid,
    modifieddate as modified_date
from {{ ref('salesorderdetail') }}
