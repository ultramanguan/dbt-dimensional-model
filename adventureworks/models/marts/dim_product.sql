with stg_product as (
    select *
    from {{ ref('stg_production__product') }}
),

stg_product_subcategory as (
    select *
    from {{ ref('stg_production__productsubcategory') }}
),

stg_product_category as (
    select *
    from {{ ref('stg_production__productcategory') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['stg_product.product_id']) }} as product_key,
    stg_product.product_id,
    stg_product.product_name,
    stg_product.product_number,
    stg_product.product_color,
    stg_product.product_class,
    stg_product_subcategory.product_subcategory_name,
    stg_product_category.product_category_name
from stg_product
left join stg_product_subcategory on stg_product.product_subcategory_id = stg_product_subcategory.product_subcategory_id
left join stg_product_category on stg_product_subcategory.product_category_id = stg_product_category.product_category_id
