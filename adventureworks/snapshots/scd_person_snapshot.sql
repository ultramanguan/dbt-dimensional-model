{% snapshot scd_person_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='business_entity_id',
        strategy='timestamp',
        updated_at='modified_date',
    )
}}

select
    business_entity_id,
    first_name,
    middle_name,
    last_name,
    modified_date
from {{ ref('stg_person__person') }}

{% endsnapshot %}
