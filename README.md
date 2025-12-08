


## Unpack the CloudWatch data file into a TSV

```
./cloud-watch-logs.g aws-logs/cloud-watch-events-12h-%mlt%-resultCount-zero.csv > aws-log-reports/cloud-watch-events-12h-%mlt%-resultCount-zero.tsv
```

## Load data into DuckDB

```
$ duckdb -ui foo.db 
┌──────────────────────────────────────┐
│                result                │
│               varchar                │
├──────────────────────────────────────┤
│ UI started at http://localhost:4213/ │
└──────────────────────────────────────┘
DuckDB v1.4.2 (Andium) 68d7555f68
Enter ".help" for usage hints.
D CREATE TABLE events AS SELECT * FROM read_csv_auto('aws-log-reports/log-events-viewer-result-zero-12h.tsv');
                                             ^
D CREATE TABLE monday AS SELECT * FROM read_csv_auto('aws-log-reports/cloud-watch-events-12h-%mlt%-resultCount-zero.tsv');

```
## DuckDB queries

```
select e.event_eventType , count(*) from monday as e group by 1
```



```
--
-- Cloudwatch events with MLR - filter was `{ $.eventType = %mlt%  && $.resultCount = 0}`
--
with feats as (
  select 
    case when e.param_feat <> 'nil' then 1 else 0 end has_URL_feat, 
    case when e.jwt_feat <> 'nil' then 1 else 0 end as has_jwToken_feat,
    case when e.param_feat = 'nil' AND e.jwt_feat = 'nil' then 1 else 0 end as has_no_feat,
    case when e.param_feat <> 'nil' OR e.jwt_feat <> 'nil' then 1 else 0 end as has_feat
    from monday as e
)

select sum(has_URL_feat) , sum(has_jwToken_feat), sum(has_feat), sum(has_no_feat), count(*) as total
from feats 

```

## DuckDB feature breakdown 

```
--
-- Cloudwatch events with MLR - filter was `{ $.eventType = %mlt%  && $.resultCount = 0}`
--
with feats as (
  select
    e.event_eventType,
    case when e.param_feat <> 'nil' or e.jwt_feat <> 'nil' then 'has_feat' else '' end has_URL_feat, 
    case when e.param_feat <> 'nil' then 'URL_feat' else '' end has_URL_feat, 
    case when e.jwt_feat <> 'nil' then 'jwToken_feat' else '' end as has_jwToken_feat,
    from monday as e
)

select 'mlt_event_with_zero_results', *
from feats 
```


```
$ gawk 'NR!=1{print}' aws-log-reports/cloud-watch-events-12h-%mlt%-resultCount-zero-features.csv | frangipanni -breaks '",' -counts -no-fold
mlt_event_with_zero_results: 253
    mlt-sport: 171
        has_feat: 151
            jwToken_feat: 139
            URL_feat: 12
                jwToken_feat: 11
    mlt: 82
        has_feat: 45
            URL_feat: 16
                jwToken_feat: 13
            jwToken_feat: 29
```
