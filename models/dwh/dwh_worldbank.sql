{{
    config(
        materialized='incremental'
    )
}}

select
    country,
    years,
    gdp,
    gdp_growth,
    min_gdp_since_2000,
    max_gdp_since_2000
from 
    {{ ref('stg_worldbank') }}