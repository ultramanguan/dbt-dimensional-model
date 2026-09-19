select
    businessentityid as business_entity_id,
    storename as store_name,
    salespersonid as salesperson_id,
    modifieddate as modified_date
from {{ ref('store') }}
