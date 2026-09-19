with stg_address as (
    select *
    from {{ ref('stg_person__address') }}
),

stg_stateprovince as (
    select *
    from {{ ref('stg_person__stateprovince') }}
),

stg_countryregion as (
    select *
    from {{ ref('stg_person__countryregion') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['stg_address.address_id']) }} as address_key,
    stg_address.address_id,
    stg_address.city_name,
    stg_stateprovince.state_name,
    stg_countryregion.country_name
from stg_address
left join stg_stateprovince on stg_address.state_province_id = stg_stateprovince.state_province_id
left join stg_countryregion on stg_stateprovince.country_region_code = stg_countryregion.country_region_code
