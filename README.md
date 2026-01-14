
# BS-2647 A/B Test: Evaluate Google Media Search as Primary Engine for Conversion Uplift vs. API Cost.
# Huddle with Ray 8.1.2026:

Ray is on annual leave Friday 8th - Monday 18th.

ray.xu
  Today at 14:56
https://docs.google.com/spreadsheets/d/1iz029gnt4o4XtFS1qj6ICJgxn7zS1uI2FRpQ3HNR3TE/edit?gid=727922942#gid=727922942
ray.xu
  25 minutes ago
https://github.com/StreamCo/streamco-search/pull/125


#

## time band for data

```
duckdb -c "select min(event_serverTime), max(event_serverTime) from 'search.userID.eq.1.tsv' "                                                                                                                                   
┌───────────────────────┬───────────────────────┐
│ min(event_serverTime) │ max(event_serverTime) │                                                                                                                                                                                                           
│         int64         │         int64         │                                                                                                                                                                                                           
├───────────────────────┼───────────────────────┤                                                                                                                                                                                                           
│     1768188871181     │     1768190635758     │                                                                                                                                                                                                           
│    (1.77 trillion)    │    (1.77 trillion)    │                                                                                                                                                                                                           
└───────────────────────┴───────────────────────┘                                                                                                                                                                                                           
$ gdate -d @1768188871
Mon Jan 12 14:34:31 AEDT 2026
$ gdate -d @1768190635
Mon Jan 12 15:03:55 AEDT 2026
```

and

```
$ duckdb -line -c "select min(event_serverTime), max(event_serverTime) from 'search.userID.eq.1.vendor.neq.2.tsv' "
min(event_serverTime) = 1768189586710
max(event_serverTime) = 1768191417051

$ gdate -d @1768189586
Mon Jan 12 14:46:26 AEDT 2026
$ gdate -d @1768191417
Mon Jan 12 15:16:57 AEDT 2026

```


```
{ ( $.userID = %^1% )  && $.path = %/search% && $.vendor != 2 }
```

```
mv ~/Downloads/log-events-viewer-result\ \(2\).csv search.userID.eq.1.vendor.neq.2.csv
 ```
 
# Interesting Queries

Where the search results in no entries and the userID begins with '1'

```
$ duckdb -c "select param_q from 'search.userID.eq.1.vendor.neq.2.tsv' where event_programIDs == 'nil'" 
┌───────────────────────────────────────┐
│                param_q                │                                                                                                                                                                                                                   
│                varchar                │                                                                                                                                                                                                                   
├───────────────────────────────────────┤                                                                                                                                                                                                                   
│ 000                                   │                                                                                                                                                                                                                   
│ 0000                                  │                                                                                                                                                                                                                   
│ 00000                                 │                                                                                                                                                                                                                   
│ 000000                                │                                                                                                                                                                                                                   
│ 0000000                               │                                                                                                                                                                                                                   
│ migran                                │                                                                                                                                                                                                                   
│ aag                                   │                                                                                                                                                                                                                   
│ Jur                                   │                                                                                                                                                                                                                   
│ tv                                    │                                                                                                                                                                                                                   
│ quadro                                │                                                                                                                                                                                                                   
│ brin                                  │                                                                                                                                                                                                                   
│ related:Bring Her Back                │                                                                                                                                                                                                                   
│ related:Bring It On                   │                                                                                                                                                                                                                   
│ wip                                   │                                                                                                                                                                                                                   
│ th0                                   │                                                                                                                                                                                                                   
│ Iconi                                 │                                                                                                                                                                                                                   
│ Iconic                                │                                                                                                                                                                                                                   
│ 1h                                    │                                                                                                                                                                                                                   
│ 1he                                   │                                                                                                                                                                                                                   
│ 1he+                                  │                                                                                                                                                                                                                   
│ related:Devil in a Blue Dress         │                                                                                                                                                                                                                   
│ related:The Devil Inside              │                                                                                                                                                                                                                   
│ abcdefghij                            │                                                                                                                                                                                                                   
│ abcdefghijk                           │                                                                                                                                                                                                                   
│ abcdefghijkl                          │                                                                                                                                                                                                                   
│ occ                                   │                                                                                                                                                                                                                   
│ Vo                                    │                                                                                                                                                                                                                   
│ Update cred                           │                                                                                                                                                                                                                   
│ related:What%27s Eating Gilbert Grape │                                                                                                                                                                                                                   
│ related:Predator                      │                                                                                                                                                                                                                   
│ 80s                                   │                                                                                                                                                                                                                   
│ related:The Night Manager             │                                                                                                                                                                                                                   
│ related:David Brent: Life on the Road │                                                                                                                                                                                                                   
│ related:The Notebook                  │                                                                                                                                                                                                                   
│ seriesss                              │                                                                                                                                                                                                                   
│ kickas                                │                                                                                                                                                                                                                   
│ related:Affeksjonsverdi               │                                                                                                                                                                                                                   
│ related:Afflicted                     │                                                                                                                                                                                                                   
│ related:Affliction                    │                                                                                                                                                                                                                   
│ related:The Affair                    │                                                                                                                                                                                                                   
├───────────────────────────────────────┤                                                                                                                                                                                                                   
│                40 rows                │                                                                                                                                                                                                                   
└───────────────────────────────────────┘                                                                                                                                                                                                                   

```

Better

```
$ duckdb -line -c "select param_q from 'search.userID.eq.1.vendor.neq.2.tsv' where param_q not like 'related:%' and event_programIDs == 'nil'" | awk -F ' = ' '/=/ && !/related:/ {print $2}'
000
0000
00000
000000
0000000
migran
aag
Jur
tv
quadro
brin
wip
th0
Iconi
Iconic
1h
1he
1he+
abcdefghij
abcdefghijk
abcdefghijkl
occ
Vo
Update cred
80s
seriesss
kickas
```

### What kinds of search in the results?

```
$ duckdb -c "select event_vendor, event_model, event_searchType, count(*) from 'cloudwatch/search.userID.eq.1.vendor.neq.2.tsv' group by 1,2,3 union all select event_vendor, event_model, event_searchType, count(*) from
 'cloudwatch/search.userID.eq.1.tsv' group by 1,2,3"
┌─────────────────────┬────────────────────────┬──────────────┐
│     event_model     │    event_searchType    │ count_star() │                                                                                                                                                                                             
│       varchar       │        varchar         │    int64     │                                                                                                                                                                                             
├─────────────────────┼────────────────────────┼──────────────┤                                                                                                                                                                                             
│ stan-search         │ chop_last_char         │           35 │                                                                                                                                                                                             
│ stan-search         │ imdb_search            │           35 │                                                                                                                                                                                             
│ stan-search         │ split_words            │          123 │                                                                                                                                                                                             
│ stan-search         │ full_match             │         1267 │                                                                                                                                                                                             
│ stan-search         │ fuzzy_search           │           15 │                                                                                                                                                                                             
│ google-media-search │ discovery_media_search │           77 │                                                                                                                                                                                             
└─────────────────────┴────────────────────────┴──────────────┘                                                                                                                                                                                             

```
## fuzzy search queries

b$  duckdb -c "select param_q from 'cloudwatch/search.userID.eq.1.vendor.neq.2.tsv' where event_searchType = 'fuzzy_search' and param_q not like 'related:%' "                               
┌────────────┐
│  param_q   │                                                                                                                                                                                                                                              
│  varchar   │                                                                                                                                                                                                                                              
├────────────┤                                                                                                                                                                                                                                              
│ helan      │                                                                                                                                                                                                                                              
│ Transfornm │                                                                                                                                                                                                                                              
│ Twins      │                                                                                                                                                                                                                                              
│ Jerse      │                                                                                                                                                                                                                                              
│ jesus      │                                                                                                                                                                                                                                              
│ Jesus      │                                                                                                                                                                                                                                              
│ spirited   │                                                                                                                                                                                                                                              
│ japaneswe  │                                                                                                                                                                                                                                              
│ findi      │                                                                                                                                                                                                                                              
│ breakfas   │                                                                                                                                                                                                                                              
│ Shift      │                                                                                                                                                                                                                                              
│ Shifting   │                                                                                                                                                                                                                                              
│ seriesss   │                                                                                                                                                                                                                                              
│ kickas     │                                                                                                                                                                                                                                              
│ Loveis     │                                                                                                                                                                                                                                              
├────────────┤                                                                                                                                                                                                                                              
│  15 rows   │                                                                                                                                                                                                                                              
└────────────┘       

## imdb search queries

```
$  duckdb -c "select param_q from 'cloudwatch/search.userID.eq.1.vendor.neq.2.tsv' where event_searchType = 'imdb_search' and param_q not like 'related:%' "                            
┌──────────────┐
│   param_q    │                                                                                                                                                                                                                                            
│   varchar    │                                                                                                                                                                                                                                            
├──────────────┤                                                                                                                                                                                                                                            
│ 000          │                                                                                                                                                                                                                                            
│ 0000         │                                                                                                                                                                                                                                            
│ 00000        │                                                                                                                                                                                                                                            
│ 000000       │                                                                                                                                                                                                                                            
│ 0000000      │                                                                                                                                                                                                                                            
│ migran       │                                                                                                                                                                                                                                            
│ aag          │                                                                                                                                                                                                                                            
│ Jur          │                                                                                                                                                                                                                                            
│ tv           │                                                                                                                                                                                                                                            
│ quadro       │                                                                                                                                                                                                                                            
│ wip          │                                                                                                                                                                                                                                            
│ th0          │                                                                                                                                                                                                                                            
│ 1h           │                                                                                                                                                                                                                                            
│ 1he          │                                                                                                                                                                                                                                            
│ 1he+         │                                                                                                                                                                                                                                            
│ abcdefghij   │                                                                                                                                                                                                                                            
│ abcdefghijk  │                                                                                                                                                                                                                                            
│ abcdefghijkl │                                                                                                                                                                                                                                            
│ occ          │                                                                                                                                                                                                                                            
│ Vo           │                                                                                                                                                                                                                                            
│ Update cred  │                                                                                                                                                                                                                                            
│ 80s          │                                                                                                                                                                                                                                            
├──────────────┤                                                                                                                                                                                                                                            
│   22 rows    │                                                                                                                                                                                                                                            
└──────────────┘                                                                                                                                                                                                                                            
```


## Find users without the Internal feature
```
$ duckdb -c "select distinct jwt_uid from 'cloudwatch/search.userID.eq.1.tsv' where event_userID like '1%' and not jwt_feat & (1<<4)"
┌──────────────────────────────────┐
│             jwt_uid              │
│             varchar              │
├──────────────────────────────────┤
│ 1c958a38237446c1ac549ffadfbd2c06 │
│ 1d09c1dc81a449f7aa085a50d3b0fb39 │
│ 178b0286aeb24241a795d69ad6f20750 │
│ 197a141da6864213940781ad508a22cb │
│ 1f34b61d23ab4b0b96b080600b3664a6 │
│ 1fba4b429da64f508c4e5c458d45d64f │
│ 195a480ec1894538be7d6200f0b95b5c │
│ 1bbe8a6a66b34a138f79d63ef98b482f │
│ 110d96a4ee474a7eb85019493e5bd4f3 │
│ 137ed3f6b5974e4da98f42525427751d │
│ 11ff0e2649654de6b218d3aaf8486434 │
│ 16306d8d3f7b4533a6aa1c882b7b5769 │
│ 11ae3f92bedb4233af2fe8fe5c3e99c7 │
│ 1a780970f0954aa588f2784896d4b21b │
│ 1288cd63e21e44ddbfee57c73d3ce5a5 │
│ 195f6e0580b2473098be921fdd8dfed2 │
├──────────────────────────────────┤
│             16 rows              │
└──────────────────────────────────┘
```


# Percentage of searches by first character of the userID from a one minute period

```
b$ duckdb -f userid-first-char.sql                                                                                                                                                           
┌───────────────────┬────────────┐
│ userID_first_char │ percentage │                                                                                                                                                                                                                          
│      varchar      │   double   │                                                                                                                                                                                                                          
├───────────────────┼────────────┤                                                                                                                                                                                                                          
│ 0                 │       7.26 │                                                                                                                                                                                                                          
│ 1                 │       6.48 │                                                                                                                                                                                                                          
│ 2                 │       4.92 │                                                                                                                                                                                                                          
│ 3                 │       8.16 │                                                                                                                                                                                                                          
│ 4                 │      12.51 │                                                                                                                                                                                                                          
│ 5                 │       7.37 │                                                                                                                                                                                                                          
│ 6                 │       4.02 │                                                                                                                                                                                                                          
│ 7                 │       6.15 │                                                                                                                                                                                                                          
│ 8                 │       8.16 │                                                                                                                                                                                                                          
│ 9                 │       6.93 │                                                                                                                                                                                                                          
│ a                 │       5.36 │                                                                                                                                                                                                                          
│ b                 │       2.57 │                                                                                                                                                                                                                          
│ c                 │       7.49 │                                                                                                                                                                                                                          
│ d                 │       3.35 │                                                                                                                                                                                                                          
│ e                 │       5.03 │                                                                                                                                                                                                                          
│ f                 │       4.25 │                                                                                                                                                                                                                          
├───────────────────┴────────────┤                                                                                                                                                                                                                          
│ 16 rows              2 columns │                                                                                                                                                                                                                          
└────────────────────────────────┘                                                                                                                                                                                                                          
```

# Some production userids and tokens for testing

```
$ duckdb -list -f userids-for-testing.sql > userids-for-testing.list
```
example
```
userID_first_char|event_userID|feat|param_jwtoken
8|88a1bf210ab74afc9bf9cdee57ecbbe7|166152|redacted
c|c42064ae89a945858d6eddf946fc2ef9|132872|redacted
```

## Check for expired JWTokens in the data sample

There are none. Proof:

```
$ duckdb -csv -f expired-tokens.sql 
number_expired_tokens
0
```

# Footnotes
## Now using jwtdecode instead of jwt-cli decode - check the changes
### Now dates are passed as epoch. Are they the same?

No. strangely, the jwt-cli decode returns a incorrect dates! So the `jwtdecode.bin` is better. 
Proof:

```
$ duckdb -f compare-log-unpacks.sql 
┌──────────────────────┬────────────┬──────────────────────┐
│        oldexp        │   newexp   │          ts          │                                                                                                                                                                                                
│       varchar        │  varchar   │       varchar        │                                                                                                                                                                                                
├──────────────────────┼────────────┼──────────────────────┤                                                                                                                                                                                                
│ 2026-05-11T01:47:28Z │ 1778466553 │ 2026-05-11T02:29:13Z │                                                                                                                                                                                                
│ 2026-05-11T01:54:24Z │ 1778466585 │ 2026-05-11T02:29:45Z │                                                                                                                                                                                                
│ 2026-05-11T02:29:05Z │ 1778466583 │ 2026-05-11T02:29:43Z │                                                                                                                                                                                                
│ 2026-05-11T02:29:13Z │ 1778464048 │ 2026-05-11T01:47:28Z │                                                                                                                                                                                                
│ 2026-05-11T02:29:26Z │ 1778466616 │ 2026-05-11T02:30:16Z │                                                                                                                                                                                                
│ 2026-05-11T02:29:43Z │ 1778466545 │ 2026-05-11T02:29:05Z │                                                                                                                                                                                                
│ 2026-05-11T02:29:45Z │ 1778464464 │ 2026-05-11T01:54:24Z │                                                                                                                                                                                                
│ 2026-05-11T02:30:16Z │ 1778466566 │ 2026-05-11T02:29:26Z │                                                                                                                                                                                                
└──────────────────────┴────────────┴──────────────────────┘                                                                                                                                                                                                
$ gdate -d @1778466616 -u                                                                                                                                              
Mon May 11 02:30:16 UTC 2026
$ gdate -d @1778466616 -u
Mon May 11 02:30:16 UTC 2026
```

## Look at the searches over time
```
$ duckdb -csv -c "select jwt_uid, param_q, event_model, event_totalResults from 'cloudwatch/search.2026.01.11.13.30.tsv' order by jwt_uid, event_serverTime" | visidata -
```
examples
```
│ e2602d28db2546d08bb8108c821fdcde │ be                                       │ stan-search         │                 30 │                                                                                                                                  
│ e2602d28db2546d08bb8108c821fdcde │ ben                                      │ stan-search         │                 30 │                                                                                                                                  
│ e2602d28db2546d08bb8108c821fdcde │ benn                                     │ stan-search         │                  3 │                                                                                                                                  
│ e2602d28db2546d08bb8108c821fdcde │ benne                                    │ stan-search         │                  0 │                                                                                                                                  
│ e2602d28db2546d08bb8108c821fdcde │ bennet                                   │ stan-search         │                  0 │                                                                                                                                  
│ e2602d28db2546d08bb8108c821fdcde │ bennett                                  │ google-media-search │                 30 │                                                                                                                                  

│ d2e4277b2b3e48bc806dd0d3ffa5d256 │ pr                                       │ stan-search         │                 30 │                                                                                                                                  
│ d2e4277b2b3e48bc806dd0d3ffa5d256 │ pri                                      │ stan-search         │                 30 │                                                                                                                                  
│ d2e4277b2b3e48bc806dd0d3ffa5d256 │ prim                                     │ stan-search         │                  2 │                                                                                                                                  
│ d2e4277b2b3e48bc806dd0d3ffa5d256 │ prima                                    │ stan-search         │                  2 │                                                                                                                                  
│ d2e4277b2b3e48bc806dd0d3ffa5d256 │ primat                                   │ google-media-search │                 10 │                                                                                                                                  
│ d2e4277b2b3e48bc806dd0d3ffa5d256 │ primati                                  │ google-media-search │                 17 │                                                                                                                                  
│ d2e4277b2b3e48bc806dd0d3ffa5d256 │ primativ                                 │ stan-search         │                  0 │  
```

## Use the new log file unpacker to query on feature names

Unpack the log file. It rejects JWT in records with invalid UTF-8 sequences.

```
$ odin run cloudwatchlog -- cloudwatch/search.2026.01.11.13.30.csv > cloudwatch/search.2026.01.11.13.30.odin.tsv
128 error decoding JWT BadJSON {"header": {"alg":"HS256","kid":"pikachu","typ":"JWT"}, "payload": {"exp":1778466593,"iat":1768098593,"jti":"d6ac162ab21c4b8bb25417639366a492","role":"user","uid":"ed16bef9465f44a89b2f2910bdb292c9","streams":"hd","concurrency":4,"profileId":"36cc1ff5bee0401495d3bd216ee86f8e","profileName":"bubbas🫶??","kids":true,"tz":"Australia/Hobart","app":"Stan-AndroidTV","ver":"5.17.0","nuid":"e99f1bfd4d334695bed401a9f4bcd0c7","apid":"b342799e-2968-0bb0-8181-938dd21607ee","feat":53945329125128,"priceName":"premiumv6"}, "signature": "FYFMGl2lF5O-q_RK6v3yR-CFBANH2YpI015pittySW4" }
133 error decoding JWT BadJSON {"header": {"alg":"HS256","kid":"pikachu","typ":"JWT"}, "payload": {"exp":1778466593,"iat":1768098593,"jti":"d6ac162ab21c4b8bb25417639366a492","role":"user","uid":"ed16bef9465f44a89b2f2910bdb292c9","streams":"hd","concurrency":4,"profileId":"36cc1ff5bee0401495d3bd216ee86f8e","profileName":"bubbas🫶??","kids":true,"tz":"Australia/Hobart","app":"Stan-AndroidTV","ver":"5.17.0","nuid":"e99f1bfd4d334695bed401a9f4bcd0c7","apid":"b342799e-2968-0bb0-8181-938dd21607ee","feat":53945329125128,"priceName":"premiumv6"}, "signature": "FYFMGl2lF5O-q_RK6v3yR-CFBANH2YpI015pittySW4" }
207 error decoding JWT BadJSON {"header": {"alg":"HS256","kid":"pikachu","typ":"JWT"}, "payload": {"exp":1778466593,"iat":1768098593,"jti":"d6ac162ab21c4b8bb25417639366a492","role":"user","uid":"ed16bef9465f44a89b2f2910bdb292c9","streams":"hd","concurrency":4,"profileId":"36cc1ff5bee0401495d3bd216ee86f8e","profileName":"bubbas🫶??","kids":true,"tz":"Australia/Hobart","app":"Stan-AndroidTV","ver":"5.17.0","nuid":"e99f1bfd4d334695bed401a9f4bcd0c7","apid":"b342799e-2968-0bb0-8181-938dd21607ee","feat":53945329125128,"priceName":"premiumv6"}, "signature": "FYFMGl2lF5O-q_RK6v3yR-CFBANH2YpI015pittySW4" }
```

```
$ duckdb -csv -c "select jwt_profileName from read_csv('voo.tsv', delim = '\t',ignore_errors = true) where jwt_features like '%Premium%'"
```