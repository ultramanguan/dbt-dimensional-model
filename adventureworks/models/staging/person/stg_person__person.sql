select
    businessentityid as business_entity_id,
    title,
    firstname as first_name,
    middlename as middle_name,
    lastname as last_name,
    persontype as person_type,
    namestyle as name_style,
    suffix,
    modifieddate as modified_date,
    rowguid as row_guid,
    emailpromotion as email_promotion
from {{ ref('person') }}
