-- Type 2 customer dimension: one row per customer per version of the linked person record.
-- Customers with no person history get a single row. The first version of every customer
-- starts at 1900-01-01 so orders placed before the first recorded change still find a version.
with stg_customer as (
    select
        customer_id,
        person_id,
        store_id
    from {{ ref('stg_sales__customer') }}
),

person_history as (
    select
        business_entity_id,
        concat(coalesce(first_name, ''), ' ', coalesce(middle_name, ''), ' ', coalesce(last_name, '')) as full_name,
        dbt_valid_from,
        dbt_valid_to
    from {{ ref('scd_person_snapshot') }}
),

stg_store as (
    select
        business_entity_id as store_business_entity_id,
        store_name
    from {{ ref('stg_sales__store') }}
),

customer_versions as (
    select
        stg_customer.customer_id,
        stg_customer.store_id,
        person_history.business_entity_id,
        person_history.full_name,
        case
            when person_history.dbt_valid_from is null
                or row_number() over (partition by stg_customer.customer_id order by person_history.dbt_valid_from) = 1
                then cast('1900-01-01' as timestamp)
            else person_history.dbt_valid_from
        end as valid_from,
        person_history.dbt_valid_to as valid_to
    from stg_customer
    left join person_history on stg_customer.person_id = person_history.business_entity_id
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_versions.customer_id', 'customer_versions.valid_from', 'customer_versions.full_name']) }} as customer_key,
    customer_versions.customer_id,
    customer_versions.business_entity_id,
    customer_versions.full_name,
    stg_store.store_business_entity_id,
    stg_store.store_name,
    case
        when customer_versions.store_id is not null then 'Reseller'
        else 'Individual'
    end as customer_segment,
    customer_versions.valid_from,
    customer_versions.valid_to,
    (customer_versions.valid_to is null) as is_current
from customer_versions
left join stg_store on customer_versions.store_id = stg_store.store_business_entity_id
