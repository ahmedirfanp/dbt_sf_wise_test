{{
    config(
        materialized='table'
    )
}}

select *,
  case when funded_date is null or created_date is null then null
       else datediff('day', created_date::date, funded_date::date) end as days_to_fund,
  case when transferred_date is null or funded_date is null then null
       else datediff('day', funded_date::date, transferred_date::date) end as days_to_transfer,
  case when transferred_date is null or created_date is null then null
       else datediff('day', created_date::date, transferred_date::date) end as total_days,
  (iff(created_date    is not null, 1, 0)
   + iff(funded_date   is not null, 1, 0)
   + iff(transferred_date is not null, 1, 0)) as steps_completed,
  case
    when created_date is not null and funded_date is not null and transferred_date is not null then 'completed'
    when created_date is not null and funded_date is not null and transferred_date is null then 'funded_only'
    when created_date is not null and funded_date is null  and transferred_date is null then 'created_only'
    when created_date is null     and funded_date is not null and transferred_date is null then 'funded_no_created'
    when created_date is null     and transferred_date is not null then 'transferred_no_prev'
    when created_date is not null and funded_date is null and transferred_date is not null then 'skipped_fund'
    else 'unknown'
  end as status
from {{ ref('wise_funnel_events_final') }}