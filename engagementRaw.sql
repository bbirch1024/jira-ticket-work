.maxrows 1000

with sfv as (
    select distinct engagementRaw from 'data/stan_search_event/*/*.parquet' where json_valid(engagementRaw)
),
afv as (
    select distinct engagementRaw from 'data/stan_analytics_event/*/*.parquet' where json_valid(engagementRaw)
),
sf as (
    select distinct j.key as name from sfv as stan_search_event, LATERAL json_each(engagementRaw::JSON) AS j(key, value)
),
af as (
    select distinct j.key as name from afv as stan_analytics_event, LATERAL json_each(engagementRaw::JSON) AS j(key, value)
),
allf as (
    select distinct name from (
        select name from sf
        union all
        select name from af
    )
)
select ifnull(sf.name, '') as search_fields,  ifnull(af.name, '') as analytics_fields
from allf un
left outer join sf
on un.name = sf.name
left outer join af
on un.name = af.name
order by 2, 1

-- ┌───────────────┬──────────────────┐
-- │ search_fields │ analytics_fields │
-- │    varchar    │     varchar      │
-- ├───────────────┼──────────────────┤
-- │               │                  │
-- │ correlationId │ correlationId    │
-- │ model         │ model            │
-- │ query         │ query            │
-- │ source        │ source           │
-- │ vendor        │ vendor           │
-- └───────────────┴──────────────────┘
