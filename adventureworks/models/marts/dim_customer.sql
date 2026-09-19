with stg_customer as (
    select
        customer_id,
        person_id,
        store_id
    from {{ ref('stg_sales__customer') }}
),

stg_person as (
    select
        business_entity_id,
        concat(coalesce(first_name, ''), ' ', coalesce(middle_name, ''), ' ', coalesce(last_name, '')) as full_name
    from {{ ref('stg_person__person') }}
),

stg_store as (
    select
        business_entity_id as store_business_entity_id,
        store_name
    from {{ ref('stg_sales__store') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['stg_customer.customer_id']) }} as customer_key,
    stg_customer.customer_id,
    stg_person.business_entity_id,
    stg_person.full_name,
    stg_store.store_business_entity_id,
    stg_store.store_name
from stg_customer
left join stg_person on stg_customer.person_id = stg_person.business_entity_id
left join stg_store on stg_customer.store_id = stg_store.store_business_entity_id
