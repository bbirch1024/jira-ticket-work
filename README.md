# 

## Buildkite deploed at 13:49 to Test 

[](https://buildkite.com/streamco/recworker/builds/1762#019b0621-b9c2-488d-81ac-5d0222619911)

## CloudWatch Test query

on `test/rec` log group

`{$.path = %related% &&  $.resultCount=0 }`

## Unpack

```
$ ./cloud-watch-logs.g data/cloudwatch/path\=related-and-resultCount\=0.csv > data/cloudwatch/path\=related-and-resultCount\=0.tsv
```


## Effect of deployment on zerolength MLTs

[](./mlt-frequency.sql)`

```
$ duckdb -f mlt-frequency.sql 
┌──────────────────────────┬─────────────────┬─────────────┐
│   ten_minute_interval    │ event_eventType │ event_count │
│ timestamp with time zone │     varchar     │    int64    │
├──────────────────────────┼─────────────────┼─────────────┤
│ 2025-12-09 16:50:00+11   │ mlt-sport       │           1 │
│ 2025-12-09 17:00:00+11   │ mlt-sport       │           1 │
│ 2025-12-09 17:30:00+11   │ mlt-sport       │           7 │
│ 2025-12-09 22:10:00+11   │ mlt             │           1 │
│ 2025-12-10 09:10:00+11   │ mlt             │           1 │
│ 2025-12-10 09:30:00+11   │ mlt             │           1 │
│ 2025-12-10 09:50:00+11   │ mlt             │           2 │
│ 2025-12-10 10:40:00+11   │ mlt             │           1 │
│ 2025-12-10 11:00:00+11   │ mlt             │           1 │
│ 2025-12-10 11:20:00+11   │ mlt-sport       │          10 │
│ 2025-12-10 11:30:00+11   │ mlt-sport       │           1 │
│ 2025-12-10 11:40:00+11   │ mlt-sport       │           4 │
│ 2025-12-10 12:50:00+11   │ mlt             │           3 │
│ 2025-12-10 13:00:00+11   │ mlt             │           1 │
│ 2025-12-10 13:20:00+11   │ mlt-sport       │           2 │
│ 2025-12-10 14:30:00+11   │ mlt             │           1 │
│ 2025-12-10 15:00:00+11   │ mlt-sport       │           1 │
│ 2025-12-10 15:00:00+11   │ mlt             │           1 │
│ 2025-12-10 15:20:00+11   │ mlt             │           1 │
│ 2025-12-10 15:50:00+11   │ mlt             │           1 │
│ 2025-12-10 15:50:00+11   │ mlt-sport       │           2 │
│ 2025-12-10 16:30:00+11   │ mlt             │           1 │
├──────────────────────────┴─────────────────┴─────────────┤
│ 22 rows                                        3 columns │
└──────────────────────────────────────────────────────────┘
```

## Are the users sending JWTs? Do the have Sport feature?

(mlt-features.sql)

```
$ duckdb -quote -f mlt-features.sql | gawk 'NR!=1{print}' | frangipanni -breaks "'|" -counts -no-fold
mlt_event_with_zero_results: 45
    mlt-sport: 29
        has_feat: 29
            jwToken_feat: 25
            URL_feat: 4
                jwToken_feat: 4
    mlt: 16
        has_feat: 16
            jwToken_feat: 16
                FeatureSport: 8
```
