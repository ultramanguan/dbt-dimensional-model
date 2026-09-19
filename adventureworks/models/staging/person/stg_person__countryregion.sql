select
    countryregioncode as country_region_code,
    name as country_name,
    modifieddate as modified_date
from {{ ref('countryregion') }}
