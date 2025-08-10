select
  user_id,
  transfer_seq,
  max(experience) as experience,
  max(region)     as region,
  max(platform)   as platform,
  min(case when event_name = 'Transfer Created'     then dt end) as created_date,
  min(case when event_name = 'Transfer Funded'      then dt end) as funded_date,
  min(case when event_name = 'Transfer Transferred' then dt end) as transferred_date
from {{ ref('stg_wise_funnel_events') }}
group by user_id, transfer_seq