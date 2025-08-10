select
  cast(user_id as int) as user_id,
  dt,
  event_name,
  region,
  platform,
  experience,
  sum(case when event_name = 'Transfer Created' then 1 else 0 end)
    over (
      partition by user_id
      order by
        dt,
        case event_name
          when 'Transfer Created'   then 1
          when 'Transfer Funded'    then 2
          when 'Transfer Transferred' then 3
          else 999
        end
      rows between unbounded preceding and current row
    ) as transfer_seq
from {{ source('wise_funnel', 'STG_WISE_FUNNEL_EVENTS') }}
