
# CouldWatch Filter

[](https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#logsV2:log-groups/log-group/prod$252Frec/log-events$3Fstart$3D1765112400000$26end$3D1765198799000$26filterPattern$3D$257B$2524.path+$253D+$25255681682$2525+$257D)

```
{ $.eventType = %mlt%  && $.resultCount <= 1}
```

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
SELECT MIN(monday.event_time) fromtime, MAX(monday.event_time) untiltime FROM monday;
┌───────────────────────────────┬──────────────────────────────┐
│           fromtime            │          untiltime           │
│   timestamp with time zone    │   timestamp with time zone   │
├───────────────────────────────┼──────────────────────────────┤
│ 2025-12-08 03:09:32.049236+11 │ 2025-12-08 15:03:49.58781+11 │
└───────────────────────────────┴──────────────────────────────┘

```



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

# Look for similar but successful requests

## Select interestinmg sources

```
from foo.main.monday
  select
      param_source, count(*)
  group by 1
  order by 2 desc 
  limit 5
  ;
┌──────────────┬──────────────┐
│ param_source │ count_star() │
│   varchar    │    int64     │
├──────────────┼──────────────┤
│ 5681682      │           81 │
│ 5713271      │           24 │
│ 5713268      │            9 │
│ 5713264      │            9 │
│ 5455362      │            6 │
└──────────────┴──────────────┘

```


## CloudWatch Filter 5681682

[](https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#logsV2:log-groups/log-group/prod$252Frec/log-events$3Fstart$3D1765112400000$26end$3D1765198799000$26filterPattern$3D$257B$2524.path+$253D+$25255681682$2525+$257D)


```
{ $.eventType = %mlt% && $.path = %source=5681682%  && $.resultCount != 0 }
```

## Load results

```
CREATE TABLE notzero AS SELECT * FROM read_csv_auto('aws-log-reports/cloud-watch-events-12h-%mlt%-resultCount-notzero-5681682.tsv');
```

### Look at the stats
```

with feats as (
  select
    e.event_eventType,
    case when e.param_feat <> 'nil' or e.jwt_feat <> 'nil' then 'has_feat' else '' end has_URL_feat, 
    case when e.param_feat <> 'nil' then 'URL_feat' else '' end has_URL_feat, 
    case when e.jwt_feat <> 'nil' then 'jwToken_feat' else '' end as has_jwToken_feat,
    from notzero as e
)

select 'mlt_event_with_results', * from feats 
```

```
$ gawk 'NR!=1{print}' export.csv | frangipanni -breaks '",' -counts -no-fold
mlt_event_with_results: 150
    mlt-sport: 150
        has_feat: 149
            URL_feat: 5
                jwToken_feat: 5
            jwToken_feat: 144
```

### Compare with failed requests

Find all the common features that good requests have.

```
with feats as (
    from notzero as e
    select
      bit_and(cast( e.jwt_feat as int64)) as features
    where e.jwt_feat <> 'nil'
  )
  
  select features, lpad(to_base(features, 2), 64, '0') from feats ;
┌────────────────┬──────────────────────────────────────────────────────────────────┐
│    features    │               lpad(to_base(features, 2), 64, '0')                │
│     int64      │                             varchar                              │
├────────────────┼──────────────────────────────────────────────────────────────────┤
│ 17592186045696 │ 0000000000000000000100000000000000000000000000000000010100000000 │
└────────────────┴──────────────────────────────────────────────────────────────────┘

```

jared decoded: FeatureAskWhoIsWatching | FeatureDynamicSitemap | FeatureEntertainment

Find all the common features that _bad_ requests have.

```
with feats as (
    from monday as e
    select
      bit_and(cast( e.jwt_feat as int64)) as features
    where e.jwt_feat <> 'nil' and e.param_source = '5681682'
  )
  
  select features, lpad(to_base(features, 2), 64, '0') from feats ;
  
┌────────────────┬──────────────────────────────────────────────────────────────────┐
│    features    │               lpad(to_base(features, 2), 64, '0')                │
│     int64      │                             varchar                              │
├────────────────┼──────────────────────────────────────────────────────────────────┤
│ 17660907618560 │ 0000000000000000000100000001000000000000001000000000000100000000 │
└────────────────┴──────────────────────────────────────────────────────────────────┘

```
decoded: FeatureAskWhoIsWatching | FeatureStripeBilled | FeatureStudioPartlyUnhackable | FeatureEntertainment 

### Compare-by-eye

good: 0000000000000000000100000000000000000000000000000000010100000000
bad : 0000000000000000000100000001000000000000001000000000000100000000

### Compare with code

```
with bad_feats as (
      from monday as e
      select
        bit_and(cast( e.jwt_feat as bigint)) as features
      where e.jwt_feat <> 'nil' and e.param_source = '5681682'
  ),
  good_feats as (
      from notzero as e
      select
        bit_and(cast( e.jwt_feat as bigint)) as features
      where e.jwt_feat <> 'nil'
  ),
  
  not_in_bad as (select good_feats.features & ~bad_feats.features as missing from bad_feats, good_feats)
  
  select not_in_bad.missing, lpad(to_base(not_in_bad.missing, 2), 64, '0') 
  from not_in_bad;
┌─────────┬──────────────────────────────────────────────────────────────────┐
│ missing │          lpad(to_base(not_in_bad.missing, 2), 64, '0')           │
│  int64  │                             varchar                              │
├─────────┼──────────────────────────────────────────────────────────────────┤
│  1024   │ 0000000000000000000000000000000000000000000000000000010000000000 │
└─────────┴──────────────────────────────────────────────────────────────────┘

```

So there is only one feature which the good requests have and the bad requests do not. 
According to Jared this is FeatureDynamicSitemap


### Now look for all and any features

```
with feats as (
    from notzero as e
    select
      bit_or(cast( e.jwt_feat as int64)) as features
    where e.jwt_feat <> 'nil' and e.param_source = '5681682'
  )
  
  select features, lpad(to_base(features, 2), 64, '0') from feats ;  
┌─────────────────┬──────────────────────────────────────────────────────────────────┐
│    features     │               lpad(to_base(features, 2), 64, '0')                │
│      int64      │                             varchar                              │
├─────────────────┼──────────────────────────────────────────────────────────────────┤
│ 140728532400118 │ 0000000000000000011111111111110111101010001011101111011111110110 │
└─────────────────┴──────────────────────────────────────────────────────────────────┘

```
decoded: 
```
$ pbpaste | tr '| ' $'\n' | sort | column -x -c 170
FeatureAllowInAppPurchases			FeatureAskWhoIsWatching				FeatureClearAudio
FeatureDashWithTimeline				FeatureDolbyAtmos				FeatureDolbyVision
FeatureDynamicSitemap  				FeatureEntertainment				FeatureExperimentFourthCta
FeatureFairPlay					    FeatureGlobalised				FeatureHDR
FeatureHEVC					        FeatureInternal					FeatureLinearStream
FeatureLive					        FeatureLiveUHD					FeatureNewProfile
FeatureOlderProfile				    FeatureOptusBasicAndSportUpsellExperiment	FeaturePremiumPlan
FeatureQA					        FeatureQualityUpsell				FeatureSport
FeatureSportUpsell				    FeatureStandardPlan				FeatureStripeBilled
FeatureStudioHWSecurity				FeatureStudioPartlyUnhackable			FeatureStudioScreen2160
FeatureStudioUnhackable				FeatureSubhub					FeatureSubhubBilled
FeatureSubhubNav				    FeatureUhd					FeatureWidevineOrPlayReady

```

```
with feats as (
    from monday as e
    select
      bit_or(cast( e.jwt_feat as int64)) as features
    where e.jwt_feat <> 'nil' and e.param_source = '5681682'
  )
  
  select features, lpad(to_base(features, 2), 64, '0') from feats ;

┌────────────────┬──────────────────────────────────────────────────────────────────┐
│    features    │               lpad(to_base(features, 2), 64, '0')                │
│     int64      │                             varchar                              │
├────────────────┼──────────────────────────────────────────────────────────────────┤
│ 56611597883156 │ 0000000000000000001100110111110011101010001011101001011100010100 │
└────────────────┴──────────────────────────────────────────────────────────────────┘

```

decoded: 
```
$ pbpaste | tr '| ' $'\n' | sort 
FeatureAllowInAppPurchases
FeatureAskWhoIsWatching
FeatureClearAudio
FeatureDashWithTimeline
FeatureDynamicSitemap
FeatureEntertainment
FeatureExperimentFourthCta
FeatureFairPlay
FeatureHDR
FeatureHEVC
FeatureLive
FeatureLiveUHD
FeatureNewProfile
FeatureOlderProfile
FeaturePremiumPlan
FeatureQualityUpsell
FeatureSportUpsell
FeatureStandardPlan
FeatureStripeBilled
FeatureStudioHWSecurity
FeatureStudioPartlyUnhackable
FeatureStudioScreen2160
FeatureStudioUnhackable
FeatureUhd
FeatureWidevineOrPlayReady
```

### compare by eye

```
good:0000000000000000011111111111110111101010001011101111011111110110
bad :0000000000000000001100110111110011101010001011101001011100010100
```
### Compare with code

```
with bad_feats as (
      from monday as e
      select
        bit_or(cast( e.jwt_feat as bigint)) as features
      where e.jwt_feat <> 'nil' and e.param_source = '5681682'
  ),
  good_feats as (
      from notzero as e
      select
        bit_or(cast( e.jwt_feat as bigint)) as features
      where e.jwt_feat <> 'nil' and e.param_source = '5681682'
  ),
  not_in_bad as (select good_feats.features & ~bad_feats.features as missing from bad_feats, good_feats)
  
  
  select not_in_bad.missing, lpad(to_base(not_in_bad.missing, 2), 64, '0') 
  from not_in_bad;
┌────────────────┬──────────────────────────────────────────────────────────────────┐
│    missing     │          lpad(to_base(not_in_bad.missing, 2), 64, '0')           │
│     int64      │                             varchar                              │
├────────────────┼──────────────────────────────────────────────────────────────────┤
│ 84116934516962 │ 0000000000000000010011001000000100000000000000000110000011100010 │
└────────────────┴──────────────────────────────────────────────────────────────────┘

```

decoded: FeatureInternal | FeatureQA | FeatureSport | FeatureGlobalised | FeatureDolbyVision | FeatureDolbyAtmos | FeatureLinearStream | FeatureSubhubBilled | FeatureSubhub | FeatureSubhubNav | FeatureOptusBasicAndSportUpsellExperiment
```
$ echo $FOO | tr -d ' ' | tr '|' $'\n' | sort
FeatureDolbyAtmos
FeatureDolbyVision
FeatureGlobalised
FeatureInternal
FeatureLinearStream
FeatureOptusBasicAndSportUpsellExperiment
FeatureQA
FeatureSport
FeatureSubhub
FeatureSubhubBilled
FeatureSubhubNav
```

### Do any of the bad requests have FeatureSport?

```
from monday as e
      select
        cast( e.jwt_feat as int64) & 64 = 64 as jwt_FeatureSport, count(*) as number
      where e.jwt_feat <> 'nil'
      group by 1
      ;
┌──────────────────┬────────┐
│ jwt_FeatureSport │ number │
│     boolean      │ int64  │
├──────────────────┼────────┤
│ false            │    186 │
│ true             │      6 │
└──────────────────┴────────┘
from events as e
      select
        cast( e.jwt_feat as int64) & 64 = 64 as FeatureSport, count(*) as number
      where e.jwt_feat <> 'nil'
      group by 1
      ;
┌──────────────┬────────┐
│ FeatureSport │ number │
│   boolean    │ int64  │
├──────────────┼────────┤
│ false        │    149 │
│ true         │      5 │
└──────────────┴────────┘

```


#### Summary

I have now compared the Features supplied in requests which get results (good) and those that do not (bad),
for the same source program (5681682, Opetaia v Cinkara: Pay-Per-View 2025).

None of the bad requests have any of these features which occur in one or more of the good requests:

    FeatureDolbyAtmos
    FeatureDolbyVision
    FeatureGlobalised
    FeatureInternal
    FeatureLinearStream
    FeatureOptusBasicAndSportUpsellExperiment
    FeatureQA
    FeatureSport
    FeatureSubhub
    FeatureSubhubBilled
    FeatureSubhubNav

Every single MLT item served to good clients for 5681682 MLT all have features.required: 64 (FeatureSport), this comes from CMS.

So it seems that _none_ of these failed requests for 5681682 MLT have the Sport feature which is required.

In fact in the 24 hours in the sample data, of those providing a jwToken, for any source program,
only 11 have the FeatureSport, 335 do not.

This is 3% with a jwt and FeatureSport.

This validates the assumption that the Features are wrong, we should get 88% * 97% = 85% improvement or close. 

##### Aside

Also _all_ of the failed requests do not have the FeatureDynamicSitemap bit set. 

In streamco-pages I found this:
```
		if feed.source != "catalogue" && feed.source != "editorial" {
			// Skip any personalised (i.e. non editorial) feeds where the app doesn't support them
			if !req.Features.Has(auth.FeatureDynamicSitemap) {
				continue
			}
		}
```        
I think this means these clients will never see MLT on the main page?
        
#### Sidebar: SQL ExplanationGPT

is:

Reading from table notzero (aliased as e).

* Filtering out rows where jwt_feat = 'nil'.
* Casting jwt_feat from a string to INT64:
* CAST(e.jwt_feat AS int64)


Applying the bitwise AND aggregate function to all remaining rows:

`bit_and(...)`


So you end up with a single INT64 value representing the bitwise-AND of all rows’ jwt_feat values.

The final SELECT:

```
SELECT lpad(to_base(features, 2), 64, '0')
FROM feats;
```

Does this:

`to_base(features, 2)`

Converts the integer into a binary string.

E.g. 8 → '1000'.

`lpad(..., 64, '0')`

Left-pads the binary with zeros to make a 64-bit representation.

E.g.:

'1000'
→ '0000000000000000000000000000000000000000000000000000000000001000'


So you always get a full fixed-width 64-bit mask.
The output is one row containing:
* the bitwise AND across all jwt_feat rows
* represented as a 64-bit zero-padded binary string

