# Post Release of BS-2670 to production

## Cloudwatch query
```
{$.eventType = %mlt% && $.resultCount = 0 }
```

## Unpack

```
./cloud-watch-logs.g data/cloudwatch/post-release-zero-result.csv > data/cloudwatch/post-release-zero-result.ts
```

with mlt-frequency.sql:

```sql
SELECT
  -- 1. Use TIME_BUCKET() with an INTERVAL '10 minutes'
  TIME_BUCKET(INTERVAL '10 minutes', CAST(e.event_time AS TIMESTAMPTZ)) AS ten_minute_interval,
   -- e.event_eventType,
  COUNT(*) AS event_count
FROM
--  'data/cloudwatch/path=related-and-resultCount=0.tsv' as e
 'data/cloudwatch/post-release-zero-result.tsv' as e
 where e.event_resultCount = 0
GROUP BY
  1
ORDER BY
  ten_minute_interval;

```

Generate stats per ten minutes

```
duckdb -csv -f mlt-frequency.sql > data/cloudwatch/post-release-zero-result-mlt-frequency.csv
```

Plot the result
```
gnuplot ./post-release-frequency.gp && open post-release-zero-result-mlt-frequency.png
```


