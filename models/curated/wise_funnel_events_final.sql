{{
    config(
        materialized='table'
    )
}}

select
  user_id,
  experience,
  transfer_seq,
  region,
  platform,
  created_date,
  funded_date,
  transferred_date
from {{ ref('wise_funnel_events_pivoted') }}
