select
    stateprovinceid as state_province_id,
    countryregioncode as country_region_code,
    name as state_name,
    territoryid as territory_id,
    isonlystateprovinceflag as is_only_state_province_flag,
    stateprovincecode as state_province_code,
    rowguid as row_guid,
    modifieddate as modified_date
from {{ ref('stateprovince') }}
