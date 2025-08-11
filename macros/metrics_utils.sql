{# Generic percent helper: ROUND(numer*100 / NULLIF(denom,0), precision) #}
{% macro pct_expr(numer_sql, denom_sql, precision=2) -%}
  ROUND( ({{ numer_sql }}) * 100.0 / NULLIF({{ denom_sql }}, 0), {{ precision }} )
{%- endmacro %}

{# Snowflake: COUNT_IF(condition) #}
{% macro pct_if(condition_sql, precision=2) -%}
  {{ pct_expr("COUNT_IF(" ~ condition_sql ~ ")", "COUNT(*)", precision) }}
{%- endmacro %}

{# Transition: numerator is condition A over rows satisfying condition B #}
{% macro pct_transition(numer_condition_sql, denom_condition_sql, precision=2) -%}
  {{ pct_expr(
      "COUNT_IF(" ~ numer_condition_sql ~ ")",
      "COUNT_IF(" ~ denom_condition_sql ~ ")",
      precision
  ) }}
{%- endmacro %}

{# Drop-off = 100 - pct(...) #}
{% macro dropoff_from(pct_sql) -%}
  100 - ( {{ pct_sql }} )
{%- endmacro %}
