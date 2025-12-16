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

# Testing locally pointing to Production Using docker

```
$ docker ps --no-trunc
CONTAINER ID                                                       IMAGE         COMMAND                           CREATED       STATUS        PORTS                                         NAMES
a50204f8c02924a91bcecfe4dd1231ef916410824f76c81a617d68640a9e3ba8   postgres:17   "docker-entrypoint.sh postgres"   4 weeks ago   Up 43 hours   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp   programs_integration_test
```

```
b$ psql -h localhost -p 5432 -d postgres -U postgres < ../streamco-feedbuilder/db/catalogue/schema.sql 
Password for user postgres: 
CREATE TYPE
CREATE TYPE
CREATE TYPE
. . .
```
create the env file
```
$ cat  .streamco-env/prod/local.yaml
CATALOGUE_DATABASE_URL: 'postgres://localhost:5432/catalogue_prod?sslmode=disable'
RECENGINE_DATABASE_URL: 'postgres://localhost:5432/catalogue_prod?sslmode=disable'
```

Check how muich data this would garner


```
$  (cd ../streamco-search &&  streamco-env -env prod -tunnel CATALOGUE_DATABASE_URL search psql  '${CATALOGUE_DATABASE_URL}' )
2025/12/11 09:43:02 forwarding localhost:5531 -> catalogue-pg17-data.cs4tunnhfjea.ap-southeast-2.rds.amazonaws.com:5432
2025/12/11 09:43:03 Port 5531 opened for sessionId bill.birch-i8lonq78dkbzbhuyjphxd5ae38.
psql (18.0, server 17.3)
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off, ALPN: postgresql)
Type "help" for help.

catalogue_prod=> -- "run '1=1'"
catalogue_prod=> SELECT count(*) FROM run;
 count 
-------
     8
(1 row)

catalogue_prod=> 
catalogue_prod=> -- "program 'id != 0'"
catalogue_prod=> SELECT count(*) FROM program WHERE id != 0;
 count  
--------
 158959
(1 row)

catalogue_prod=> 
catalogue_prod=> -- "people 'id != 0'"
catalogue_prod=> SELECT count(*) FROM people WHERE id != 0;
 count 
-------
 25761
(1 row)

catalogue_prod=> 
catalogue_prod=> -- "imdb 'votes >= 10000'"
catalogue_prod=> SELECT count(*) FROM imdb WHERE votes >= 10000;
 count 
-------
 13075
(1 row)

catalogue_prod=> 
catalogue_prod=> -- "sport_metadata 'competition != '''"
catalogue_prod=> SELECT count(*) FROM sport_metadata WHERE competition != '';
 count 
-------
 79010
(1 row)

catalogue_prod=> 
catalogue_prod=> -- "tile_metadata 'program_id != 0'"
catalogue_prod=> SELECT count(*) FROM tile_metadata WHERE program_id != 0;
 count 
-------
 36532
(1 row)
```


```
with row_counts as (
    SELECT 'run' as table_name, count(*) as number_of_rows FROM run
    union all
    SELECT 'program' as table_name, count(*) as number_of_rows FROM program WHERE id != 0
    union all
    SELECT 'people' as table_name, count(*) as number_of_rows FROM people WHERE id != 0
    union all
    SELECT 'imdb' as table_name, count(*) as number_of_rows FROM imdb WHERE votes >= 10000
    union all
    SELECT 'sport_metadata' as table_name, count(*) as number_of_rows FROM sport_metadata WHERE competition != ''
    union all
    SELECT 'tile_metadata' as table_name, count(*) as number_of_rows FROM tile_metadata WHERE program_id != 0
)
--select * from row_counts;
select sum(number_of_rows) from row_counts;
```

```
catalogue_prod=> with row_counts as (
catalogue_prod(>     SELECT 'run' as table_name, count(*) as number_of_rows FROM run
catalogue_prod(>     union all
catalogue_prod(>     SELECT 'program' as table_name, count(*) as number_of_rows FROM program WHERE id != 0
catalogue_prod(>     union all
catalogue_prod(>     SELECT 'people' as table_name, count(*) as number_of_rows FROM people WHERE id != 0
catalogue_prod(>     union all
catalogue_prod(>     SELECT 'imdb' as table_name, count(*) as number_of_rows FROM imdb WHERE votes >= 10000
catalogue_prod(>     union all
catalogue_prod(>     SELECT 'sport_metadata' as table_name, count(*) as number_of_rows FROM sport_metadata WHERE competition != ''
catalogue_prod(>     union all
catalogue_prod(>     SELECT 'tile_metadata' as table_name, count(*) as number_of_rows FROM tile_metadata WHERE program_id != 0
catalogue_prod(> )
catalogue_prod-> select * from row_counts;
   table_name   | number_of_rows 
----------------+----------------
 run            |              8
 people         |          25761
 tile_metadata  |          36537
 sport_metadata |          79015
 imdb           |          13075
 program        |         158964
(6 rows)
```

```
catalogue_prod=> with row_counts as (
catalogue_prod(>     SELECT 'run' as table_name, count(*) as number_of_rows FROM run
catalogue_prod(>     union all
catalogue_prod(>     SELECT 'program' as table_name, count(*) as number_of_rows FROM program WHERE id != 0
catalogue_prod(>     union all
catalogue_prod(>     SELECT 'people' as table_name, count(*) as number_of_rows FROM people WHERE id != 0
catalogue_prod(>     union all
catalogue_prod(>     SELECT 'imdb' as table_name, count(*) as number_of_rows FROM imdb WHERE votes >= 10000
catalogue_prod(>     union all
catalogue_prod(>     SELECT 'sport_metadata' as table_name, count(*) as number_of_rows FROM sport_metadata WHERE competition != ''
catalogue_prod(>     union all
catalogue_prod(>     SELECT 'tile_metadata' as table_name, count(*) as number_of_rows FROM tile_metadata WHERE program_id != 0
catalogue_prod(> )
catalogue_prod-> --select * from row_counts;
catalogue_prod-> select sum(number_of_rows) from row_counts;
  sum   
--------
 313360
(1 row)
```

# Test Data
# 

```
psql --tuples-only -f all-sport.sql -d 'postgres://postgres:postgres@localhost:5432/rec_integration_test'
```

In integration tests with source 148498 we get these items in the MLT

148539 148496 5037024 5054790 5054780 5044381 

```
$ psql --tuples-only -c 'select p.id, p.bundle, p.genres from program p where p.id in (148539, 148496, 5037024, 5054790, 5054780, 5044381) ' -d 'postgres://postgres:postgres@localhost:5432/rec_integration_test'
  148539 | olympics | {Sport,Olympics,"Sport Show"}
  148496 | olympics | {Sport,Olympics,"Sport Show"}
 5037024 | olympics | {Sport}
 5054790 | olympics | {Sport}
 5054780 | olympics | {Sport}
 5044381 | olympics | {Sport}

```

But the program_features table is empty.

```
$ psql --tuples-only -c 'select count(*) from program_features ; ' -d 'postgres://postgres:postgres@localhost:5432/rec_integration_test'
     0
```

```
(cd ../streamco-search ; streamco-env -env prod -tunnel CATALOGUE_DATABASE_URL search bash) 

psql --tuples-only -c 'select count(*) from program_features p where p.program_id in (148539, 148496, 5037024, 5054790, 5054780, 5044381) ' -d '${CATALOGUE_DATABASE_URL}'

```

Download the real features from Production

```
(cd ../streamco-search ; streamco-env -env prod -tunnel CATALOGUE_DATABASE_URL search bash)
go run github.com/streamco/streamco-db/cmd/pgdump@latest ${CATALOGUE_DATABASE_URL} program_features 'program_id in (148498, 148539, 148496, 5037024, 5054790, 5054780, 5044381)' > /tmp/dump-148539.sql
```
resulting in: 

```
COPY public.program_features (program_id, required_features, required_purchases, precluded_features) FROM stdin;
148496	64	0	0
148498	0	0	0
148539	64	0	0
5037024	64	0	0
5044381	64	0	0
5054780	64	0	0
5054790	64	0	0
\.

```

# Test Environment Mocks Data

## Get the Mocks JSON from the environment

```
( cd /Users/birchb/go/src/github.com/streamco/streamco-rec ; streamco-env -env test rec bash )
echo $MOCK_OVERRIDES | jp @ > ../BS-2670-Fix-for-empty-MLT-by-removing-feature-restrictions/mlt-mocks.json
```

# Analyse the mocks in the JSON file

Using `display-mlt-mocks.g` - this script could be useful to confirm the new mocks. . .

Fetch the source program information for non-default user id prefixes: 
    id, title, related and MLT feeds' genres

```
$ ./display-mlt-mocks.g | csvcut -C 1 | column -s , -t
0   1622778  Audio described Parks and Rec     related.genres:  Comedy%2CDocudrama
0   1622778  More like this                    feed.genres:     Comedy%2CDocudrama
0   3181101  Once Upon a Time... in Hollywood  related.genres:  Action%2CComedy
0   3181101  More like this                    feed.genres:     Action%2CComedy
50  1622778  Audio described Parks and Rec     related.genres:  Comedy%2CDocudrama
50  1622778  More like this                    feed.genres:     Comedy%2CDocudrama
50  3181101  Once Upon a Time... in Hollywood  related.genres:  Action%2CComedy
50  3181101  More like this                    feed.genres:     Action%2CComedy
f   1622778  Audio described Parks and Rec     related.genres:  Comedy%2CDocudrama
f   1622778  More like this                    feed.genres:     Comedy%2CDocudrama
f   3181101  Once Upon a Time... in Hollywood  related.genres:  Action%2CComedy
f   3181101  More like this                    feed.genres:     Action%2CComedy
```

# Create some new Mocks for Sport and Optussport bundles

```
psql --csv -f sport-mlt-in-test-env.sql "${CATALOGUE_DATABASE_URL}" > sport-mlt-in-test-env.sql.csv


gawk /^5425947/ sport-mlt-in-test-env.sql.csv

# 5425947,Highlights: Fiorentina v Real Betis - UEFA Conference League 2024/2025,"{5452357,5455246,5455247,5455248,5455249,5455250,5473046,5473054,5485994,5485996,5485997,5485998,5502578,5503180,5503212,5530502,5538070,5665963,5678634,5679511,5679512,5687237,5687239,5687248,5687250,5689534,5712337,5723123}"


gawk /^5425947/ sport-mlt-in-test-env.sql.csv | csvcut -C 2| tr '{}' '[]' | tr -d '"'

# 5425947,[5452357,5455246,5455247,5455248,5455249,5455250,5473046,5473054,5485994,5485996,5485997,5485998,5502578,5503180,5503212,5530502,5538070,5665963,5678634,5679511,5679512,5687237,5687239,5687248,5687250,5689534,5712337,5723123]

``

Pasted that into .streamco-env/test/rec.yaml



