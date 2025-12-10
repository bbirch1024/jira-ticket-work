
SELECT
  -- 1. Use TIME_BUCKET() with an INTERVAL '10 minutes'
  TIME_BUCKET(INTERVAL '10 minutes', CAST(e.event_time AS TIMESTAMPTZ)) AS ten_minute_interval,
   e.event_eventType,
  COUNT(*) AS event_count
FROM
  'data/cloudwatch/path=related-and-resultCount=0.tsv' as e
GROUP BY
  1,2
ORDER BY
  ten_minute_interval;

