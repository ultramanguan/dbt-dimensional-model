select
    date_day,
    prior_date_day,
    next_date_day,
    prior_year_date_day,
    prior_year_over_year_date_day,
    day_of_week,
    day_of_week_name,
    day_of_month,
    day_of_year
from {{ ref('date') }}
