
# Setup for testing & experiments

Go to the `streamco-rec` project

to run in the debugger

`streamco-env -env test rec bash`

To run the IDE

`goland &`

then run the app from the build `go build github.com/streamco/streamco-rec/cmd/api`


To hit the service:

`,curl 'http://localhost:5000/related?genres=Sport%2CFootball&source=5487021' | goyamp `



## error from `res, err := r.client.Recommend(context.TODO(), &discoveryenginepb.RecommendRequest{`

Will have to use the Mock Google becuse of errors:


```
servingConfig 'projects/340734754121/locations/global/collections/default_collection/dataStores/default_data_store/servingConfigs/mlt-cvr-srv' 
 not found for location global and project_number 340734754121. If you just created this resource
  (for example, by activating your project), it may take up 5 minutes for the resource(s) to be activated.`
```

# Paging results
 
# next page of results

```
https://api.test.streamco.com.au/rec/v1/related?feat=23436565677378&genres=Sport&offset=30&purchases=0&source=2835091
```

This looks like a bug. The basefeed is full of Next links like above. But these lines chop it back to 15, so 
if the next link is used it will skip every 15 items.

```
	basefeed := h.feedbuilder.BuildFeed(r.Context(), feedReq, respPrograms, filters...)

	// Special sports rule cap results to 15 items for sports related mlt, doing after as dont want less than 15 items
	if hasSportsCategory && len(basefeed.Items) > 15 {
		basefeed.Items = basefeed.Items[:15] // Will make parameter in feed builder in future
	}
```

The total is not the number of items. It misses 15 results every page. 

```
$ ,curl "http://localhost:5000/related?genres=Sport&source=2835091&jwToken=$jwtoken" | goyamp | grep -e '^    title:' -e total:
    title: Chiefs v Brumbies - Super Rugby Pacific Round 3 2025
    title: Force v Brumbies - Super Rugby Women's Round 1 2025
    title: Force v Reds - Super Rugby Pacific Round 3 2025
    title: Hurricanes v Blues - Super Rugby Pacific Round 3 2025
    title: Moana Pasifika v Highlanders - Super Rugby Pacific Round 3 2025
    title: Queensland Reds Under 16 v NSW Waratahs Under 16 - Men's Super Rugby U16 2024
    title: Session test
    title: Super Rugby AU Rd 1 - Force v Brumbies
    title: Super Rugby AU Rd 1 - Reds v Waratahs
    title: Super Rugby AU Rd 2 - Reds v Rebels
    title: Super Rugby AU Rd 3 - Brumbies v Waratahs
    title: Super Rugby AU Rd 3 - Waratahs v Force
    title: Super Rugby AU Rd 7 - Western Force vs. Waratahs
    title: Super Rugby AU Rd 8 Western Force vs. Reds
    title: TEST Everton v Bournemouth - Summer Series MD1 2025
total: 90
```

and in the next page

```
$ ,curl "http://localhost:5000/related?genres=Sport&source=2835091&offset=30&jwToken=$jwtoken" | goyamp | grep -e '^    title:' -e total:
    title: Jess v Jess Roland Garros Test - Day 1 2025
    title: Jess v Kris Roland Garros Test - Day 1 2025
    title: Jess v Sahar Roland Garros Test - Day 1 2025
    title: Jess v Sahar US Open Test - Day 2 2025
    title: Juventus v PSV - UEFA Champions League 2024/2025
    title: Kris v Jess US Open Test - Day 2 2025
    title: Kris v Seb US Open Test - Day 2 2025
    title: KÍ v Borac Banja Luka - UEFA Europa League 2024/2025
    title: Live test
    title: Liverpool v Real Madrid TEST
    title: Martin Zapata v Daman Saudi
    title: Maximilian Marterer - Nino Serdarusic
    title: Men's Coxless Four Heats - Rowing - Olympics Test Feature
    title: Men’s 10m Air Pistol Final - Shooting - Olympic Test Feature
    title: Michael Darklogo3
total: 90
```
But this is not relevant to the FEF

# Empty or not found source form field gets zero entries with no JWT

```
$ ,curl "http://api.stan.com.au/rec/v1/related?genres=optussport&source=121212" | goyamp #| grep  -e '^    title:'  -e total: -e next: -e vendor:
entries: []
model: related
title: More Like This
total: 0
updated: 1764569423
vendor: 1
```

# `play.stan` and `play.test` give different results for unknown source with bad token

PROD

```
bash-5.3$ ,curl "http://api.stan.com.au/rec/v1/related?genres=Sport&source=111111&A=1&jwToken=$jwtoken" | goyamp | grep  -e '^    title:'  -e total: -e next: -e vendor:
total: 0
vendor: 1
```

TEST 

```
bash-5.3$ ,curl "http://api.test.streamco.com.au/rec/v1/related?genres=Sport&source=111111&A=1&jwToken=$jwtoken" | goyamp | grep  -e '^    title:'  -e total: -e next: -e vendor:
    title: ARC18.3 Men's Individual Quarterfinal
    title: AZ v Elfsborg - UEFA Europa League 2024/2025
    title: Athletic Club v Slavia Praha - UEFA Europa League 2024/2025
    title: Chelsea v Manchester United
    title: Elfsborg v Pafos - UEFA Europa League 2024/2025
    title: Football - Spain v Australia - Olympic Football TEST Feature
    title: How to be accepted by the dev team
    title: How to replace your CMS with airtable
    title: Internazionale v Crvena zvezda - UEFA Champions League 2024/2025
    title: Jess v Jess Roland Garros Test - Day 1 2025
    title: Jess v Kris Roland Garros Test - Day 1 2025
    title: Jess v Sahar Roland Garros Test - Day 1 2025
    title: Jess v Sahar US Open Test - Day 2 2025
    title: Juventus v PSV - UEFA Champions League 2024/2025
    title: Kris v Jess US Open Test - Day 2 2025
    title: Kris v Seb US Open Test - Day 2 2025
    title: KÍ v Borac Banja Luka - UEFA Europa League 2024/2025
    title: Live test
    title: Liverpool v Real Madrid TEST
    title: Martin Zapata v Daman Saudi
    title: Maximilian Marterer - Nino Serdarusic
    title: Men's Coxless Four Heats - Rowing - Olympics Test Feature
    title: Men’s 10m Air Pistol Final - Shooting - Olympic Test Feature
    title: Michael Darklogo3
    title: Michael Shortform Testing
    title: Mike Test
    title: Mixed Group Stage - Badminton - Olympic Test Feature
    title: Olympics Test Asset
    title: Ring of Fire - PPV Test
    title: SMWYG - Dynamic query all the things
next: https://api.test.streamco.com.au/rec/v1/related?feat=23436565677378&genres=Sport&offset=30&purchases=0&source=111111
total: 90
vendor: 1
```

# but similar results with a good token

Prod

```
bash-5.3$ ,curl "http://api.stan.com.au/rec/v1/related?genres=Sport&source=111111&A=1&jwToken=$prodToken" | goyamp | grep  -e '^    title:'  -e total: -e next: -e vendor:
    title: 71 goals on Matchday 3 set a new record for the competition's highest-scoring matchday.
    title: AC Milan v Liverpool - UEFA Champions League 2024/2025
    title: APOEL v Astana - UEFA Conference League 2024/2025
    title: APOEL v Borac Banja Luka - UEFA Conference League 2024/2025
    title: APOEL v Fiorentina - UEFA Conference League 2024/2025
    title: ARG v AUS, The Rugby Championship, 6 Oct 2012
    title: ARG v AUS, Tri Nations, 21 Nov 2020
    title: ARG v NZ, The Rugby Championship, 1 Oct 2016
    title: ARG v NZ, The Rugby Championship, 20 Jul 2019
    title: ARG v NZ, The Rugby Championship, 27 Sep 2014
    title: ARG v NZ, The Rugby Championship, 28 Sep 2013
    title: ARG v NZ, The Rugby Championship, 29 Sep 2012
    title: ARG v NZ, The Rugby Championship, 29 Sep 2018
    title: ARG v NZ, The Rugby Championship, 30 Sep 2017
    title: ARG v SA, The Rugby Championship, 24 Aug 2013
    title: ARG v SA, The Rugby Championship, 25 Aug 2012
    title: ARG v SA, The Rugby Championship, 25 Aug 2018
    title: AUS v ARG, International, 17 Jun 2000
    title: AUS v ARG, The Rugby Championship, 27 Jul 2019
    title: AUS v ARG, Tri Nations, 5 Dec 2020
    title: AUS v ENG, International, 17 Jun 2006
    title: AUS v IRE, International, 26 Jun 2010
    title: AUS v IRE, International, 9 Jun 2018
    title: AUS v NZ, Bledisloe Cup, 1 Sep 2001
    title: AUS v NZ, Bledisloe Cup, 11 Sep 2010
    title: AUS v NZ, Bledisloe Cup, 13 Aug 2005
    title: AUS v NZ, Bledisloe Cup, 13 Sep 2008
    title: AUS v NZ, Bledisloe Cup, 15 Jul 2000
    title: AUS v NZ, Bledisloe Cup, 20 Oct 2012
    title: AUS v NZ, Bledisloe Cup, 21 Oct 2017
next: https://api.stan.com.au/rec/v1/related?feat=23162224641856&genres=Sport&offset=30&purchases=0&source=111111
total: 90
vendor: 1
```

Test


```
bash-5.3$ ,curl "http://api.test.streamco.com.au/rec/v1/related?genres=Sport&source=111111&A=1&jwToken=$testToken" | goyamp | grep  -e '^    title:'  -e total: -e next: -e vendor:
    title: ARC18.3 Men's Individual Quarterfinal
    title: AZ v Elfsborg - UEFA Europa League 2024/2025
    title: Athletic Club v Slavia Praha - UEFA Europa League 2024/2025
    title: Chelsea v Manchester United
    title: Elfsborg v Pafos - UEFA Europa League 2024/2025
    title: Football - Spain v Australia - Olympic Football TEST Feature
    title: How to be accepted by the dev team
    title: How to replace your CMS with airtable
    title: Internazionale v Crvena zvezda - UEFA Champions League 2024/2025
    title: Jess v Jess Roland Garros Test - Day 1 2025
    title: Jess v Kris Roland Garros Test - Day 1 2025
    title: Jess v Sahar Roland Garros Test - Day 1 2025
    title: Jess v Sahar US Open Test - Day 2 2025
    title: Juventus v PSV - UEFA Champions League 2024/2025
    title: Kris v Jess US Open Test - Day 2 2025
    title: Kris v Seb US Open Test - Day 2 2025
    title: KÍ v Borac Banja Luka - UEFA Europa League 2024/2025
    title: Live test
    title: Liverpool v Real Madrid TEST
    title: Martin Zapata v Daman Saudi
    title: Maximilian Marterer - Nino Serdarusic
    title: Men's Coxless Four Heats - Rowing - Olympics Test Feature
    title: Men’s 10m Air Pistol Final - Shooting - Olympic Test Feature
    title: Michael Darklogo3
    title: Michael Shortform Testing
    title: Mike Test
    title: Mixed Group Stage - Badminton - Olympic Test Feature
    title: Olympics Test Asset
    title: Ring of Fire - PPV Test
    title: SMWYG - Dynamic query all the things
next: https://api.test.streamco.com.au/rec/v1/related?feat=23436565677378&genres=Sport&offset=30&purchases=0&source=111111
total: 90
vendor: 1

```

# to get vendor 2 (Google) we need a valid source id and a valid token

```
    title: AUS v SA, Tri Nations, 5 Aug 2006
    title: 'Uruguay v USA: Men''s 9th Place SF 2 - World Rugby Sevens Series Cape Town 2024/25'
    title: New Zealand v France - WXV Matchday 3 2024
    title: New Zealand v England - WXV Matchday 2 2024
    title: NZ v AUS, Bledisloe Cup, 11 Oct 2020
    title: SA v AUS, Tri Nations, 22 Aug 1998
    title: Jaguares v Chiefs - Super Rugby QF 2019
    title: Sharks v Reds - Super Rugby R9 2000
    title: ARG v NZ, The Rugby Championship, 29 Sep 2018
    title: Manchester United v Twente - UEFA Europa League 2024/2025
    title: AUS v IRE, International, 9 Jun 2018
    title: Federer v Söderling - Roland Garros Men's Final 2009 - Classic Match
    title: NZ v SA, The Rugby Championship, 15 Sep 2012
    title: AUS v NZ, Bledisloe Cup, 8 Aug 2015
    title: Slovan Bratislava v Manchester City - UEFA Champions League 2024/2025
total: 30
vendor: 2
```
# prod and test, localhost give different results with empty source and empty token

Prod

```
bash-5.3$ ,curl "http://api.stan.com.au/rec/v1/related?genres=Sport&source=&jwToken=" | goyamp | grep -E -e '^    title\:' -e total: -e next: -e vendor: 
total: 0
vendor: 1
```

Test

```
bash-5.3$ ,curl "http://api.test.streamco.com.au/rec/v1/related?genres=Sport&source=&jwToken=" | goyamp | grep -E -e '^    title\:' -e total: -e next: -e vendor: 
    title: Martin Zapata v Daman Saudi
    title: Ring of Fire - PPV Test
    title: Uncaged PPV Test
    title: Arsenal vs Man U
total: 4
vendor: 1
```

Local


```
bash-5.3$ ,curl "http://localhost:5000/related?genres=Sport&source=&jwToken=" | goyamp | grep -E -e '^    title\:' -e total: -e next: -e vendor: 
    title: Martin Zapata v Daman Saudi
    title: Ring of Fire - PPV Test
    title: Uncaged PPV Test
    title: Arsenal vs Man U
total: 4
vendor: 1
```


# JW Token play
 
## prodToken
 
```
eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzQ5Mzc4NzMsImlhdCI6MTc2NDU2OTg3MywianRpIjoiMWE3YzVkYmQ3ZDE3NGYzNGIzMDJkYmUxMWI1ZTlhMGUiLCJyb2xlIjoidXNlciIsInVpZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjQsInByb2ZpbGVJZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwicHJvZmlsZU5hbWUiOiJQZXRlciIsInR6IjoiQXVzdHJhbGlhL01lbGJvdXJuZSIsImFwcCI6IlN0YW4tV2ViIiwidmVyIjoiMDdkOWRiOSIsIm51aWQiOiIyNzFlYzk3Zjc2ODM0YWYxYTEyNWFlM2U5MTIyZjJjNiIsImFwaWQiOiJiMjZkNWI3ZS1jNzU1LWUyMTQtNjhiYy0zY2UyZGJlMWJiMGQiLCJmZWF0IjoyMzE2MjIyNDY0MTg1NiwicHJpY2VOYW1lIjoidmlwIn0.sOFUImnvLVccrua7KAd2mFDl3AjNfOgVNSLPlP__cjk
```

```
 active: true
header:
  alg: HS256
  kid: pikachu
  typ: JWT
payload:
  apid: b26d5b7e-c755-e214-68bc-3ce2dbe1bb0d
  app: Stan-Web
  concurrency: 4
  exp: "2026-03-31T06:17:53Z"
  feat: 23162224641856
  iat: "2025-12-01T06:17:53Z"
  jti: 1a7c5dbd7d174f34b302dbe11b5e9a0e
  nuid: 271ec97f76834af1a125ae3e9122f2c6
  priceName: vip
  profileId: 581152ed28f64cf2a1e52e789725bf0a
  profileName: Peter
  role: user
  streams: hd
  tz: Australia/Melbourne
  uid: 581152ed28f64cf2a1e52e789725bf0a
  ver: 07d9db9
signature: false

```
 
## badtoken2
 
secret 
```
 a-valid-string-secret-that-is-at-least-512-bits-long-which-is-very-long
```
 
 
```
 eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.ANCf_8p1AE4ZQs7QuqGAyyfTEgYrKSjKWkhBk5cIn1_2QVr2jEjmM-1tu7EgnyOf_fAsvdFXva8Sv05iTGzETg
```
 
```
 active: true
header:
  alg: HS512
  typ: JWT
payload:
  admin: true
  iat: "2018-01-18T01:30:22Z"
  name: John Doe
  sub: "1234567890"
signature: false
 ```
 
## badtoken3

secret `i.am.a.duck`

jwt

```
eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhcGlkIjoiYjI2ZDViN2UtYzc1NS1lMjE0LTY4YmMtM2NlMmRiZTFiYjBkIiwiYXBwIjoiU3Rhbi1XZWIiLCJjb25jdXJyZW5jeSI6NCwiZXhwIjoiMjAyNi0wMy0zMVQwNjoxNzo1M1oiLCJmZWF0IjoyMzE2MjIyNDY0MTg1NiwiaWF0IjoiMjAyNS0xMi0wMVQwNjoxNzo1M1oiLCJqdGkiOiIxYTdjNWRiZDdkMTc0ZjM0YjMwMmRiZTExYjVlOWEwZSIsIm51aWQiOiIyNzFlYzk3Zjc2ODM0YWYxYTEyNWFlM2U5MTIyZjJjNiIsInByaWNlTmFtZSI6InZpcCIsInByb2ZpbGVJZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwicHJvZmlsZU5hbWUiOiJQZXRlciIsInJvbGUiOiJ1c2VyIiwic3RyZWFtcyI6ImhkIiwidHoiOiJBdXN0cmFsaWEvTWVsYm91cm5lIiwidWlkIjoiNTgxMTUyZWQyOGY2NGNmMmExZTUyZTc4OTcyNWJmMGEiLCJ2ZXIiOiIwN2Q5ZGI5In0.TRCMXcsq_gkmdpe03qsoHbjHyTzJwaspr3gIX1QsXjd1N16L8a-PfGIuhRPYz4VRXkQK0-e80nvyPjcEr_1g1Q
```

decoded

```
active: true
header:
  alg: HS512
  typ: JWT
payload:
  apid: b26d5b7e-c755-e214-68bc-3ce2dbe1bb0d
  app: Stan-Web
  concurrency: 4
  exp: "2026-03-31T06:17:53Z"
  feat: 23162224641856
  iat: "2025-12-01T06:17:53Z"
  jti: 1a7c5dbd7d174f34b302dbe11b5e9a0e
  nuid: 271ec97f76834af1a125ae3e9122f2c6
  priceName: vip
  profileId: 581152ed28f64cf2a1e52e789725bf0a
  profileName: Peter
  role: user
  streams: hd
  tz: Australia/Melbourne
  uid: 581152ed28f64cf2a1e52e789725bf0a
  ver: 07d9db9
signature: false
```

Test

```
bash-5.3$ ,curl 'https://api.test.streamco.com.au/rec/v1/related?genres=Sport%2CFootball&maxRating=PG&source=5619870&jwToken=$prodToken' | goyamp | grep -e '^    title:' -e total: -e vendor: -e id:
    guid: "5473046"
    id: "5473046"
    title: Arsenal vs Man U
    guid: "3230588"
    id: "3230588"
    title: Martin Zapata v Daman Saudi
    guid: "5672798"
    id: "5672798"
    title: Ring of Fire - PPV Test
    guid: "4941455"
    id: "4941455"
    title: Uncaged PPV Test
total: 4
vendor: 1

```


# How to get zero entries

## zero entries - good token, bad genres, bad source

```
bash-5.3$ ,curl 'https://api.test.streamco.com.au/rec/v1/related?genres=port&maxRating=PG&source=11111111&jwToken=$testToken' | goyamp | grep -e '^    title:' -e total: -e vendor: -e id:
total: 0
vendor: 1
```

```
bash-5.3$ ,curl 'http://localhost:5000/related?genres=port&maxRating=PG&source=11111111&jwToken=$testToken' | goyamp | grep -e '^    title:' -e total: -e vendor: -e id:
total: 0
vendor: 1
```


## zero entries - no token, no genres, good source

```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885513&jwToken=" | goyamp | grep -e '^    title:' -e total: -e vendor: 
total: 0
vendor: 1
```


## vendor 2 - 30 entries - good token, no genres, good source, 
```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885513&jwToken=$prodToken" | goyamp | grep -e '^    title:' -e total: -e vendor: 
    title: NZ v AUS, Bledisloe Cup, 8 Jul 2006
    title: AUS v NZ, Bledisloe Cup, 8 Aug 2015
    title: AUS v SA, Tri Nations, 5 Aug 2006
    title: Australia v Lions, Lions Tour Test 2 2013
    title: AUS v NZ, Bledisloe Cup, 13 Sep 2008
    title: Stormers v Hurricanes - Super Rugby R11 2000
    title: ARG v NZ, The Rugby Championship, 29 Sep 2012
    title: NZ v SA, Tri Nations, 10 Jul 1999
    title: AUS v NZ, Bledisloe Cup, 11 Sep 2010
    title: Hurricanes v Brumbies - Super Rugby R7 2001
    title: Sharks v Reds - Super Rugby R9 2000
    title: 'Uruguay v USA: Men''s 9th Place SF 2 - World Rugby Sevens Series Cape Town 2024/25'
    title: SA v NZ, Tri Nations, 19 Aug 2000
    title: NZ v SA, The Rugby Championship, 16 Sep 2017
    title: England v Australia - Autumn Nations Series Round 1 Ball in Play Replay 2024
total: 30
vendor: 2
```

# vendor 2 - 30 entries - good token, no genres, good source 

```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885453&jwToken=$prodToken" | goyamp | grep -e '^    title:' -e total: -e vendor: -e id:
    guid: "2885474"
    id: "2885474"
    title: AUS v NZ, Bledisloe Cup, 13 Sep 2008
    guid: "2885464"
    id: "2885464"
    title: AUS v NZ, Bledisloe Cup, 30 Jun 2007
    guid: "2919962"
    id: "2919962"
    title: NZ v SA, The Rugby Championship, 16 Sep 2017
    guid: "2926567"
    id: "2926567"
    title: NZ v SA, Tri Nations, 27 Aug 2005
    guid: "2922166"
    id: "2922166"
    title: SA v NZ, Tri Nations, 19 Jul 2003
    guid: "2926507"
    id: "2926507"
    title: NZ v SA, The Rugby Championship, 15 Sep 2012
    guid: "2888108"
    id: "2888108"
    title: NZ v AUS, Bledisloe Cup, 27 Aug 2016
    guid: "2885466"
    id: "2885466"
    title: NZ v AUS, Bledisloe Cup, 21 Jul 2007
    guid: "2919942"
    id: "2919942"
    title: SA v NZ, The Rugby Championship, 25 Jul 2015
    guid: "2885429"
    id: "2885429"
    title: AUS v NZ, Bledisloe Cup, 3 Aug 2002
    guid: "2885494"
    id: "2885494"
    title: AUS v NZ, Bledisloe Cup, 11 Sep 2010
    guid: "2926579"
    id: "2926579"
    title: SA v NZ, Tri Nations, 21 Aug 2010
    guid: "2926575"
    id: "2926575"
    title: SA v NZ, Tri Nations, 1 Aug 2009
    guid: "2926559"
    id: "2926559"
    title: SA v NZ, Tri Nations, 7 Aug 1999
    guid: "2926561"
    id: "2926561"
    title: SA v NZ, Tri Nations, 19 Aug 2000
total: 30
vendor: 2

```

## Error - good token, no genre, bad source

```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=28854532&jwToken=$prodToken" | goyamp #| grep -e '^    title:' -e total: -e vendor: -e id:
errors:
  - code: Streamco.Rec.BadRequest
    message: program 28854532 not found & no genres provided
```

## Empty entries - bad token, good source, no genres but with cache hiding the true results

```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885453&jwToken=$badToken3" | goyamp | grep -e '^    title:' -e total: -e vendor: -e id:
total: 0
vendor: 1
```


## Empty enties - good token, bad source, bad genre 

```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=28854532&genres=Spor&jwToken=$prodToken" | goyamp #| grep -e '^    title:' -e total: -e vendor: -e id:
entries: []
model: related
title: More Like This
total: 0
updated: 1764575854
vendor: 1
```

# 

## Empty entries - bad token, good source 

```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885453&jwToken=$badToken3" | goyamp | grep -e '^    title:' -e total: -e vendor: -e id:
total: 0
vendor: 1

bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885453&genres=Sport2CFootball&jwToken=$badToken3" | goyamp | grep -e '^    title:' -e total: -e vendor: 
total: 0
vendor: 1

bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885453&genres=&jwToken=$badToken3" | goyamp | grep -e '^    title:' -e total: -e vendor: 
total: 0
vendor: 1

bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885453&jwToken=$badToken3" | goyamp | grep -e '^    title:' -e total: -e vendor: 
total: 0
vendor: 1

```


## Good entries - bad token, good genres, good source

```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885453&genres=Sport%2CFootball&jwToken=$badToken3" | goyamp | grep -e '^    title:' -e total: -e vendor: 
    title: AUS v NZ, Bledisloe Cup, 13 Sep 2008
    title: AUS v NZ, Bledisloe Cup, 30 Jun 2007
    title: NZ v SA, The Rugby Championship, 16 Sep 2017
    title: NZ v SA, Tri Nations, 27 Aug 2005
    title: SA v NZ, Tri Nations, 19 Jul 2003
    title: NZ v SA, The Rugby Championship, 15 Sep 2012
    title: NZ v AUS, Bledisloe Cup, 27 Aug 2016
    title: NZ v AUS, Bledisloe Cup, 21 Jul 2007
    title: SA v NZ, The Rugby Championship, 25 Jul 2015
    title: AUS v NZ, Bledisloe Cup, 3 Aug 2002
    title: AUS v NZ, Bledisloe Cup, 11 Sep 2010
    title: SA v NZ, Tri Nations, 21 Aug 2010
    title: SA v NZ, Tri Nations, 1 Aug 2009
    title: SA v NZ, Tri Nations, 7 Aug 1999
    title: SA v NZ, Tri Nations, 19 Aug 2000
total: 30
vendor: 2
```

# Cycling through source IDs to beat the cache

## All Good
```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885429&genres=Sport%2CFootball&jwToken=$prodToken" | goyamp | grep  -e total: -e vendor: -e ' id:'
    id: "2885464"
    id: "2885474"
    id: "2885453"
    id: "2885447"
    id: "2885427"
    id: "2926567"
    id: "2926561"
    id: "2926579"
    id: "2926575"
    id: "5262777"
    id: "2890074"
    id: "2885532"
    id: "2885494"
    id: "2885513"
    id: "2919947"
total: 30
vendor: 2
```

## Bad token bad token gets zero items
```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885464&genres=Sport%2CFootball&jwToken=$badToken3" | goyamp | grep  -e total: -e vendor: -e ' id:'
total: 0
vendor: 1
bash-5.3$ # bad token gets zero items
```

## Good token, unknown source gets 30 vendor 1 results

```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=1111111&genres=Sport%2CFootball&jwToken=$prodToken" | goyamp | grep  -e total: -e vendor: -e ' id:'
    id: "5685334"
    id: "5658913"
    id: "5685326"
    id: "5685335"
    id: "5685325"
    id: "5669034"
    id: "5669032"
    id: "5685337"
    id: "5486823"
    id: "5487316"
    id: "5685331"
    id: "5486879"
    id: "5658914"
    id: "5536541"
    id: "5658912"
    id: "5685329"
    id: "5487288"
    id: "5685327"
    id: "5486801"
    id: "5685323"
    id: "5486956"
    id: "5486985"
    id: "4197438"
    id: "4090146"
    id: "4197029"
    id: "4197341"
      id: "4325499"
    id: "4325497"
    id: "4926858"
      id: "4755684"
    id: "4755682"
    id: "5565210"
total: 90
vendor: 1
bash-5.3$ # unknown source gets 30 vendor 1 results
```

# Good toke, bad Genre bad genres gets 30 vendor 2 results


```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885466&genres=SportFootball&jwToken=$prodToken" | goyamp | grep  -e total: -e vendor: -e ' id:'
    id: "2885474"
    id: "2885453"
    id: "2885464"
    id: "2926504"
    id: "2926561"
    id: "2885513"
    id: "2885494"
    id: "2888108"
    id: "2885429"
    id: "2885447"
    id: "2926457"
    id: "2926575"
    id: "2919962"
    id: "2895601"
    id: "2926567"
total: 30
vendor: 2
bash-5.3$ # bad genres gets 30 vendor 2 results
```

# Good token, no genres gets 30 vendor 2 results

```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885474&genres=&jwToken=$prodToken" | goyamp | grep  -e total: -e vendor: -e ' id:'
    id: "2885453"
    id: "2885464"
    id: "2885494"
    id: "2919962"
    id: "2888108"
    id: "2885513"
    id: "2885429"
    id: "2926561"
    id: "2888120"
    id: "2926457"
    id: "2895601"
    id: "2888355"
    id: "5101626"
    id: "2885427"
    id: "2895602"
total: 30
vendor: 2
bash-5.3$ # no generes gets 30 vendor 2 results
```

# Good or Bad token with the same other parameters gets results - these come from the cache - from the previous call ^

```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885494&genres=Sport&jwToken=$prodToken" | goyamp | grep  -e total: -e vendor: -e ' id:'
    id: "2926575"
    id: "2885474"
    id: "2885456"
    id: "2885464"
    id: "2926457"
    id: "2885513"
    id: "2926504"
    id: "2895601"
    id: "2926567"
    id: "2885447"
    id: "2885453"
    id: "2885377"
    id: "2919962"
    id: "2919942"
    id: "2895599"
total: 30
vendor: 2
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885494&genres=Sport&jwToken=$badToken3" | goyamp | grep  -e total: -e vendor: -e ' id:'
    id: "2926575"
    id: "2885474"
    id: "2885456"
    id: "2885464"
    id: "2926457"
    id: "2885513"
    id: "2926504"
    id: "2895601"
    id: "2926567"
    id: "2885447"
    id: "2885453"
    id: "2885377"
    id: "2919962"
    id: "2919942"
    id: "2895599"
total: 30
vendor: 2
```

# Bad token, good source, good genres

```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2888108&genres=Sport&jwToken=$badToken3" | goyamp | grep  -e total: -e vendor: -e ' id:'
total: 0
vendor: 1

```

# Notes about streamco-rec

## preamble sets cache to max-age to 300 before knowing if this is an empty response.

```Go
// preamble is a middleware that sets the response headers and handles backward compatibility
func preamble(hdlr func(w http.ResponseWriter, r *http.Request)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Cache-Control", "max-age=300")
```

## Handler ignores bad session tokens error return 

https://github.com/StreamCo/streamco-rec/blob/34eb2b7d9d378378de8bd21979a5e8b50286be16/cmd/api/handler.go#L662-L666

```Go
func (h recHandler) Related(w http.ResponseWriter, r *http.Request) {
	tzOffset, _ := strconv.Atoi(r.FormValue("tzOffset"))

	// decode session variables for use
	session, _ := h.session(r)
```

## Handler uses session vlaues (from token) which may not exist or is expired

https://github.com/StreamCo/streamco-rec/blob/34eb2b7d9d378378de8bd21979a5e8b50286be16/cmd/api/handler.go#L681-L694

```Go
	reqFeatures = cmp.Or(reqFeatures, session.Features)    // fallback to session values if not provided
	reqPurchases = cmp.Or(reqPurchases, session.Purchases) // fallback to session values if not provided
	feedSource := r.FormValue("feedSource")                // used to identify the source of feed, example if from marketing email or homepage
	if feedSource == "" {
		feedSource = "pdp" // default to program detail page (pdp) if not provided
	}

	offset, _ := strconv.Atoi(r.FormValue("offset"))
	offset -= offset % h.pageSize // Limit offset to multiples of the pageSize, for caching reasons
	if offset < 0 {
		offset = 0
	}
	sourceID, _ := strconv.Atoi(r.FormValue("source"))
	kidsOnly := isKids(r, session)
```

## Handler uses features in session data even when missing token 

TODO (Rabbit-Hole): see if handler will use data from an unsigned or expired toke in the session.

```
func (h recHandler) selectVendor(session auth.Session, vendorForm string) string {
	// Vendor override - for leanplum or internal testing
	if _, ok := vendorMap[vendorForm]; ok {
		return vendorForm
	}
	// TODO: come up with a better way for internal users,
	// depending on what stakeholders want
	if session.Features.Has(auth.FeatureInternal) {
		return "googleexperiment5"
	}

```

## Google rollout all in the past now

https://github.com/StreamCo/streamco-rec/blob/f2255f14143a3962fe642cb5261a672a2e78d24f/cmd/api/rollout.go#L12-L35

## noProgramID value in condition always zero

https://github.com/StreamCo/streamco-rec/blob/34eb2b7d9d378378de8bd21979a5e8b50286be16/cmd/api/handler.go#L1323-L1330

```
	noProgramID := prog.ID == 0 // this is for genre recommendations, so we handle them with Stan Recommendations. Also this will help with some of trailers

	// check if sport bundle to exclude from cold start
	// still use old stan model for new titles
	coldStartFallbackEntertainment := coldStartFallback && !hasSports

	// NOTE: need to check if hasExclusions is still required?
	return hasExclusions || coldStartFallbackEntertainment || noProgramID
```

# REPRO IN LOCAL !

* needed to use Sport item which is in the `shows` query and hence in the cache ; 
* and force vendor to be Google 
* and use env var MOCK_GCP=true

## fail
```
$ ,curl "http://localhost:5000/related?source=2829705&genres=Sport&vendor=googleexperiment5&jwToken=" 
{"title":"More Like This","entries":[],"total":0,"vendor":2,"model":"mlt-cvr-srv","updated":1764628629}
```

## good token, good source id

```
$ ,curl "http://localhost:5000/related?source=2829705&genres=Sport&vendor=googleexperiment5&jwToken=$(cat testToken.jwt)"  | goyamp | grep -e total: -e '^    title:' -e vendor: -e model:
    title: No Activity (U.S.)
    title: The Commons
    title: A bit of Weather
    title: Gemini Man (2016)
    title: Haruki Test
    title: Cyberpunk 2077
    title: Nick Offerman's "Yule log"
    title: Audio described Parks and Rec
    title: Audio described Parks and Rec
model: mlt-cvr-srv
total: 9
vendor: 2
```

shows query `/Users/birchb/go/pkg/mod/github.com/streamco/streamco-feedbuilder@v1.4.6/db/catalogue/queries.sql.go:349`

```SQL
    const shows = `-- name: Shows :many
    select
        id,
        title,
        type,
        kids,
        bundle,
        short_title,
        short_message,
        genres,
        year as release_year,
        classification_rating,
        classification_advices,
        first_air_date,
        last_air_date,
        start_date,
        expiry_date,
        live_start_date,
        live_end_date,
        images,
        ribbon,
        duration,
        quality,
        description,
        short_description,
        long_description
    from
        program
    where
        updated_nano >= $1
        and expiry_date > $2
        and type = ANY($3::program_type_enum[])
    `

```

# Root Cause? maybe. 

The google engine returns 13 rows however these are removed by a Feature check in  `buildFeedItem()`

Features come from the jwtoken or an URL parameter `feat`. When there is neither the user has no features, not even default ones.

`/Users/birchb/go/pkg/mod/github.com/streamco/streamco-feedbuilder@v1.4.6/builder/builder.go:207`


`/Users/birchb/go/pkg/mod/github.com/streamco/streamco-feedbuilder@v1.4.6/builder/builder.go:215`

```
func (f Feedbuilder) buildFeedItem(r FeedRequest, item cmsdb.FeedItem, filters ...ProgramFilter) (FeedItem, bool) {
    . 
    .
    .
	// check if user deserves to see program , Auth
	if !f.deserves(feedItem, r, item.RequiredFeatures, item.PrecludedFeatures) {
		return feedItem, false
	}
```


`/Users/birchb/go/pkg/mod/github.com/streamco/streamco-feedbuilder@v1.4.6/builder/builder.go:565`

```    
func (f Feedbuilder) deserves(dbItem FeedItem, r FeedRequest, cmsRequiredFeatures auth.Features, cmsPrecludedFeatures auth.Features) bool {
. . .
    if !r.Features.Has(requiredFeatures) {
		return false
	}

```

## You can fake features with the `feat` param and get results

```
$ ,curl "http://localhost:5000/related?source=2829705&genres=Sport&vendor=google&feat=9223372036854775807&jwToken=" | goyamp | grep -e '^    title:' -e model: -e total: -e vendor:
    title: A bit of Weather
    title: Cyberpunk 2077
model: mlt-cvr-srv
total: 2
vendor: 2
```

# Footnnote getting Test program ids

```
select
    id,
    title,
    type,
    kids,
    bundle,
    genres,
    duration
from
    program
where true
	and bundle in ('sport', 'olympics', 'optussport', 'ppv')
    and expiry_date > 1764633728
    and kids = false
	and type in ('movie', 'series', 'linear')
order by expiry_date desc
limit 30
```

```
id     |title                                  |type |kids |bundle|genres                |duration|
-------+---------------------------------------+-----+-----+------+----------------------+--------+
3230588|Martin Zapata v Daman Saudi            |movie|false|ppv   |{Sport}               |     862|
5686376|Test Auto Ads Publish                  |movie|false|sport |{Action,Animation}    |      22|
5503220|Arsenal vs Real Madrid Mini            |movie|false|sport |{Action,Animation}    |    1445|
5031183|Maximilian Marterer - Nino Serdarusic  |movie|false|sport |{Sport}               |       0|
5004888|Yoyo tabiul 4                          |movie|false|sport |{Action,Animation}    |    1200|
5004767|Yoyo Tabiul 3                          |movie|false|sport |{Action,Animation}    |       0|
5004766|Tabiul Yoyo 2                          |movie|false|sport |{Action,Animation}    |       0|
4345706|shared lv2 bis                         |movie|false|sport |{Sport,Animation}     |       0|
4228760|SMWYG - Audio Normalization            |movie|false|sport |{Sport,Animation}     |    1879|
4220600|Source Testing                         |movie|false|sport |{Sport,Animation}     |       0|
4220583|source+id shared 2                     |movie|false|sport |{Action,Animation}    |       0|
4220572|Testing Source_ID Shared               |movie|false|sport |{Action,Animation}    |       0|
4189118|louis live 29 aug                      |movie|false|sport |{Action,Music}        |       0|
4112911|Video Codec & AV1                      |movie|false|sport |{Sport,Animation}     |    2225|
4101122|Tabiul Live Testing 10 May 2023        |movie|false|sport |{Sport,Animation}     |       0|
4063496|louis sport                            |movie|false|sport |{Sport,Animation}     |      22|
4006866|Tabiul Transcode Testing               |movie|false|sport |{Action}              |      28|
4005724|Tabiul Live Testing 5 Jan Shared       |movie|false|sport |{Sport,MotorSport}    |       0|
4004620|Tabiul Prepromote testing 4 Jan 2023   |movie|false|sport |{Sport,Motorsport}    |       0|
4003741|Tabiul Live Testing 3 Jan Shared       |movie|false|sport |{Sport,MotorSport}    |       0|
4001032|Tabiul Live Testing 28 Dec 2022 Part 1 |movie|false|sport |{Sport,MotorSport}    |       0|
3999594|Tabiul Live Testing 23 Dec 2022, Part 3|movie|false|sport |{Sport,MotorSport}    |       0|
3990701|Tabiul Live BACKUP Testing 14 Dec 2022 |movie|false|sport |{Sport,MotorSport}    |       0|
3978287|louis live 0112 6                      |movie|false|sport |{Sport,Animation}     |       0|
3978266|louis live 0112 5                      |movie|false|sport |{Sport,Animation}     |       0|
3978264|louis live 0112 4                      |movie|false|sport |{Sport,Animation}     |       0|
3978260|louis live 0112 2                      |movie|false|sport |{Sport,Animation}     |       0|
3977540|louis live 3011                        |movie|false|sport |{Sport,Animation}     |       0|
3865712|lw-dashboard-test-1                    |movie|false|sport |{Sport,Animation}     |       0|
3375922|Movie for sport                        |movie|false|sport |{"World Movies",Sport}|    3600|
```

# Footnote prod IDs to use

```
bash-5.3$ ,curl "https://api.stan.com.au/rec/v1/related?source=2885453&genres=Sport%2CFootball&G=23&jwToken=$prodToken" | goyamp | grep  -e total: -e vendor: -e ' id:'
    id: "2885429"
    id: "2885464"
    id: "2885466"
    id: "2885474"
    id: "2885494"
    id: "2888108"
    id: "2919942"
    id: "2919962"
    id: "2922166"
    id: "2926507"
    id: "2926559"
    id: "2926561"
    id: "2926567"
    id: "2926575"
    id: "2926579"
total: 30
vendor: 2
```

# Expired tokens

```
$ ,curl "http://localhost:5000/related?source=2829705&genres=Sport&vendor=googleexperiment5&jwToken=$(cat testTokenExpired.jwt)"  | goyamp | grep -e total: -e '^    title:' -e vendor: -e model:
    title: No Activity (U.S.)
    title: The Commons
    title: A bit of Weather
    title: Gemini Man (2016)
    title: Haruki Test
    title: Cyberpunk 2077
    title: Nick Offerman's "Yule log"
    title: Audio described Parks and Rec
    title: Audio described Parks and Rec
model: mlt-cvr-srv
total: 9
vendor: 2
macmini:FES-4775-MLT-sometimes-empty birchb$ < jwt-cli decode
bash: jwt-cli: No such file or directory
macmini:FES-4775-MLT-sometimes-empty birchb$ <testTokenExpired.jwt jwt-cli decode
{"active":false,"header":{"alg":"HS256","typ":"JWT"},"payload":{"apid":"c674a8ff-b0bc-4724-ae60-366ff58a1e07","app":"Stan-Web","concurrency":1,"exp":"2025-12-01T00:00:01Z","feat":23436565677378,"iat":"2025-12-01T00:00:00Z","jti":"9d62d8683fe047789753079c8a2ab091","nuid":"fd0b1472795c4f5ca72c19db3147acf2","priceName":"basicv2","profileId":"2e3ff044d810478ea48bb296e50a3f6f","profileName":"Peter","role":"user","streams":"sd","tz":"Australia/Melbourne","uid":"2e3ff044d810478ea48bb296e50a3f6f","ver":"07d9db9"},"signature":false}
```

# opensearch data

# by user agent

```
$ csvcut -c 3 On_demand_report_2025-12-02T23_48_11.756Z_5ca38ac0-cfd9-11f0-8feb-eba28f56b33b.csv | frangipanni  -depth 3 -breaks ' ()"' -counts -sort counts -no-fold 
user_agent_raw: 1
Slackbot-LinkExpanding: 1
    1.0: 1
        +https://api.slack.com/robots: 1
Dalvik/2.1.0: 270
    Linux;: 270
        U;: 270
Mozilla/5.0: 9729
    iPhone;: 3
        CPU: 3
    Fuchsia: 10
        AppleWebKit/537.36: 10
    SmartHub;: 13
        SMART-TV;: 13
    SMART-TV;: 13
        Linux;: 13
    Linux;: 32
        Tizen: 8
        NetCast;: 24
    X11;: 229
        Ubuntu;: 12
        CrOS: 105
        Linux: 112
    Macintosh;: 3087
        Intel: 3087
    Windows: 6342
        NT: 6342
```

# by genres

```
$ csvcut -c 4 On_demand_report_2025-12-02T23_48_11.756Z_5ca38ac0-cfd9-11f0-8feb-eba28f56b33b.csv  | awk -F '[&?]' '/genres/{print $2}' | sed 's/%2C/,/' | frangipanni -breaks ' =,' -counts -no-fold
genres: 10000
    Sport: 10000
        Football: 7077
        Rugby: 2572
        Tennis: 73
        Combat: 23
        Motorsport: 25
        Extreme+Sport: 5
        Cycling: 7
``` 

# top 10 program ids

``
$ csvcut -c 4 On_demand_report_2025-12-02T23_48_11.756Z_5ca38ac0-cfd9-11f0-8feb-eba28f56b33b.csv  | awk -F '[&?]' '/genres/{print $4}' | sed 's/%2C/,/' | frangipanni -breaks ' =,' -counts -no-fold -sort counts | tail | sort -k 2 -r
    5545776: 429 Republic of Ireland v Portugal - European World Cup Qualifiers 2025
    159276: 361  Every Goal: European World Cup Qualifiers
    5545773: 348
    5629288: 327
    5629285: 300
    5545764: 258
    5629290: 247
    5629287: 237
    5545789: 210
    5629289: 188
```

# Looking at cloud watch diurectly

URL: `https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#logsV2:log-groups/log-group/prod$252Frec/log-events$3Fstart$3D-1800000`

filter 

`{ $.eventType = %mlt%  && $.resultCount <= 1}`


gets 67 records saved in `aws-logs/log-events-viewer-result-full.csv`

# From Ray - zero results with feat and jwt!


```
$ ,curl -v 'http://api.stan.com.au/rec/v1/related?feat=19037982458128&offset=0&purchases=0&source=5681682&jwToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzUwODY2NzksImlhdCI6MTc2NDcxODY3OSwianRpIjoiYzgzYTYxMmYwMGEzNGVjNjhlYjBmYmE0MjVjYjA2Y2EiLCJyb2xlIjoidXNlciIsInVpZCI6ImNhZWUwNzY0YzIzMzQzNjg5ZTEzMWQxYjJhZTkyN2RjIiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjMsInByb2ZpbGVJZCI6ImNhZWUwNzY0YzIzMzQzNjg5ZTEzMWQxYjJhZTkyN2RjIiwicHJvZmlsZU5hbWUiOiJzZXJlbmEiLCJ0eiI6IkF1c3RyYWxpYS9TeWRuZXkiLCJhcHAiOiJTdGFuLU1pY3Jvc29mdFRWIiwidmVyIjoiNy4wLjEiLCJudWlkIjoiNDQ5NmZhZDljZWQxNDljM2I0MDNjY2QxZWJjMGEzNTciLCJhcGlkIjoiMDNjMjhlODQtYzU3Yi0wMmZjLWJhNjItZjhiMGYxZjA2ZTBiIiwiZmVhdCI6MTkwMzc5ODI0NTgxMjgsInByaWNlTmFtZSI6InN0YW5kYXJkdjUifQ.lAIKbIw7nah3xUxElLiHldd_jjyuHvH681S7PEer_PM'
* Host api.stan.com.au:80 was resolved.
* IPv6: (none)
* IPv4: 23.42.188.58
*   Trying 23.42.188.58:80...
* Connected to api.stan.com.au (23.42.188.58) port 80
> GET /rec/v1/related?feat=19037982458128&offset=0&purchases=0&source=5681682&jwToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzUwODY2NzksImlhdCI6MTc2NDcxODY3OSwianRpIjoiYzgzYTYxMmYwMGEzNGVjNjhlYjBmYmE0MjVjYjA2Y2EiLCJyb2xlIjoidXNlciIsInVpZCI6ImNhZWUwNzY0YzIzMzQzNjg5ZTEzMWQxYjJhZTkyN2RjIiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjMsInByb2ZpbGVJZCI6ImNhZWUwNzY0YzIzMzQzNjg5ZTEzMWQxYjJhZTkyN2RjIiwicHJvZmlsZU5hbWUiOiJzZXJlbmEiLCJ0eiI6IkF1c3RyYWxpYS9TeWRuZXkiLCJhcHAiOiJTdGFuLU1pY3Jvc29mdFRWIiwidmVyIjoiNy4wLjEiLCJudWlkIjoiNDQ5NmZhZDljZWQxNDljM2I0MDNjY2QxZWJjMGEzNTciLCJhcGlkIjoiMDNjMjhlODQtYzU3Yi0wMmZjLWJhNjItZjhiMGYxZjA2ZTBiIiwiZmVhdCI6MTkwMzc5ODI0NTgxMjgsInByaWNlTmFtZSI6InN0YW5kYXJkdjUifQ.lAIKbIw7nah3xUxElLiHldd_jjyuHvH681S7PEer_PM HTTP/1.1
> Host: api.stan.com.au
> User-Agent: curl/8.7.1
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 200 OK
< Content-Type: application/json; charset=utf-8
< Cache-Control: max-age=227
< Date: Wed, 03 Dec 2025 04:37:25 GMT
< Content-Length: 239
< Connection: keep-alive
< Access-Control-Allow-Origin: *
< 
{"title":"More Like This","entries":[],"total":0,"correlationId":"ChM5NDA5MDQzNzM2NjkyMDMwNjUwGiVzdGFuLW1vcmUtbGlrZS10aGlzLWN2cl8xNjg5ODk0ODI3Njc4IgttbHQtY3ZyLXNydigAMAI6CKGhnTenoZ03","vendor":2,"model":"mlt-cvr-srv","updated":1764736572}
* Connection #0 to host api.stan.com.au left intact
```

The token

```
active: true
header:
  alg: HS256
  kid: pikachu
  typ: JWT
payload:
  apid: 03c28e84-c57b-02fc-ba62-f8b0f1f06e0b
  app: Stan-MicrosoftTV
  concurrency: 3
  exp: "2026-04-01T23:37:59Z"
  feat: 19037982458128
  iat: "2025-12-02T23:37:59Z"
  jti: c83a612f00a34ec68eb0fba425cb06ca
  nuid: 4496fad9ced149c3b403ccd1ebc0a357
  priceName: standardv5
  profileId: caee0764c23343689e131d1b2ae927dc
  profileName: serena
  role: user
  streams: hd
  tz: Australia/Sydney
  uid: caee0764c23343689e131d1b2ae927dc
  ver: 7.0.1
signature: true
```

the features from Jared
```
decode features 19037982458128

FeatureStandardPlan | FeatureOlderProfile | FeatureAskWhoIsWatching | FeatureHEVC | FeatureSportUpsell | FeatureDashWithTimeline | FeatureLive | FeatureStripeBilled | FeatureAllowInAppPurchases | FeatureStudioPartlyUnhackable | FeatureQualityUpsell | FeatureWidevineOrPlayReady | FeatureEntertainment
```

## Here's more in the cloudwatch logs - some are not even sport


```
$ ./cloud-watch-logs.g aws-logs/log-events-viewer-result-full.csv
'Dec  3 03:28:04 ip-10-1-221-167 rec[5056' 'mlt' 0 '/related?exclude=4223516%2C148291%2C158598&feat=19070865769728&offset=0&purchases=0&source=5455362&tz=Australia%2FAdelaide&clipsAutoplayDisabled=true&tripleNav=true&feedTypes=landscapes%2Cresume%2Clandscapes_xl%2Cpreviews%2Csquares%2Cbanner%2Cordinal%2Cweb_view_page&jwToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzUxMDA0MzAsImlhdCI6MTc2NDczMjQzMCwianRpIjoiMTc0NDBiYzZjNzljNDIwOGJhMDRkOTIyNTQ4M2ExZmYiLCJyb2xlIjoidXNlciIsInVpZCI6Ijc1MmM1OTQzZmUzYjQ5M2M4MGMxNGViMGVkNWI2OTk1Iiwic3RyZWFtcyI6InNkIiwiY29uY3VycmVuY3kiOjEsInByb2ZpbGVJZCI6Ijc1MmM1OTQzZmUzYjQ5M2M4MGMxNGViMGVkNWI2OTk1IiwicHJvZmlsZU5hbWUiOiJEYW5pZWwiLCJ0eiI6IkF1c3RyYWxpYS9BZGVsYWlkZSIsImFwcCI6IlN0YW4tQW5kcm9pZCIsInZlciI6IjQuNDcuMC41ODM3MSIsIm51aWQiOiI5NjljYzE0MmQ4Mzk0Yzg3YmI4NDdjYWNkYTcxOGI2ZCIsImFwaWQiOiJjMDJkZWU5Ny0xMmVjLTI4MjUtMTgzOS05NDFlMWU5OGMwZjQiLCJmZWF0IjoxOTA3MDg2NTc2OTcyOCwicHJpY2VOYW1lIjoiYmFzaWN2MiJ9.DF60pKnv7B9XUkuxi1M7f6UCeeGkvwkOjMssb-U-CMY'
'Dec  3 03:28:05 ip-10-1-142-17 rec[5249' 'mlt' 0 '/related?exclude=4223516%2C158598&feat=19070865769728&offset=0&purchases=0&source=5455362&tz=Australia%2FAdelaide&clipsAutoplayDisabled=true&tripleNav=true&feedTypes=landscapes%2Cresume%2Clandscapes_xl%2Cpreviews%2Csquares%2Cbanner%2Cordinal%2Cweb_view_page&jwToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzUxMDA0MzAsImlhdCI6MTc2NDczMjQzMCwianRpIjoiMTc0NDBiYzZjNzljNDIwOGJhMDRkOTIyNTQ4M2ExZmYiLCJyb2xlIjoidXNlciIsInVpZCI6Ijc1MmM1OTQzZmUzYjQ5M2M4MGMxNGViMGVkNWI2OTk1Iiwic3RyZWFtcyI6InNkIiwiY29uY3VycmVuY3kiOjEsInByb2ZpbGVJZCI6Ijc1MmM1OTQzZmUzYjQ5M2M4MGMxNGViMGVkNWI2OTk1IiwicHJvZmlsZU5hbWUiOiJEYW5pZWwiLCJ0eiI6IkF1c3RyYWxpYS9BZGVsYWlkZSIsImFwcCI6IlN0YW4tQW5kcm9pZCIsInZlciI6IjQuNDcuMC41ODM3MSIsIm51aWQiOiI5NjljYzE0MmQ4Mzk0Yzg3YmI4NDdjYWNkYTcxOGI2ZCIsImFwaWQiOiJjMDJkZWU5Ny0xMmVjLTI4MjUtMTgzOS05NDFlMWU5OGMwZjQiLCJmZWF0IjoxOTA3MDg2NTc2OTcyOCwicHJpY2VOYW1lIjoiYmFzaWN2MiJ9.DF60pKnv7B9XUkuxi1M7f6UCeeGkvwkOjMssb-U-CMY'
'Dec  3 03:32:58 ip-10-1-221-167 rec[5056' 'mlt-sport' 0 '/related?genres=Sport%2CFootball&maxRating=PG&source=158852&jwToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzUxMDA3MjEsImlhdCI6MTc2NDczMjcyMSwianRpIjoiYmNkZWU4Y2FhODcxNDZiNThjZGM3ODFlM2I0YTEwOTMiLCJyb2xlIjoidXNlciIsInVpZCI6IjE0MWJiMzhkZmViZTQ4NDU4Nzc4MzU5NWZjOGEyNzY0Iiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjMsInByb2ZpbGVJZCI6IjVmYzY0MTA2NTU2MDRhZDg5YjViZWY3NzM2NjNlMTM2IiwicHJvZmlsZU5hbWUiOiJSdW1iaWUiLCJhcHAiOiJTdGFuLWlPUyIsInZlciI6IjQuNDEuMC41NDYiLCJudWlkIjoiMTUzNTdhZDQ5MjZkNGQzYTllMTJlODZkMmM1MTExOGQiLCJhcGlkIjoiMzYyOGY2YzYtMDc0ZS1kZTdlLTExNTItZjM3MWQzNzBmNmUwIiwiZmVhdCI6MjAzMDcxNDUwMzI5NzYsInByaWNlTmFtZSI6InN0YW5kYXJkdjUifQ.eICzec23XV0MoeCWlqTlGDcWPCFc_FKi-bFuSHfq2cM'
'Dec  3 03:36:39 ip-10-1-206-15 rec[5216' 'mlt-sport' 0 '/related?genres=Sport%2CFootball&maxRating=PG&source=158852&jwToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzUwOTk0MjksImlhdCI6MTc2NDczMTQyOSwianRpIjoiZGQ1NTAzNTRlYzEyNDMzNTk1NmNiZmMyMGM4NmFkYWEiLCJyb2xlIjoidXNlciIsInVpZCI6IjQ3ZjAzYTU2MjhlMTQ5NGNhNDJlMmFmOTllNjBjZDAxIiwic3RyZWFtcyI6InNkIiwiY29uY3VycmVuY3kiOjEsInByb2ZpbGVJZCI6IjQ3ZjAzYTU2MjhlMTQ5NGNhNDJlMmFmOTllNjBjZDAxIiwicHJvZmlsZU5hbWUiOiJTaGFiYW5pIiwidHoiOiJBdXN0cmFsaWEvQnJpc2JhbmUiLCJhcHAiOiJTdGFuLUFuZHJvaWRUViIsInZlciI6IjUuMTUuMCIsIm51aWQiOiIwY2E2YjM0Y2FkNjk0MWJiOTY2YjQ4NDlmMTEzZThmYSIsImFwaWQiOiIzMjc2YzYyZi1jZDM0LTAzMWYtNjJjMC01YTA5YzU2ZTFjMWIiLCJmZWF0Ijo1NDQwOTg5MDI2ODQyMCwicHJpY2VOYW1lIjoiYmFzaWN2MiJ9.xsE7yqMYI38ztVQ0WX7ReT16s2b6F8eEC6voH7Ogec0&tz=Australia%2FBrisbane'
'Dec  3 03:40:54 ip-10-1-216-46 rec[5023' 'mlt' 0 '/related?exclude=2894797,2306687,2306686,1646,3875158,3203795,108682&feat=20032267126016&offset=0&purchases=0&source=5455360&jwToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzUxMDEyNDQsImlhdCI6MTc2NDczMzI0NCwianRpIjoiMTU5NTAxNjAzYjBiNDc2NmFlOTMwZTM1ZmYxNDdkYzQiLCJyb2xlIjoidXNlciIsInVpZCI6Ijc4YzhmZDRhNjljZDRkMmViYzJiNjRmYzUzMTFjODY1Iiwic3RyZWFtcyI6InNkIiwiY29uY3VycmVuY3kiOjEsInByb2ZpbGVJZCI6Ijc4YzhmZDRhNjljZDRkMmViYzJiNjRmYzUzMTFjODY1IiwicHJvZmlsZU5hbWUiOiJSYWNoYWVsIiwiYXBwIjoiU3Rhbi1pT1MiLCJ2ZXIiOiI0LjQxLjAuNTQ2IiwibnVpZCI6Ijg1NWE3OWFjNWU4MjRhOGU4MGYxYzNhOTI4MjM4ODBhIiwiYXBpZCI6IjNjNzY5YTk0LWQ1YWUtMDgzYy1hN2E5LWQxNWVkYjc3YTYyZSIsImZlYXQiOjIwMDMyMjY3MTI2MDE2LCJwcmljZU5hbWUiOiJiYXNpY3YyIn0.ch8VpDwAjED4ASD0UnLMfF7KisvBtZfVdY9x0l_XakI&tz=Australia/Melbourne'
'Dec  3 03:41:49 ip-10-1-206-15 rec[5216' 'mlt' 0 '/related?feat=54137562465556&offset=0&purchases=0&source=4994815&jwToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzUxMDEyNTksImlhdCI6MTc2NDczMzI1OSwianRpIjoiODU3MmMwYjM4MTEyNDI5ZWFlNzcyZjA0NGUzNjQ0MTAiLCJyb2xlIjoidXNlciIsInVpZCI6IjBmZjA1ZDVjNjBiODQzODRhMmViN2FhNTI2MDA5Y2E1Iiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjMsInByb2ZpbGVJZCI6IjBmZjA1ZDVjNjBiODQzODRhMmViN2FhNTI2MDA5Y2E1IiwicHJvZmlsZU5hbWUiOiJTdGV2ZW4iLCJ0eiI6IkF1c3RyYWxpYS9BZGVsYWlkZSIsImFwcCI6IlN0YW4tU2Ftc3VuZ1RWIiwidmVyIjoiOC42LjAiLCJudWlkIjoiZjI0ZTc2MGU4YWE0NGU1ZDg5MzVmY2U4NmQ1MmQ4MmIiLCJhcGlkIjoiMDcyNzZjNDktYzczMC05ODZiLTc3YjgtYmIwNzhiYzc1NDhiIiwiZmVhdCI6NTQxMzc1NjI0NjU1NTYsInByaWNlTmFtZSI6InN0YW5kYXJkdjUifQ.Wa_dtGpF00ip0ENXsldTQH2P9EZn4VoXvPJ48_UPsu4'
'Dec  3 03:47:05 ip-10-1-148-39 rec[5224' 'mlt' 0 '/related?exclude=5455337,5455328,5455354&feat=20307145033472&offset=0&purchases=0&source=5455338&jwToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzUxMDE2MTYsImlhdCI6MTc2NDczMzYxNiwianRpIjoiNWZiMDgwZjYzZWJhNGYzMjlhMGZjMTMwNzhjMTliMDEiLCJyb2xlIjoidXNlciIsInVpZCI6Ijg5NDJlN2Q4ZGFkYTRmYzc4YWYzMWQ0YWY3Yjk0NTUyIiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjQsInByb2ZpbGVJZCI6Ijg5NDJlN2Q4ZGFkYTRmYzc4YWYzMWQ0YWY3Yjk0NTUyIiwicHJvZmlsZU5hbWUiOiJCZW4iLCJhcHAiOiJTdGFuLWlPUyIsInZlciI6IjQuNDAuMS41NDIiLCJudWlkIjoiMDBjOGIxZWY5YjI3NDgzNDgyYWQ1ODkzZjRlMTNjMWYiLCJhcGlkIjoiZTYxY2UzMTgtZWNkMC0zMjI5LTE5OTctMDdkZWUyMGZjMTg5IiwiZmVhdCI6MjAzMDcxNDUwMzM0NzIsInByaWNlTmFtZSI6InByZW1pdW12NiJ9.JIW9bLRB-3n9htmkwYjhBfJ5DDX3PDmd1bYelsrFr-k&tz=Australia/Darwin'
~ 67
```

Their Tokens


`for X in $(./cloud-watch-logs.g aws-logs/log-events-viewer-result-full.csv | tr '&' $'\n' | tr -d "'" | awk -F '=' '/jwToken/{print $2}' ); do echo $X | jwt-cli decode | goyamp ; done`

```
active: true
header:
  alg: HS256
  kid: pikachu
  typ: JWT
payload:
  apid: c02dee97-12ec-2825-1839-941e1e98c0f4
  app: Stan-Android
  concurrency: 1
  exp: "2026-04-02T03:27:10Z"
  feat: 19070865769728
  iat: "2025-12-03T03:27:10Z"
  jti: 17440bc6c79c4208ba04d9225483a1ff
  nuid: 969cc142d8394c87bb847cacda718b6d
  priceName: basicv2
  profileId: 752c5943fe3b493c80c14eb0ed5b6995
  profileName: Daniel
  role: user
  streams: sd
  tz: Australia/Adelaide
  uid: 752c5943fe3b493c80c14eb0ed5b6995
  ver: 4.47.0.58371
signature: true
active: true
header:
  alg: HS256
  kid: pikachu
  typ: JWT
payload:
  apid: c02dee97-12ec-2825-1839-941e1e98c0f4
  app: Stan-Android
  concurrency: 1
  exp: "2026-04-02T03:27:10Z"
  feat: 19070865769728
  iat: "2025-12-03T03:27:10Z"
  jti: 17440bc6c79c4208ba04d9225483a1ff
  nuid: 969cc142d8394c87bb847cacda718b6d
  priceName: basicv2
  profileId: 752c5943fe3b493c80c14eb0ed5b6995
  profileName: Daniel
  role: user
  streams: sd
  tz: Australia/Adelaide
  uid: 752c5943fe3b493c80c14eb0ed5b6995
  ver: 4.47.0.58371
signature: true
active: true
header:
  alg: HS256
  kid: pikachu
  typ: JWT
payload:
  apid: 3628f6c6-074e-de7e-1152-f371d370f6e0
  app: Stan-iOS
  concurrency: 3
  exp: "2026-04-02T03:32:01Z"
  feat: 20307145032976
  iat: "2025-12-03T03:32:01Z"
  jti: bcdee8caa87146b58cdc781e3b4a1093
  nuid: 15357ad4926d4d3a9e12e86d2c51118d
  priceName: standardv5
  profileId: 5fc6410655604ad89b5bef773663e136
  profileName: Rumbie
  role: user
  streams: hd
  uid: 141bb38dfebe484587783595fc8a2764
  ver: 4.41.0.546
signature: true
active: true
header:
  alg: HS256
  kid: pikachu
  typ: JWT
payload:
  apid: 3276c62f-cd34-031f-62c0-5a09c56e1c1b
  app: Stan-AndroidTV
  concurrency: 1
  exp: "2026-04-02T03:10:29Z"
  feat: 54409890268420
  iat: "2025-12-03T03:10:29Z"
  jti: dd550354ec124335956cbfc20c86adaa
  nuid: 0ca6b34cad6941bb966b4849f113e8fa
  priceName: basicv2
  profileId: 47f03a5628e1494ca42e2af99e60cd01
  profileName: Shabani
  role: user
  streams: sd
  tz: Australia/Brisbane
  uid: 47f03a5628e1494ca42e2af99e60cd01
  ver: 5.15.0
signature: true
active: true
header:
  alg: HS256
  kid: pikachu
  typ: JWT
payload:
  apid: 3c769a94-d5ae-083c-a7a9-d15edb77a62e
  app: Stan-iOS
  concurrency: 1
  exp: "2026-04-02T03:40:44Z"
  feat: 20032267126016
  iat: "2025-12-03T03:40:44Z"
  jti: 159501603b0b4766ae930e35ff147dc4
  nuid: 855a79ac5e824a8e80f1c3a92823880a
  priceName: basicv2
  profileId: 78c8fd4a69cd4d2ebc2b64fc5311c865
  profileName: Rachael
  role: user
  streams: sd
  uid: 78c8fd4a69cd4d2ebc2b64fc5311c865
  ver: 4.41.0.546
signature: true
active: true
header:
  alg: HS256
  kid: pikachu
  typ: JWT
payload:
  apid: 07276c49-c730-986b-77b8-bb078bc7548b
  app: Stan-SamsungTV
  concurrency: 3
  exp: "2026-04-02T03:40:59Z"
  feat: 54137562465556
  iat: "2025-12-03T03:40:59Z"
  jti: 8572c0b38112429eae772f044e364410
  nuid: f24e760e8aa44e5d8935fce86d52d82b
  priceName: standardv5
  profileId: 0ff05d5c60b84384a2eb7aa526009ca5
  profileName: Steven
  role: user
  streams: hd
  tz: Australia/Adelaide
  uid: 0ff05d5c60b84384a2eb7aa526009ca5
  ver: 8.6.0
signature: true
active: true
header:
  alg: HS256
  kid: pikachu
  typ: JWT
payload:
  apid: e61ce318-ecd0-3229-1997-07dee20fc189
  app: Stan-iOS
  concurrency: 4
  exp: "2026-04-02T03:46:56Z"
  feat: 20307145033472
  iat: "2025-12-03T03:46:56Z"
  jti: 5fb080f63eba4f329a0fc13078c19b01
  nuid: 00c8b1ef9b27483482ad5893f4e13c1f
  priceName: premiumv6
  profileId: 8942e7d8dada4fc78af31d4af7b94552
  profileName: Ben
  role: user
  streams: hd
  uid: 8942e7d8dada4fc78af31d4af7b94552
  ver: 4.40.1.542
signature: true
```

# Stats from 12hours of CloudWatch data

## Sample size 264

```
$ wc -l aws-log-reports/log-events-viewer-result-zero-12h.tsv
     265 aws-log-reports/log-events-viewer-result-zero-12h.tsv
```

## eventType (bundles) / Genres


```
$'\t' -c 'event.eventType,param.genres'  aws-log-reports/log-events-viewer-result-zero-12h.tsv | awk 'NR!=1{print}' | frangipanni -breaks $'\t,"' -counts -sort counts -no-fold -depth 2 
mlt: 128
    Dark+Comedy: 1
    War: 1
    Adventure: 1
    Fantasy: 1
    Game-Show: 1
    Reality-TV: 1
    Crime: 1
    Action: 2
    Thriller: 2
    Reality: 3
    Comedy: 3
    Documentary: 3
    Drama: 6
    Sport: 41
    nil: 61
mlt-sport: 136
    nil: 14
    Sport: 122
```

## presence of jwTokens

Plenty with JWT (154) of those without JWT (110) most have no `feat` (95),  

```
$ csvcut -d $'\t' -c 'param.jwToken,param.feat'  aws-log-reports/log-events-viewer-result-zero-12h.tsv | awk 'NR!=1{print}' | frangipanni -breaks $'\t,"' -counts -sort counts -no-fold -depth 2  | awk '!/^    [0-9]/'
nil: 110
    nil: 95
redacted: 154
    nil: 94
```

## Application Names

Event log and jwt values are identical.

```
$ csvcut -d $'\t' -c 'event.sessionAppName,jwt.app'  aws-log-reports/log-events-viewer-result-zero-12h.tsv | awk 'NR!=1{print}' | frangipanni -breaks $'\t' -counts -sort counts -no-fold -depth 3
Stan-Hisense,Stan-Hisense: 1
Stan-MicrosoftTV,Stan-MicrosoftTV: 1
Stan-Samsung,Stan-Samsung: 1
Stan-atv,Stan-atv: 1
Stan-TelstraTV,Stan-TelstraTV: 2
Stan-FoxtelTV,Stan-FoxtelTV: 2
Stan-HisenseTV,Stan-HisenseTV: 6
Stan-Web,Stan-Web: 6
Stan-LGTV,Stan-LGTV: 10
Stan-AndroidTV,Stan-AndroidTV: 13
Stan-SamsungTV,Stan-SamsungTV: 17
Stan-Android,Stan-Android: 21
Stan-iOS,Stan-iOS: 73
,nil: 110
```

## Applications (where recorded) are mostly Mobiles or TVs only 6 Web

```
$ 
Stan-Hisense: 1
Stan-MicrosoftTV: 1
Stan-Samsung: 1
Stan-atv: 1
Stan-TelstraTV: 2
Stan-FoxtelTV: 2
Stan-HisenseTV: 6
Stan-Web: 6
Stan-LGTV: 10
Stan-AndroidTV: 13
Stan-SamsungTV: 17
Stan-Android: 21
Stan-iOS: 73
nil: 110
```
### Stan-iOS versions
```
$ csvcut -d $'\t' -c 'jwt.app,jwt.ver'  aws-log-reports/log-events-viewer-result-zero-12h.tsv | awk 'NR!=1 && /Stan-iOS/ {print}' | frangipanni -breaks $'\t,"' -counts -sort counts -no-fold -depth 3
Stan-iOS: 73
    4.42.0.562: 1
    4.40.1.542: 1
    3.4.184c208f3: 1
    4.41.0.546: 70
```


### When sessionAppName is NULL (110 of) 

User agents for these is as follows

```
$ duckdb -line -c "SELECT \"event.user_agent_raw\" from 'aws-log-reports/log-events-viewer-result-zero-12h.tsv' tsv where \"event.sessionAppName\" is NULL  ;" | frangipanni -breaks '/?&=' -depth 3 -counts -no-fold 
event.user_agent_raw : 110
     Dalvik: 41
        2.1.0 (Linux; U; Android 9; UnionTV Build: 2
        2.1.0 (Linux; U; Android 11; Smart TV Build: 3
        2.1.0 (Linux; U; Android 14; Chromecast HD Build: 5
        2.1.0 (Linux; U; Android 11; AI PONT Build: 2
        2.1.0 (Linux; U; Android 14; Chromecast Build: 9
        2.1.0 (Linux; U; Android 11; Smart TV Pro Build: 4
        2.1.0 (Linux; U; Android 12; Smart TV Pro Build: 4
        2.1.0 (Linux; U; Android 11; AFTKRT Build: 1
        2.1.0 (Linux; U; Android 11; EKO 2K Android TV Build: 1
        2.1.0 (Linux; U; Android 10; BRAVIA 4K UR3 Build: 2
        2.1.0 (Linux; U; Android 11; SHIELD Android TV Build: 1
        2.1.0 (Linux; U; Android 14; Google TV Streamer Build: 1
        2.1.0 (Linux; U; Android 11; BeyondTV2 Build: 2
        2.1.0 (Linux; U; Android 9; BRAVIA 4K GB Build: 2
        2.1.0 (Linux; U; Android 11; 4K EKO Google TV Build: 1
        2.1.0 (Linux; U; Android 12; BRAVIA 4K VH21 Build: 1
     Mozilla: 67
        5.0 (Windows NT 10.0; Win64; x64) AppleWebKit: 12
        5.0 (X11; Linux x86_64) AppleWebKit: 1
        5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit: 18
        5.0 (SmartHub; SMART-TV; U; Linux: 4
        5.0 (ARRIS_Foxtel_STB_QH5515ZF; Linux armv7l) AppleWebKit: 1
        5.0 (X11; Ubuntu; Linux x86_64; rv:74.0) Gecko: 31
     Stan: 2
        Android: 2

```


## App versions from JWT

Mostly TV

```
$ csvcut -d $'\t' -c 'event.sessionAppName,jwt.ver'  aws-log-reports/log-events-viewer-result-zero-12h.tsv | awk 'NR!=1{print}' | frangipanni -breaks $'\t,"' -counts -sort counts -no-fold -depth 4
Stan-Hisense: 1
    1.92: 1
Stan-MicrosoftTV: 1
    7.0.1: 1
Stan-Samsung: 1
    1.92: 1
Stan-atv: 1
    3.64.916.c96c681: 1
Stan-TelstraTV: 2
    3.44.305: 2
Stan-FoxtelTV: 2
    5.1.8: 1
    7.0.1: 1
Stan-HisenseTV: 6
    5.1.6: 1
    8.6.0: 5
Stan-Web: 6
    07d9db9: 6
Stan-LGTV: 10
    8.6.1: 2
    8.6.0: 8
Stan-AndroidTV: 13
    5.16.0: 1
    5.13.3: 1
    5.17.0: 2
    5.15.0: 9
Stan-SamsungTV: 17
    8.6.2: 1
    8.6.0: 16
Stan-Android: 21
    4.46.1.57870: 1
    4.47.0.58371: 20
Stan-iOS: 73
    4.42.0.562: 1
    4.40.1.542: 1
    3.4.184c208f3: 1
    4.41.0.546: 70
nil: 110
```

## Browser types

Side quest would be to use this API to get more clarity [The WhatIsMyBrowser.com Browser Detection API](https://developers.whatismybrowser.com/api/features/)

```
$ csvcut -d $'\t' -c 'event.user_agent_raw'  aws-log-reports/log-events-viewer-result-zero-12h.tsv | awk 'NR!=1{print}' | frangipanni -breaks $'\t," ;:()' -counts -sort counts -no-fold -depth 2
Opera/9.80: 1
    Linux: 1
Stan/Android/4.46.1: 1
    Dalvik/2.1.0: 1
Stan/4.42.0: 1
    au.com.stan: 1
Stan/542: 1
    CFNetwork/3826.600.41: 1
Stan%20tvOS/560: 1
    CFNetwork/1496.0.7: 1
Stan/441: 1
    CFNetwork/758.5.3: 1
Roku/G000X: 2
    Firmware/15.0.4.5537: 2
Stan/Android/4.47.0: 22
    Dalvik/2.1.0: 22
Stan/546: 34
    CFNetwork/1498.700.2: 2
    CFNetwork/3826.500.131: 2
    CFNetwork/3860.200.71: 4
    CFNetwork/3826.600.41: 26
Stan/4.41.0: 36
    au.com.stan: 36
Dalvik/2.1.0: 54
    Linux: 54
Mozilla/5.0: 110
    Linux: 1
    iPhone: 1
    ARRIS_Foxtel_STB_QH5515ZF: 2
    SmartHub: 5
    Web0S: 10
    Windows: 16
    SMART-TV: 17
    Macintosh: 20
    X11: 38
```


## features in URL params and JWT are always identical

```
$ csvcut -d $'\t' -c 'param.feat,jwt.feat'  aws-log-reports/log-events-viewer-result-zero-12h.tsv | awk 'NR!=1{print}' | gawk -F, '$1 == $2{print "same", $0}' | sort | uniq -c
   1 same 18764178261264,18764178261264
   1 same 18796390515968,18796390515968
   1 same 18796390516480,18796390516480
   2 same 19036908685056,19036908685056
   1 same 19039056168208,19039056168208
   1 same 19071268422912,19071268422912
   5 same 19071268422928,19071268422928
   2 same 19071268455680,19071268455680
   1 same 19071268455696,19071268455696
   1 same 20031730255616,20031730255616
   2 same 20032267126016,20032267126016
   3 same 20032267126032,20032267126032
   1 same 20032267126528,20032267126528
   1 same 20306608162064,20306608162064
   1 same 20306742379776,20306742379776
   1 same 20306742379792,20306742379792
   4 same 20307145032960,20307145032960
  14 same 20307145032976,20307145032976
   6 same 20307145033472,20307145033472
   1 same 53878757132032,53878757132032
   1 same 54137025594628,54137025594628
   2 same 54137562465556,54137562465556
   1 same 54153635038976,54153635038976
   1 same 54412439323908,54412439323908
   1 same 54412440372484,54412440372484
   2 same 54412440372500,54412440372500
   2 same 54412440409860,54412440409860
  95 same nil,nil
```


## duckdb the TSV

```
$ duckdb -c "select \"param.jwToken\", count(*) number from 'aws-log-reports/log-events-viewer-result-zero-12h.tsv' group by 1;" 
┌───────────────┬────────┐
│ param.jwToken │ number │
│    varchar    │ int64  │
├───────────────┼────────┤
│ nil           │    110 │
│ redacted      │    154 │
└───────────────┴────────┘

```

# GCP Analytics Data

## From Andrew Milgate

[Slack](https://streamco.slack.com/archives/D0A1GN3KK5Z/p1764889607367069)

```
HI Bill, hope you're well.
Here are the staging tables we've set up in GCP to use for out reporting. Some of the fields have been renamed from what is in OpenSearch.
`swordbill-beta.staging.stg_opensearch__analytics_event`
`swordbill-beta.staging.stg_opensearch__carousel_event`
`swordbill-beta.staging.stg_opensearch__carousel_sidecar_event`
`swordbill-beta.staging.stg_opensearch__player_event`
`swordbill-beta.staging.stg_opensearch__registration_events`
`swordbill-beta.staging.stg_opensearch__search_events`
`swordbill-beta.staging.stg_opensearch__search_svc_events`
`swordbill-beta.staging.stg_opensearch__upsell_events`
`swordbill-beta.staging.stg_opensearch__video_event`
`swordbill-beta.staging.stg_opensearch__video_view_event`
(edited)





10:10
Here's the parquet folder locations for these tables as well. These don't have any of the modelling or column name changes, the raw files here might be easier to work with
"gs://stan-prod-opensearch-pipeline/stan_analytics_event"
"gs://stan-prod-opensearch-pipeline/stan_analytics_upsell"
"gs://stan-prod-opensearch-pipeline/stan_carousel_event"
"gs://stan-prod-opensearch-pipeline/stan_player_event"
"gs://stan-prod-opensearch-pipeline/stan_registration_event"
"gs://stan-prod-opensearch-pipeline/stan_search_event"
"gs://stan-prod-opensearch-pipeline/stan_video_event"
"gs://stan-prod-opensearch-pipeline/stan_search_svc_event"
"gs://stan-prod-opensearch-pipeline/stan_video_view_event"
"gs://stan-prod-opensearch-pipeline/stan_carousel_sidecar_event"
10:12
If you have access to the Analytics Worker repository you can see exactly what is being included for each paruqet
https://github.com/StreamCo/analyticsworker
eg
Screenshot 2025-12-05 at 10.12.08.png
 
Screenshot 2025-12-05 at 10.12.08.png


10:12
We don't get all OpenSearch fields sent to us as they're not all useful for reporting.
```

## Download a day's work from GCP using gcloud cli

```
$ brew update
$ brew install gcloud-cli
$ gcloud version
$ gcloud auth login

$ mkdir data
$ gcloud storage cp -r gs://stan-prod-opensearch-pipeline/stan_analytics_event/dt=2025-04-03 data
```

## Does it have mlt events - No
```
$ duckdb -c "SELECT distinct eventType, count(*) FROM 'data/dt=2025-04-03/*.parquet' group by eventType;" 
┌──────────────────┬──────────────┐
│    eventType     │ count_star() │
│     varchar      │    int64     │
├──────────────────┼──────────────┤
│ page:load        │      7586728 │
│ page:interaction │      3535272 │
└──────────────────┴──────────────┘
```

## More from Andrew

```
Andrew Milgate
:spiral_calendar_pad:  10:59
I've just been loading them into Big Query as a raw table

11:02
The MLT impressions are in a different table
stan-prod-pubsub.rec_feedgen.events
```

```
-- 
-- Stats of event rec_model this year
-- 
with dates as (SELECT DATE_TRUNC(CURRENT_DATE(), YEAR) AS first_day_this_year)

SELECT rec_model, count(*) as number_of_feedgen_events
FROM `swordbill-beta.staging.stg_rec__feedgen_events` , dates
where DATE(event_at) >= dates.first_day_this_year
group by 1 order by 2 desc

rec_model	number_of_feedgen_events
mlt-cvr-srv	318038725
rfy-wto-srv	221602765
topshows	145978986
stan_ranker_3	138001911
mlt-cvr-srv-demotehistory	115176415
related	66846498
stan-most-popular-cvr-60-d_1725581913934	11200062
stan-most-popular-cvr-30-d_1711069410279	11111862
stan-most-popular-cvr-45-d_1725581862616	11039537
byw	40669
rfy-wto-srv-demotehistory	233
```

###

```
-- SELECT rec_model, count(*)
-- FROM `swordbill-beta.staging.stg_rec__feedgen_events`
-- where rec_model like 'mlt%'
-- group by rec_model
-- --WHERE TIMESTAMP_TRUNC(event_timestamp, DAY) = TIMESTAMP("2025-12-05") 
-- --LIMIT 1000
-- rec_model	f0_
-- mlt-cvr-srv-demotehistory	113366939
-- mlt-cvr-srv	311812568


-- SELECT TIMESTAMP_TRUNC(event_at, DAY) as date, feed_source, rec_model, source_program_id, endpoint_link, app_name, array_length(program_ids) as number_of_programs
-- -- SAFE_CONVERT_BYTES_TO_STRING(FROM_BASE64(correlation_id)) as correlation,
-- FROM `swordbill-beta.staging.stg_rec__feedgen_events`
-- where true
-- and rec_model like 'mlt%'
-- and TIMESTAMP_TRUNC(event_at, DAY) = TIMESTAMP("2025-12-05") 
-- and array_length(program_ids) = 0
-- order by event_at 
-- limit 1000

-- date	feed_source	rec_model	source_program_id	endpoint_link	app_name	number_of_programs
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	103973	/related	Stan-LGTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-AndroidTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-AndroidTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-iOS	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	157286	/related	Stan-LGTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-iOS	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-FoxtelTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5487016	/related	Stan-HisenseTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-Android	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-AndroidTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	51543	/related	Stan-SamsungTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-HisenseTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-Android	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5487016	/related	Stan-LGTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	149694	/related	Stan-iOS	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-AndroidTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-SamsungTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-iOS	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-AndroidTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-iOS	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-HisenseTV	0

SELECT DATE(event_at) as date, count(*) as number_events_with_empty_MLT--feed_source, rec_model, source_program_id, endpoint_link, app_name, array_length(program_ids) as number_of_programs
-- SAFE_CONVERT_BYTES_TO_STRING(FROM_BASE64(correlation_id)) as correlation,
FROM `swordbill-beta.staging.stg_rec__feedgen_events`
where true
and rec_model like 'mlt%'
and array_length(program_ids) = 0
group by DATE(event_at)
order by date
 -- see https://docs.google.com/spreadsheets/d/1yc-Efp9xuB6P3Tcb7Tn44Bu2J43JJwftjFQ-SM47Cxw/edit?usp=sharing

```

## Queried

```
-- SELECT rec_model, count(*)
-- FROM `swordbill-beta.staging.stg_rec__feedgen_events`
-- where rec_model like 'mlt%'
-- group by rec_model
-- --WHERE TIMESTAMP_TRUNC(event_timestamp, DAY) = TIMESTAMP("2025-12-05") 
-- --LIMIT 1000
-- rec_model	f0_
-- mlt-cvr-srv-demotehistory	113366939
-- mlt-cvr-srv	311812568


-- SELECT TIMESTAMP_TRUNC(event_at, DAY) as date, feed_source, rec_model, source_program_id, endpoint_link, app_name, array_length(program_ids) as number_of_programs
-- -- SAFE_CONVERT_BYTES_TO_STRING(FROM_BASE64(correlation_id)) as correlation,
-- FROM `swordbill-beta.staging.stg_rec__feedgen_events`
-- where true
-- and rec_model like 'mlt%'
-- and TIMESTAMP_TRUNC(event_at, DAY) = TIMESTAMP("2025-12-05") 
-- and array_length(program_ids) = 0
-- order by event_at 
-- limit 1000

-- date	feed_source	rec_model	source_program_id	endpoint_link	app_name	number_of_programs
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	103973	/related	Stan-LGTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-AndroidTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-AndroidTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-iOS	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	157286	/related	Stan-LGTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-iOS	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-FoxtelTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5487016	/related	Stan-HisenseTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-Android	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-AndroidTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	51543	/related	Stan-SamsungTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-HisenseTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-Android	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5487016	/related	Stan-LGTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	149694	/related	Stan-iOS	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-AndroidTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-SamsungTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-iOS	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-AndroidTV	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-iOS	0
-- 2025-12-05 00:00:00.000000 UTC	pdp	mlt-cvr-srv	5681682	/related	Stan-HisenseTV	0

-- SELECT DATE(event_at) as date, count(*) as number_events_with_empty_MLT
-- FROM `swordbill-beta.staging.stg_rec__feedgen_events`
-- where true
-- and rec_model like 'mlt%'
-- and array_length(program_ids) = 0
-- group by DATE(event_at)
-- order by date
--  -- see https://docs.google.com/spreadsheets/d/1yc-Efp9xuB6P3Tcb7Tn44Bu2J43JJwftjFQ-SM47Cxw/edit?usp=sharing

with dates as (
  SELECT
    date
FROM
    UNNEST(GENERATE_DATE_ARRAY('2025-07-11', '2025-12-05')) AS date
),
all_mlt as (
  SELECT DATE(event_at) as date, count(*) as number_MLT_events
  FROM `swordbill-beta.staging.stg_rec__feedgen_events`
  where true
  and rec_model like 'mlt%'
  group by DATE(event_at)
  order by date
),
zero_mlt as (
  SELECT DATE(event_at) as date, count(*) as number_empty_MLT_events
  FROM `swordbill-beta.staging.stg_rec__feedgen_events`
  where true
  and rec_model like 'mlt%'
  and array_length(program_ids) = 0
  group by DATE(event_at)
  order by date
 )
 select  all_mlt.date, round(number_MLT_events/1000000, 2) as millions_mlt_events, number_empty_MLT_events, round(100 * number_empty_MLT_events/number_MLT_events, 4) as percent_empty
 from dates left outer join all_mlt
on dates.date = all_mlt.date
left outer join zero_mlt
on dates.date = zero_mlt.date
order by date

```

(https://console.cloud.google.com/bigquery?sq=295719655560:6471e504c1544727be364f4832425b7e)

And Graphs in Sheets here : (https://docs.google.com/spreadsheets/d/1uw2h6OxU5Dr5ruhZouWaRg1aBbiLUcew0MDqaXY41wc/edit?gid=1998650008#gid=1998650008)




