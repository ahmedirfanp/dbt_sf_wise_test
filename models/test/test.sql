select *
from {{ source('wise_funnel', 'STG_WISE_FUNNEL_EVENTS') }}
