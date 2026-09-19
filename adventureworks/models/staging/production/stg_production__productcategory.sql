select
    productcategoryid as product_category_id,
    name as product_category_name,
    modifieddate as modified_date
from {{ ref('productcategory') }}
