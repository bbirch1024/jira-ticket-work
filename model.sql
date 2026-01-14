.maxrows 10000

with sf as (
    select j.key as k, j.value as v from 'data/stan_search_event/*/*.parquet' as stan_search_event, LATERAL json_each(engagement::JSON) AS j(key, value)
),
af as (
    select j.key as k, j.value as v from 'data/stan_analytics_event/*/*.parquet' as stan_analytics_event, LATERAL json_each(engagement::JSON) AS j(key, value)
)


-- allf as (
--     select distinct value from (
--         select name from sf
--         union all
--         select name from af
--     )
-- )
-- select ifnull(sf.name, '') as search_fields,  ifnull(af.name, '') as analytics_fields
-- from allf un
-- left outer join sf
-- on un.name = sf.name
-- left outer join af
-- on un.name = af.name
-- order by 2, 1
--
-- -- ┌───────────────┬──────────────────┐
-- -- │ search_fields │ analytics_fields │
-- -- │    varchar    │     varchar      │
-- -- ├───────────────┼──────────────────┤
-- -- │ correlationID │ correlationID    │
-- -- │ model         │ model            │
-- -- │               │ query            │
-- -- │               │ source           │
-- -- │ vendor        │ vendor           │
-- -- └───────────────┴──────────────────┘
