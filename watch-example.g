#!/usr/bin/env genyris

# From Slack

    # ~ Michael
    # ~ 11:03
    # ~ @bbirch see
    # ~ https://api.stan.com.au/rec/v1/related?genres=Sport%2CFootball&maxRating=PG&source=5486795&started=true
    # ~ https://api.stan.com.au/rec/v1/related?genres=Sport%2CFootball&maxRating=PG&source=5486795

@ns sys 'http://www.genyris.org/lang/system#'
@ns u 'http://www.genyris.org/lang/utilities#'
@ns web 'http://www.genyris.org/lang/web#'
@ns date 'http://www.genyris.org/lang/date#'

var started 
    cond
        (equal? 2 (length sys:argv)) (nth 1 sys:argv)
        else ''

#var jwToken 'eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzM4OTYzMjgsImlhdCI6MTc2MzUyODMyOCwianRpIjoiMWQ1NGFjZmQ1MmY4NDFjNWJmOTNjZmUxMDk0NzQ0YjQiLCJyb2xlIjoidXNlciIsInVpZCI6IjRhOTU2YTVjYTM3MDRhN2U4ZDI0M2U3ZTUwODE1OTAzIiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjQsInByb2ZpbGVJZCI6IjRhOTU2YTVjYTM3MDRhN2U4ZDI0M2U3ZTUwODE1OTAzIiwicHJvZmlsZU5hbWUiOiJZb2hhbmVzIiwidHoiOiJBdXN0cmFsaWEvU3lkbmV5IiwiYXBwIjoiU3Rhbi1XZWIiLCJ2ZXIiOiJkNmZlMjVkIiwibnVpZCI6IjcxYjliYWE0ZDhjMjQzOTQ5OWIyM2ViZWNjZmEwYzRmIiwiYXBpZCI6IjIxNmJjYjYyLTRkNDAtZmZhOC04OTdmLWUxOTdlOWI1MjU0YiIsImZlYXQiOjIzNDQxMzk3NTE2MDk4LCJwdXJjaGFzZXMiOjIxOTIsInByaWNlTmFtZSI6InByZW1pdW12NiJ9.HB_ySDMiRKFCVNfZV9_Likp3Lr2NNGcHSDglnw9u9js'
var jwToken-test 'eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzQ1ODE5MDMsImlhdCI6MTc2NDIxMzkwMywianRpIjoiMTBjNGQ0YzZjY2FhNDkzNjk2YWJkOGU5YzdhNTlmYjgiLCJyb2xlIjoidXNlciIsInVpZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjQsInByb2ZpbGVJZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwicHJvZmlsZU5hbWUiOiJQZXRlciIsInR6IjoiQXVzdHJhbGlhL01lbGJvdXJuZSIsImFwcCI6IlN0YW4tV2ViIiwidmVyIjoiNjljY2Y0ZiIsIm51aWQiOiIyNzFlYzk3Zjc2ODM0YWYxYTEyNWFlM2U5MTIyZjJjNiIsImFwaWQiOiJiMjZkNWI3ZS1jNzU1LWUyMTQtNjhiYy0zY2UyZGJlMWJiMGQiLCJmZWF0IjoyMzQzNzEwMjU0ODgwMCwicHJpY2VOYW1lIjoidmlwIn0.R5kEuYbvcrdc-s4fWDK15AjvrAt4cIvDV5iE0CA6e_M'
var jwToken-prod 'eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzQ1ODg5NTksImlhdCI6MTc2NDIyMDk1OSwianRpIjoiNTcwYzZiNWFjZTVkNDIyMGFmZGJiZGEyNWMwNzc1NTYiLCJyb2xlIjoidXNlciIsInVpZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjQsInByb2ZpbGVJZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwicHJvZmlsZU5hbWUiOiJQZXRlciIsInR6IjoiQXVzdHJhbGlhL01lbGJvdXJuZSIsImFwcCI6IlN0YW4tV2ViIiwidmVyIjoiNjljY2Y0ZiIsIm51aWQiOiIyNzFlYzk3Zjc2ODM0YWYxYTEyNWFlM2U5MTIyZjJjNiIsImFwaWQiOiJiMjZkNWI3ZS1jNzU1LWUyMTQtNjhiYy0zY2UyZGJlMWJiMGQiLCJmZWF0IjoyMzQzNzEwMjU0ODgwMCwicHJpY2VOYW1lIjoidmlwIn0.0EcsHakssTf-LOjJ8gL0G91LSqucUghkJ_tJHS0OBeM'
var jwToken jwToken-prod
var jwt-result
    os!exec 'jwt-cli' 'decode' '-t' jwToken
var token-expiry 
    ((jwt-result!left!left) (.fromJSON))!payload!exp

var programID 5487021
        
var URL
    'https://api.stan.com.au/rec/v1/related?genres=Sport%2CFootball&maxRating=PG&source=%a%a'
        .format programID started
        
print URL

var last-body ''
while true
    print URL
    var response
        web:get URL #^(('Cache-Control' = 'no-store')) '1.1'
    var headers (tag Alist response!right!left)
#    u:format "jwtoken.exp: %a\n" token-expiry
    u:format "  status: %a headers: " response!right!right
    for H in headers
        u:format "%a " H
    print
    var body (response!left(.readAll))
    cond
        (equal? '' last-body) nil
        (not (equal? body last-body))
            print '  body has changed'
    setq last-body body
    var bodi (body(.fromJSON))
    cond 
        (bodi (bound? ^.errors))
            u:format "  %s\n" body
            os!exit
        else
            u:format "  number of entries: %a\n" (length bodi!entries)
            u:format "  total: %a\n" bodi!total
            u:format "  vendor: %a\n" bodi!vendor
            u:format "  model: %a\n" bodi!model
            u:format "  updated: %a, %a, %a\n" bodi!updated (date:format-date (* 1000 bodi!updated) "dd MMM yyyy HH:mm:ss z" "Australia/Melbourne" ) (date:format-date (* 1000 bodi!updated) "dd MMM yyyy HH:mm:ss z" "UTC" )
            cond 
                (bodi (bound? ^.correlationId))
                    u:format "  correlationId: '%s'\n" (bodi!correlationId(.fromBase64))
            cond
                (not (equal? 0 (length bodi!entries)))
                    u:format "NOT EMPTY\n"
                    #print body
                    os!exit
    sleep (* 15 1000)
