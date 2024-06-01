
with source as (

    select * from {{ source('public', 'worldbank') }}

),
 
unpack_source as 
    (
        select 
            value -> 'indicator' ->> 'id' as id, 
            value -> 'country' ->> 'value' as country, 
            value -> 'value' as gdp, 
            value -> 'date' as year
        from 
            source
        where value -> 'value' is not null
),

prep_source as (
    select 
        country,
        replace(year::text,'"','') as years,
        gdp::text::decimal
    from 
        unpack_source
    where gdp::text != 'null'
),

enchance_source as 
    (
    select 
        country,
        years,
        gdp,
        lag(gdp) over (order by years) as prev_year_gdp
        --(gdp - prev_year_gdp) / prev_year_gdp as gdp_growth
     from 
     prep_source
),

transform_source as 
     (
        select 
            * 
        from enchance_source
        where 
            years::int > 2020
)

select 
    country,
    years,
    gdp,
    (gdp - prev_year_gdp) / prev_year_gdp as gdp_growth,
    min(gdp) over (partition by country rows between unbounded preceding and unbounded following) as min_gdp_since_2000,
    max(gdp) over (partition by country rows between unbounded preceding and unbounded following) as max_gdp_since_2000
    from transform_source
