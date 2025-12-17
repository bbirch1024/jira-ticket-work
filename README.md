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
export CATALOGUE_DATABASE_URL='postgres://rec:Axiewi8oKa6duteew1Joh5jo@localhost:5509/catalogue_test'
psql --csv -f sport-mlt-in-test-env.sql "${CATALOGUE_DATABASE_URL}" > sport-mlt-in-test-env.sql.csv


gawk /^5425947/ sport-mlt-in-test-env.sql.csv

# 5425947,Highlights: Fiorentina v Real Betis - UEFA Conference League 2024/2025,"{5452357,5455246,5455247,5455248,5455249,5455250,5473046,5473054,5485994,5485996,5485997,5485998,5502578,5503180,5503212,5530502,5538070,5665963,5678634,5679511,5679512,5687237,5687239,5687248,5687250,5689534,5712337,5723123}"


gawk /^5425947/ sport-mlt-in-test-env.sql.csv | csvcut -C 2| tr '{}' '[]' | tr -d '"'

# 5425947,[5452357,5455246,5455247,5455248,5455249,5455250,5473046,5473054,5485994,5485996,5485997,5485998,5502578,5503180,5503212,5530502,5538070,5665963,5678634,5679511,5679512,5687237,5687239,5687248,5687250,5689534,5712337,5723123]

``

Pasted that into .streamco-env/test/rec.yaml

Slack Message
```
bbirch
  5 minutes ago
OK I spotted my mistake. TL;DR  Don't use 'extra'  titles.
When rec loads it's cache of programs it only loads 'movie','series','linear' types.
So if you're on an 'extra' like Highlights: Fiorentina v Real Betis - UEFA Conference League 2024/2025
your program will not be in the cache, and MLT will drop back to vendor 1 (stan).
I need to stick to using 'movie'  titles.
Maybe MLT should be personalised (vendor google) for 'extra' titles?
```

New value in rec.yml
```
MOCK_OVERRIDES: '{"f":{"default":[22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631,1670804,1622778,48503],"2835085":[2835086,2835087,2835088,2835089,2835091,2835092,2835093,5258021,5258022,5269726,5269728,5269729,5269734,5269735,5709238],"3181101":[1723592,50355,4115662,2266827,3150876,1726054,2272231,50547,103712,1670977,3143519,22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631],"1622778":[68428,2864503,2865959,3375921,88631,1670804,1622778,48503,1723592,50355,4115662,2266827,3150876,1726054,2272231,50547,103712,1670977,3143519,22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631]},"50":{"default":[22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631,1670804,1622778,48503],"3181101":[1723592,50355,4115662,2266827,3150876,1726054,2272231,50547,103712,1670977,3143519,22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631],"1622778":[68428,2864503,2865959,3375921,88631,1670804,1622778,48503,1723592,50355,4115662,2266827,3150876,1726054,2272231,50547,103712,1670977,3143519,22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631]},"0":{"default":[22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631,1670804,1622778,48503],"2835085":[2835086,2835087,2835088,2835089,2835091,2835092,2835093,5258021,5258022,5269726,5269728,5269729,5269734,5269735,5709238],"3181101":[1723592,50355,4115662,2266827,3150876,1726054,2272231,50547,103712,1670977,3143519,22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631],"1622778":[68428,2864503,2865959,3375921,88631,1670804,1622778,48503,1723592,50355,4115662,2266827,3150876,1726054,2272231,50547,103712,1670977,3143519,22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631]}}'
```

```
{"f":{"default":[22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631,1670804,1622778,48503],"3181101":[1723592,50355,4115662,2266827,3150876,1726054,2272231,50547,103712,1670977,3143519,22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631],"1622778":[68428,2864503,2865959,3375921,88631,1670804,1622778,48503,1723592,50355,4115662,2266827,3150876,1726054,2272231,50547,103712,1670977,3143519,22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631]},
"50":{"default":[22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631,1670804,1622778,48503],"3181101":[1723592,50355,4115662,2266827,3150876,1726054,2272231,50547,103712,1670977,3143519,22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631],"1622778":[68428,2864503,2865959,3375921,88631,1670804,1622778,48503,1723592,50355,4115662,2266827,3150876,1726054,2272231,50547,103712,1670977,3143519,22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631]},
"0":{"default":[22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631,1670804,1622778,48503],"2835085":[2835086,2835087,2835088,2835089,2835091,2835092,2835093,5258021,5258022,5269726,5269728,5269729,5269734,5269735,5709238],"3181101":[1723592,50355,4115662,2266827,3150876,1726054,2272231,50547,103712,1670977,3143519,22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631],"1622778":[68428,2864503,2865959,3375921,88631,1670804,1622778,48503,1723592,50355,4115662,2266827,3150876,1726054,2272231,50547,103712,1670977,3143519,22031,51596,62272,4335811,2781352,68428,2864503,2865959,3375921,88631]}}


{
  "0": {
    "1622778": [
      68428,
      2864503,
      2865959,
      3375921,
      88631,
      1670804,
      1622778,
      48503,
      1723592,
      50355,
      4115662,
      2266827,
      3150876,
      1726054,
      2272231,
      50547,
      103712,
      1670977,
      3143519,
      22031,
      51596,
      62272,
      4335811,
      2781352,
      68428,
      2864503,
      2865959,
      3375921,
      88631
    ],
    "2835085": [2835086,2835087,2835088,2835089,2835091,2835092,2835093,5258021,5258022,5269726,5269728,5269729,5269734,5269735,5709238],
    "3181101": [
      1723592,
      50355,
      4115662,
      2266827,
      3150876,
      1726054,
      2272231,
      50547,
      103712,
      1670977,
      3143519,
      22031,
      51596,
      62272,
      4335811,
      2781352,
      68428,
      2864503,
      2865959,
      3375921,
      88631
    ],
    "default": [
      22031,
      51596,
      62272,
      4335811,
      2781352,
      68428,
      2864503,
      2865959,
      3375921,
      88631,
      1670804,
      1622778,
      48503
    ]
  },
  "50": {
    "1622778": [
      68428,
      2864503,
      2865959,
      3375921,
      88631,
      1670804,
      1622778,
      48503,
      1723592,
      50355,
      4115662,
      2266827,
      3150876,
      1726054,
      2272231,
      50547,
      103712,
      1670977,
      3143519,
      22031,
      51596,
      62272,
      4335811,
      2781352,
      68428,
      2864503,
      2865959,
      3375921,
      88631
    ],
    "3181101": [
      1723592,
      50355,
      4115662,
      2266827,
      3150876,
      1726054,
      2272231,
      50547,
      103712,
      1670977,
      3143519,
      22031,
      51596,
      62272,
      4335811,
      2781352,
      68428,
      2864503,
      2865959,
      3375921,
      88631
    ],
    "default": [
      22031,
      51596,
      62272,
      4335811,
      2781352,
      68428,
      2864503,
      2865959,
      3375921,
      88631,
      1670804,
      1622778,
      48503
    ]
  },
  "f": {
    "1622778": [
      68428,
      2864503,
      2865959,
      3375921,
      88631,
      1670804,
      1622778,
      48503,
      1723592,
      50355,
      4115662,
      2266827,
      3150876,
      1726054,
      2272231,
      50547,
      103712,
      1670977,
      3143519,
      22031,
      51596,
      62272,
      4335811,
      2781352,
      68428,
      2864503,
      2865959,
      3375921,
      88631
    ],
    "3181101": [
      1723592,
      50355,
      4115662,
      2266827,
      3150876,
      1726054,
      2272231,
      50547,
      103712,
      1670977,
      3143519,
      22031,
      51596,
      62272,
      4335811,
      2781352,
      68428,
      2864503,
      2865959,
      3375921,
      88631
    ],
    "default": [
      22031,
      51596,
      62272,
      4335811,
      2781352,
      68428,
      2864503,
      2865959,
      3375921,
      88631,
      1670804,
      1622778,
      48503
    ]
  }
}

```

# How does Test environment react to different feature bits?

Cycle through all the feature bits, with the url `https://api.test.streamco.com.au/rec/v1/related?source=2835085&feat=2`
which has no jwToken.

All of the results are vendor 1 (stan).

```
./cycle-feature.g > cycle-feature.1.txt
```

There are N kinds of results

# 3 results - only one of these 
```
FeatureSportStreamingInVenues bit: 24 
   total: 3
   vendor: 1
   entries:
     5672798 'Ring of Fire - PPV Test'
     4941455 'Uncaged PPV Test'
     5473046 'Arsenal vs Man U'
FeatureLiveUHD bit: 25 
   total: 4
```
# 20 results

```
FeatureSubhub bit: 42 
   total: 20
   vendor: 1
   entries:
     5269735 'Chiefs v Brumbies - Super Rugby Pacific Round 3 2025'
     5724641 'Optus 4k - Kai: 17/12/2025 16:38'
     2835088 'Super Rugby AU Rd 1 - Force v Brumbies'
     2835089 'Super Rugby AU Rd 1 - Reds v Waratahs'
     2835086 'Super Rugby AU Rd 2 - Reds v Rebels'
     2835087 'Super Rugby AU Rd 3 - Waratahs v Force'
     2835091 'Super Rugby AU Rd 6 - Waratahs vs. Reds'
     2835092 'Super Rugby AU Rd 7 - Western Force vs. Waratahs'
     2835093 'Super Rugby AU Rd 8 Western Force vs. Reds'
     5491736 'TEST Everton v Bournemouth - Summer Series MD1 2025'
     5491737 'TEST Man United v West Ham - Summer Series MD1 2025'
     5501513 'TEST Racing Louisville v KC Current - NWSL MW 14 2025'
     5501514 'TEST Yokohama FC v Urawa - J League MW 25 2025'
     5709238 'yoyo-osos2 optus - : 03/12/2025 11:41'
     3230588 'Martin Zapata v Daman Saudi'
```

Only the first 15 are returned in the response.

# 22 results

```
FeatureEntertainment bit: 44 
   total: 22
   vendor: 1
   entries:
     5724592 'Fastly - CAT No Ads 2 - : 17/12/2025 12:54'
     5724637 'Peter Segment Investigation - Peter: 17/12/2025 15:43'
     5313381 'How to be accepted by the dev team'
     5113695 'How to replace your CMS with airtable'
     2829705 'Live test'
     3230588 'Martin Zapata v Daman Saudi'
     5672798 'Ring of Fire - PPV Test'
     5009059 'SMWYG - Dynamic query all the things'
     2735407 'Teñnis Live 1'
     5009971 'Tincho & Friends - Sidecar Special Tino'
     4941455 'Uncaged PPV Test'
     5473046 'Arsenal vs Man U'
     4314931 'Backend Regression Testing - SMWYG'
     4193017 'Behind the scenes of the App Store'
     4084334 'CAT - Mon, 17 Apr 2023 09:07:45 AEST'
```

# 56 Results

```
FeatureSport bit: 6 
   total: 56
   vendor: 1
   entries:
     5258022 'Force v Brumbies - Super Rugby Women\'s Round 1 2025'
     5269729 'Force v Reds - Super Rugby Pacific Round 3 2025'
     5269728 'Hurricanes v Blues - Super Rugby Pacific Round 3 2025'
     5269734 'Moana Pasifika v Highlanders - Super Rugby Pacific Round 3 2025'
     5407912 'Queensland Reds Under 16 v NSW Waratahs Under 16 - Men\'s Super Rugby U16 2024'
     5548480 'Session test'
     5269726 'Waratahs v Fijian Drua - Super Rugby Pacific Round 3 2025'
     5258021 'Waratahs v Fijian Drua - Super Rugby Women\'s Round 1 2025'
     5049767 'ARC18.3 Men\'s Individual Quarterfinal'
     5084303 'AZ v Elfsborg - UEFA Europa League 2024/2025'
     5084470 'Athletic Club v Slavia Praha - UEFA Europa League 2024/2025'
     5258839 'Chelsea v Manchester United'
     5128136 'Elfsborg v Pafos - UEFA Europa League 2024/2025'
     4993009 'Football - Spain v Australia - Olympic Football TEST Feature'
     5090286 'Internazionale v Crvena zvezda - UEFA Champions League 2024/2025'
```


# 4 Results (the rest)

```
   total: 4
   vendor: 1
   entries:
     3230588 'Martin Zapata v Daman Saudi'
     5672798 'Ring of Fire - PPV Test'
     4941455 'Uncaged PPV Test'
     5473046 'Arsenal vs Man U'
```

All of these 42 feature bits got this result

    FeatureOffline bit: 0 
    FeatureInternal bit: 1 
    FeatureUhd bit: 2 
    FeatureKidsProfile bit: 3 
    FeatureStandardPlan bit: 4 
    FeatureQA bit: 5 
    FeatureGlobalised bit: 7 
    FeatureAskWhoIsWatching bit: 8 
    FeaturePremiumPlan bit: 9 
    FeatureDynamicSitemap bit: 10 
    FeatureFullFeeds bit: 11 
    FeatureHDR bit: 12 
    FeatureDolbyVision bit: 13 
    FeatureDolbyAtmos bit: 14 
    FeatureHEVC bit: 15 
    FeaturePlayReadyNoOutputProtection bit: 16 
    FeatureSportUpsell bit: 17 
    FeatureDashWithTimeline bit: 18 
    FeatureLive bit: 19 
    FeatureItunesBilled bit: 20 
    FeatureStripeBilled bit: 21 
    FeatureLiveUHD bit: 25 
    FeatureNewProfile bit: 27 
    FeatureItunesPurchaseAvailable bit: 28 
    FeatureOlderProfile bit: 29 
    FeatureClearAudio bit: 30 
    FeatureAllowInAppPurchases bit: 31 
    FeatureLinearStream bit: 32 
    FeatureForceSD bit: 33 
    FeatureStudioScreen2160 bit: 34 
    FeatureStudioHWSecurity bit: 35 
    FeatureStudioPartlyUnhackable bit: 36 
    FeatureStudioUnhackable bit: 37 
    FeatureQualityUpsell bit: 38 
    FeatureSubhubBilled bit: 39 
    FeatureWidevineOrPlayReady bit: 40 
    FeatureFairPlay bit: 41 
    FeatureSubhubNav bit: 43 
    FeatureExperimentFourthCta bit: 45 
    FeatureOptusBasicAndSportUpsellExperiment bit: 46 
    FeatureOptusStandardAndSportUpsellExperiment bit: 47 
    FeatureCommonAccessToken bit: 48 


# Cycle through more and decode the user jwToken features



```
./cycle-feature.g


No features no token
   total: 4
   vendor: 1
   entries:
     3230588 'Martin Zapata v Daman Saudi'
     5672798 'Ring of Fire - PPV Test'
     4941455 'Uncaged PPV Test'
     5473046 'Arsenal vs Man U'

Just jwToken with features 23436565677378 (FeatureAllowInAppPurchases FeatureAskWhoIsWatching FeatureClearAudio FeatureDashWithTimeline FeatureDynamicSitemap FeatureEntertainment FeatureInternal FeatureLive FeatureQualityUpsell FeatureSport FeatureStripeBilled FeatureStudioPartlyUnhackable FeatureSubhub FeatureWidevineOrPlayReady)
   total: 9
   vendor: 2
   entries:
     22031 'No Activity (U.S.)'
     51596 'The Commons'
     4335811 'A bit of Weather'
     2781352 'Gemini Man (2016)'
     68428 'Haruki Test'
     2864503 'Cyberpunk 2077'
     3375921 'Nick Offerman\'s "Yule log"'
     1670804 'Audio described Parks and Rec'
     1622778 'Audio described Parks and Rec'

FeatureSport bit: 6
   total: 2
   vendor: 2
   entries:
     4335811 'A bit of Weather'
     2864503 'Cyberpunk 2077'

FeatureEntertainment bit: 44
   total: 7
   vendor: 2
   entries:
     22031 'No Activity (U.S.)'
     51596 'The Commons'
     2781352 'Gemini Man (2016)'
     68428 'Haruki Test'
     3375921 'Nick Offerman\'s "Yule log"'
     1670804 'Audio described Parks and Rec'
     1622778 'Audio described Parks and Rec'
```
See [for full results](cycle-feature.2.txt)
