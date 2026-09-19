select
    addressid as address_id,
    addressline1 as address_line_1,
    addressline2 as address_line_2,
    city as city_name,
    stateprovinceid as state_province_id,
    postalcode as postal_code,
    spatiallocation as spatial_location,
    rowguid as row_guid,
    modifieddate as modified_date
from {{ ref('address') }}
