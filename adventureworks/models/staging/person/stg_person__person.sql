-- person_batch controls how many simulated change batches (seeds/person/person_changes.csv)
-- have "arrived" from the source system. 0 = only the original person seed.
with person_versions as (
    select
        businessentityid,
        title,
        firstname,
        middlename,
        lastname,
        persontype,
        namestyle,
        suffix,
        modifieddate,
        rowguid,
        emailpromotion,
        'initial' as change_type
    from {{ ref('person') }}

    union all

    select
        businessentityid,
        title,
        firstname,
        middlename,
        lastname,
        persontype,
        namestyle,
        suffix,
        modifieddate,
        rowguid,
        emailpromotion,
        change_type
    from {{ ref('person_changes') }}
    where batch <= {{ var('person_batch', 0) }}
),

latest_person as (
    select *
    from person_versions
    qualify row_number() over (partition by businessentityid order by modifieddate desc) = 1
)

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
from latest_person
where change_type != 'delete'
