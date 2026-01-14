.maxrows 1000
with names as (
    select distinct name from parquet_schema('data/stan_search_event/*/*.parquet')
    union all
    select distinct name from parquet_schema('data/stan_analytics_event/*/*.parquet')
),
unique_names as (select distinct name from names),
search_fields as (select distinct name from parquet_schema('data/stan_search_event/*/*.parquet')),
analytics_fields as (select distinct name from parquet_schema('data/stan_analytics_event/*/*.parquet'))

select un.name, ifnull(sf.name, '') as search_fields,  ifnull(af.name, '') as analytics_fields
from unique_names un
left outer join search_fields sf
on un.name = sf.name
left outer join analytics_fields af
on un.name = af.name
order by 1, 2