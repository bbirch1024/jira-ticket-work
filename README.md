
## In cloudwatch prod/rec group

search for errors

### Look for errors in /related tothe day of Nov 24 when the issue was reported.

```
{ $.eventType = "error" && $.message != %token% && $.path = %/related% }
```

[AWS CloudWatch query link](https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#logsV2:log-groups/log-group/prod$252Frec/log-events$3Fstart$3D1763974800000$26end$3D1763978399000$26filterPattern$3D$257B+$2524.eventType+$253D+$2522error$2522+$2526$2526+$2524.message+$2521$253D+$2525token$2525+$2526$2526+$2524.path+$253D+$2525$252Frelated$2525+$257D)

Download and convert and decode:

```
./cloud-watch-logs.g error-Nov.24.09.not-token.related.csv > error-Nov.24.09.not-token.related.tsv
```

# see what the falures were

```
$ duckdb -csv -c "select param_path, event_eventType, event_code, param_genres, param_source from 'error-Nov.24.09.not-token.related.tsv';" | frangipanni -breaks ',' -counts -order counts
param_path,event_eventType,event_code,param_genres,param_source: 1
/related,error: 44
    Streamco.Rec.GoogleAPIError: 12
        Sport,5527001: 1
        "Drama,Crime",11725: 1
        Entertainment,5675992: 2
        "Sport,Football",5455363: 3
        nil: 5
            5536297: 1
            5675992: 1
            4994815: 1
            5623880: 2
    Streamco.Rec.VendorNoResults: 32
        Sport,5527001: 1
        "Drama,Crime",11725: 1
        Entertainment,5675992: 2
        nil: 6
            5536297: 1
            5675992: 1
            4994815: 1
            5536191: 1
            5623880: 2
        "Sport,Football": 10
            5455360: 1
            5024797: 1
            5536191: 2
            5455363: 3
            5455361: 3
        "Reality,Entertainment",147105: 12

```

## Replay the errors

Used the recorded URL again. Print out the interesting failures.

```
./replay-errors.g > replay-errors.log.txt
```

[log is here](replay-errors.log.txt)

Some zero entries returned

    Zero entries (4994815)
    Zero entries (5455363)

One actual error (the source not exists)

```
    Errors (5675992)
        tz Australia/Melbourne
        path /related
        jwToken eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzQzNDQxODAsImlhdCI6MTc2Mzk3NjE4MCwianRpIjoiNTE3YTUyNmFkZTljNDFlMWJiMTYyNGQwY2IyMWJiOWQiLCJyb2xlIjoidXNlciIsInVpZCI6IjM3YjAwNmViYzliZDRiY2NiMzI0MjRlODRiZWQ3MmFhIiwic3RyZWFtcyI6InNkIiwiY29uY3VycmVuY3kiOjEsInByb2ZpbGVJZCI6IjM3YjAwNmViYzliZDRiY2NiMzI0MjRlODRiZWQ3MmFhIiwicHJvZmlsZU5hbWUiOiJLZWxzZXkiLCJhcHAiOiJTdGFuLWlPUyIsInZlciI6IjQuNDEuMC41NDYiLCJudWlkIjoiZjhjZWE4MzQzODdlNDEyMjhkMzJjZGNlM2M5NzU2ODQiLCJhcGlkIjoiYjFjODM1OWYtMzU0ZC02NTg3LTc4MGMtYmQ3YWQ1YTIxZjUyIiwiZmVhdCI6MjAzMDcxNDUwMzI5NjAsInByaWNlTmFtZSI6ImJhc2ljdjIifQ.fLhgDJyPZcu7kHT32Q_QgKkF9t45QOHA316p9E0S2Rg
        source 5675992
        purchases 0
        offset 0
        feat 20307145032960
    dict (.errors = ((dict (.code = 'Streamco.Rec.BadRequest') (.message = 'program 5675992 not found & no genres provided'))))
    Bad request (5675992) (404 Not Found)
        tz Australia/Melbourne
        path /related
        jwToken eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzQzNDQxODAsImlhdCI6MTc2Mzk3NjE4MCwianRpIjoiNTE3YTUyNmFkZTljNDFlMWJiMTYyNGQwY2IyMWJiOWQiLCJyb2xlIjoidXNlciIsInVpZCI6IjM3YjAwNmViYzliZDRiY2NiMzI0MjRlODRiZWQ3MmFhIiwic3RyZWFtcyI6InNkIiwiY29uY3VycmVuY3kiOjEsInByb2ZpbGVJZCI6IjM3YjAwNmViYzliZDRiY2NiMzI0MjRlODRiZWQ3MmFhIiwicHJvZmlsZU5hbWUiOiJLZWxzZXkiLCJhcHAiOiJTdGFuLWlPUyIsInZlciI6IjQuNDEuMC41NDYiLCJudWlkIjoiZjhjZWE4MzQzODdlNDEyMjhkMzJjZGNlM2M5NzU2ODQiLCJhcGlkIjoiYjFjODM1OWYtMzU0ZC02NTg3LTc4MGMtYmQ3YWQ1YTIxZjUyIiwiZmVhdCI6MjAzMDcxNDUwMzI5NjAsInByaWNlTmFtZSI6ImJhc2ljdjIifQ.fLhgDJyPZcu7kHT32Q_QgKkF9t45QOHA316p9E0S2Rg
        source 5675992
        purchases 0
        offset 0
        feat 20307145032960
```

Tested program 5675992 in the browser, and got this message, not 'Oops'

    Sorry, we couldn't find this program
    It may have been removed or isn't available yet.
    Error code C4


All the rest have entries.

Conclusion is this is no longer a problem.

### Found bad recTokens - whatrever :-(

[link](https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#logsV2:log-groups/log-group/prod$252Frec/log-events$3Fstart$3D1765962000000$26end$3D1766102399000$26filterPattern$3D$257B+$2524.eventType+$253D+$2522error$2522+$2526$2526+$2524.message+$253D$2525token$2525++$257D)


```
{ $.eventType = "error" && $.message =%token%  }
```

example output

```
Dec 17 09:00:14 ip-10-1-220-33 rec[5354]: 
{
    "asn": "1221",
    "city": "SYDNEY",
    "clientIP": "1.145.99.55",
    "code": "Streamco.Rec.Unauthorized",
    "country": "AU",
    "error": true,
    "eventType": "error",
    "host": "rec-loadbal-1gnegzdocpid4-81963089.ap-southeast-2.elb.amazonaws.com",
    "ip": "1.145.99.55, 23.205.115.36, 23.40.103.185",
    "lat": "-33.88",
    "long": "151.22",
    "message": "invalid session token: couldn't parse eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NjU5Mjk2MDAsImlhdCI6MTc2NTc1NjgwMCwicm9sZSI6IiIsInVpZCI6IjU2ZWY1YThkZGM3ZDQ4NjBiYjhjNmI1N2I3NWE4YzA4Iiwic3RyZWFtcyI6IiIsImNvbmN1cnJlbmN5IjowLCJwcm9maWxlSWQiOiI1NmVmNWE4ZGRjN2Q0ODYwYmI4YzZiNTdiNzVhOGMwOCIsInByb2ZpbGVOYW1lIjoiIiwiZmVhdCI6NTQxMzc1NjI0NzAxNDh9.yaiaMWepz2WF4JRYiwy5ELACAWjSSCe8jm7a8zExtqE: token is expired",
    "method": "GET",
    "path": "/topshows?recToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NjU5Mjk2MDAsImlhdCI6MTc2NTc1NjgwMCwicm9sZSI6IiIsInVpZCI6IjU2ZWY1YThkZGM3ZDQ4NjBiYjhjNmI1N2I3NWE4YzA4Iiwic3RyZWFtcyI6IiIsImNvbmN1cnJlbmN5IjowLCJwcm9maWxlSWQiOiI1NmVmNWE4ZGRjN2Q0ODYwYmI4YzZiNTdiNzVhOGMwOCIsInByb2ZpbGVOYW1lIjoiIiwiZmVhdCI6NTQxMzc1NjI0NzAxNDh9.yaiaMWepz2WF4JRYiwy5ELACAWjSSCe8jm7a8zExtqE&zzz=json&jwToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzYzMzAwMTMsImlhdCI6MTc2NTk2MjAxMywianRpIjoiNzY3YzQwYTM2Y2JlNDFkYjk2NDI5NTE0NWY2Y2Y0ZjkiLCJyb2xlIjoidXNlciIsInVpZCI6IjU2ZWY1YThkZGM3ZDQ4NjBiYjhjNmI1N2I3NWE4YzA4Iiwic3RyZWFtcyI6InVoZCIsImNvbmN1cnJlbmN5Ijo0LCJwcm9maWxlSWQiOiI1NmVmNWE4ZGRjN2Q0ODYwYmI4YzZiNTdiNzVhOGMwOCIsInByb2ZpbGVOYW1lIjoiQ29keSIsInR6IjoiQXVzdHJhbGlhL1N5ZG5leSIsImFwcCI6IlN0YW4tU2Ftc3VuZ1RWIiwidmVyIjoiOC43LjAiLCJudWlkIjoiNzc3ZDk3ZmMxZjUxNGI4NGE3M2I5ZDJiMzQzOGRlM2IiLCJhcGlkIjoiNTI0MmNlMTEtZjk4NC1hNzE2LWE1NjUtNzA1ZjdiMzhmNDIxIiwiZmVhdCI6NTQxMzc1NjI0NzAxNDgsInByaWNlTmFtZSI6InByZW1pdW12NiJ9.aXdbfdWfBV313I3AaCNFXTzp7qdkHn8TN-mPRbJIQwE&tz=Australia%2FSydney",
    "profileID": "56ef5a8ddc7d4860bb8c6b57b75a8c08",
    "region": "NSW",
    "serverTime": 1765962014272,
    "status": 400,
    "time": "2025-12-17T09:00:14.272171251Z",
    "userID": "56ef5a8ddc7d4860bb8c6b57b75a8c08",
    "user_agent_raw": "Mozilla/5.0 (SMART-TV; LINUX; Tizen 8.0) AppleWebKit/537.36 (KHTML, like Gecko) 108.0.5359.1/8.0 TV Safari/537.36"
}
```

paste to a file `foo.txt`, then rename it

```
mv foo.txt error-$(head -1 foo.txt | tr ' ' '.' | tr -d '[]')txt
```

Query the data

```
./cloud-watch-logs.g cloudwatch.error.token.csv > cloudwatch.error.token.tsv
 duckdb -c "SELECT param_path, count(*) number FROM read_csv('cloudwatch.error.token.tsv', sep = '\t', header = true) group by 1 order by 2;"  
```
┌────────────────┬────────┐
│   param_path   │ number │
│    varchar     │ int64  │
├────────────────┼────────┤
│ nil            │      2 │
│ /kids/personal │      6 │
│ /because       │     40 │
│ /personal      │    180 │
│ /topshows      │    232 │
└────────────────┴────────┘
```

### An example

```
$ duckdb -line -c "SELECT * FROM read_csv('cloudwatch.error.token.tsv', sep = '\t', header = true) limit 1;" | grep -v -e NULL -e nil 
                  event_asn = 1221
                 event_city = SYDNEY
             event_clientIP = 1.145.99.55
              event_country = AU
            event_eventType = error
                 event_host = rec-loadbal-1gnegzdocpid4-81963089.ap-southeast-2.elb.amazonaws.com
                   event_ip = 1.145.99.55, 23.205.115.36, 23.40.103.185
                  event_lat = -33.88
                 event_long = 151.22
               event_method = GET
                 event_path = /topshows?recToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NjU5Mjk2MDAsImlhdCI6MTc2NTc1NjgwMCwicm9sZSI6IiIsInVpZCI6IjU2ZWY1YThkZGM3ZDQ4NjBiYjhjNmI1N2I3NWE4YzA4Iiwic3RyZWFtcyI6IiIsImNvbmN1cnJlbmN5IjowLCJwcm9maWxlSWQiOiI1NmVmNWE4ZGRjN2Q0ODYwYmI4YzZiNTdiNzVhOGMwOCIsInByb2ZpbGVOYW1lIjoiIiwiZmVhdCI6NTQxMzc1NjI0NzAxNDh9.yaiaMWepz2WF4JRYiwy5ELACAWjSSCe8jm7a8zExtqE&zzz=json&jwToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzYzMzAwMTMsImlhdCI6MTc2NTk2MjAxMywianRpIjoiNzY3YzQwYTM2Y2JlNDFkYjk2NDI5NTE0NWY2Y2Y0ZjkiLCJyb2xlIjoidXNlciIsInVpZCI6IjU2ZWY1YThkZGM3ZDQ4NjBiYjhjNmI1N2I3NWE4YzA4Iiwic3RyZWFtcyI6InVoZCIsImNvbmN1cnJlbmN5Ijo0LCJwcm9maWxlSWQiOiI1NmVmNWE4ZGRjN2Q0ODYwYmI4YzZiNTdiNzVhOGMwOCIsInByb2ZpbGVOYW1lIjoiQ29keSIsInR6IjoiQXVzdHJhbGlhL1N5ZG5leSIsImFwcCI6IlN0YW4tU2Ftc3VuZ1RWIiwidmVyIjoiOC43LjAiLCJudWlkIjoiNzc3ZDk3ZmMxZjUxNGI4NGE3M2I5ZDJiMzQzOGRlM2IiLCJhcGlkIjoiNTI0MmNlMTEtZjk4NC1hNzE2LWE1NjUtNzA1ZjdiMzhmNDIxIiwiZmVhdCI6NTQxMzc1NjI0NzAxNDgsInByaWNlTmFtZSI6InByZW1pdW12NiJ9.aXdbfdWfBV313I3AaCNFXTzp7qdkHn8TN-mPRbJIQwE&tz=Australia%2FSydney
            event_profileID = 56ef5a8ddc7d4860bb8c6b57b75a8c08
               event_region = NSW
           event_serverTime = 1765962014272
                 event_time = 2025-12-17T09:00:14.272171251Z
               event_userID = 56ef5a8ddc7d4860bb8c6b57b75a8c08
       event_user_agent_raw = Mozilla/5.0 (SMART-TV; LINUX; Tizen 8.0) AppleWebKit/537.36 (KHTML, like Gecko) 108.0.5359.1/8.0 TV Safari/537.36
                 param_path = /topshows
              param_jwToken = redacted
                   param_tz = Australia/Sydney
                   jwt_apid = 5242ce11-f984-a716-a565-705f7b38f421
                    jwt_app = Stan-SamsungTV
            jwt_concurrency = 4
                    jwt_exp = 2026-04-16T09:00:13Z
                   jwt_feat = 54137562470148
                    jwt_iat = 2025-12-17T09:00:13Z
                    jwt_jti = 767c40a36cbe41db964295145f6cf4f9
                   jwt_nuid = 777d97fc1f514b84a73b9d2b3438de3b
              jwt_priceName = premiumv6
              jwt_profileId = 56ef5a8ddc7d4860bb8c6b57b75a8c08
            jwt_profileName = Cody
                   jwt_role = user
                jwt_streams = uhd
                     jwt_tz = Australia/Sydney
                    jwt_uid = 56ef5a8ddc7d4860bb8c6b57b75a8c08
                    jwt_ver = 8.7.0
         recjwt_concurrency = 0
                 recjwt_exp = 2025-12-17T00:00:00Z
                recjwt_feat = 54137562470148
                 recjwt_iat = 2025-12-15T00:00:00Z
           recjwt_profileId = 56ef5a8ddc7d4860bb8c6b57b75a8c08
                 recjwt_uid = 56ef5a8ddc7d4860bb8c6b57b75a8c08
```
