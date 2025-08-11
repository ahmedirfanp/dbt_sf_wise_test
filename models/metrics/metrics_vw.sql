select
  experience,
  platform,
  region,

  count(*) as created_transfers,
  count_if(funded_date     is not null) as funded_transfers,
  count_if(transferred_date is not null) as completed_transfers,

  {{ pct_if("funded_date IS NOT NULL") }}                                        as created_to_funded_pct,
  {{ dropoff_from( pct_if("funded_date IS NOT NULL") ) }}                        as created_to_funded_drop_off_pct,

  {{ pct_transition("transferred_date IS NOT NULL", "funded_date IS NOT NULL") }} as funded_to_completed_pct,
  {{ dropoff_from( pct_transition("transferred_date IS NOT NULL", "funded_date IS NOT NULL") ) }} as funded_to_completed_drop_off_pct,

  {{ pct_if("transferred_date IS NOT NULL") }}                                   as created_to_completed_pct,
  {{ dropoff_from( pct_if("transferred_date IS NOT NULL") ) }}                   as created_to_completed_drop_off_pct

from {{ ref('wise_funnel_events_metrics') }}
group by experience, platform, region
order by experience, platform, region
