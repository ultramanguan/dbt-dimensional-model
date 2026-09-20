with person_history as (
    select
        business_entity_id,
        concat(coalesce(first_name, ''), ' ', coalesce(middle_name, ''), ' ', coalesce(last_name, '')) as full_name,
        dbt_valid_from,
        dbt_valid_to
    from {{ ref('scd_person_snapshot') }}
),

stg_customer as (
    select
        customer_id,
        person_id,
        store_id
    from {{ ref('stg_sales__customer') }}
),

stg_store as (
    select
        business_entity_id as store_business_entity_id,
        store_name
    from {{ ref('stg_sales__store') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['stg_customer.customer_id', 'person_history.dbt_valid_from']) }} as customer_scd2_key,
    stg_customer.customer_id,
    person_history.business_entity_id,
    person_history.full_name,
    stg_store.store_business_entity_id,
    stg_store.store_name,
    person_history.dbt_valid_from as valid_from,
    person_history.dbt_valid_to as valid_to,
    (person_history.dbt_valid_to is null) as is_current
from stg_customer
inner join person_history on stg_customer.person_id = person_history.business_entity_id
left join stg_store on stg_customer.store_id = stg_store.store_business_entity_id
