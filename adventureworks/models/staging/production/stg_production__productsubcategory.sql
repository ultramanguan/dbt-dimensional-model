select
    productsubcategoryid as product_subcategory_id,
    productcategoryid as product_category_id,
    name as product_subcategory_name,
    modifieddate as modified_date
from {{ ref('productsubcategory') }}
