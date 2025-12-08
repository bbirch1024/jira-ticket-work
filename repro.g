#!/usr/bin/env genyris
#
# A script to attempt reproduction of the issue
# Hack to suit.
# Caveat Luser
#

@ns sys 'http://www.genyris.org/lang/system#'
@ns u 'http://www.genyris.org/lang/utilities#'
@ns web 'http://www.genyris.org/lang/web#'
@ns date 'http://www.genyris.org/lang/date#'

var iterations (power 2 62)

cond
    (equal? 2 (length sys:argv))
        setq iterations (parse (nth 1 sys:argv))

#var jwToken 'eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzM4OTYzMjgsImlhdCI6MTc2MzUyODMyOCwianRpIjoiMWQ1NGFjZmQ1MmY4NDFjNWJmOTNjZmUxMDk0NzQ0YjQiLCJyb2xlIjoidXNlciIsInVpZCI6IjRhOTU2YTVjYTM3MDRhN2U4ZDI0M2U3ZTUwODE1OTAzIiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjQsInByb2ZpbGVJZCI6IjRhOTU2YTVjYTM3MDRhN2U4ZDI0M2U3ZTUwODE1OTAzIiwicHJvZmlsZU5hbWUiOiJZb2hhbmVzIiwidHoiOiJBdXN0cmFsaWEvU3lkbmV5IiwiYXBwIjoiU3Rhbi1XZWIiLCJ2ZXIiOiJkNmZlMjVkIiwibnVpZCI6IjcxYjliYWE0ZDhjMjQzOTQ5OWIyM2ViZWNjZmEwYzRmIiwiYXBpZCI6IjIxNmJjYjYyLTRkNDAtZmZhOC04OTdmLWUxOTdlOWI1MjU0YiIsImZlYXQiOjIzNDQxMzk3NTE2MDk4LCJwdXJjaGFzZXMiOjIxOTIsInByaWNlTmFtZSI6InByZW1pdW12NiJ9.HB_ySDMiRKFCVNfZV9_Likp3Lr2NNGcHSDglnw9u9js'
var jwToken-test 'eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzQ1ODE5MDMsImlhdCI6MTc2NDIxMzkwMywianRpIjoiMTBjNGQ0YzZjY2FhNDkzNjk2YWJkOGU5YzdhNTlmYjgiLCJyb2xlIjoidXNlciIsInVpZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjQsInByb2ZpbGVJZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwicHJvZmlsZU5hbWUiOiJQZXRlciIsInR6IjoiQXVzdHJhbGlhL01lbGJvdXJuZSIsImFwcCI6IlN0YW4tV2ViIiwidmVyIjoiNjljY2Y0ZiIsIm51aWQiOiIyNzFlYzk3Zjc2ODM0YWYxYTEyNWFlM2U5MTIyZjJjNiIsImFwaWQiOiJiMjZkNWI3ZS1jNzU1LWUyMTQtNjhiYy0zY2UyZGJlMWJiMGQiLCJmZWF0IjoyMzQzNzEwMjU0ODgwMCwicHJpY2VOYW1lIjoidmlwIn0.R5kEuYbvcrdc-s4fWDK15AjvrAt4cIvDV5iE0CA6e_M'
var jwToken-prod 'eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzQ1ODg5NTksImlhdCI6MTc2NDIyMDk1OSwianRpIjoiNTcwYzZiNWFjZTVkNDIyMGFmZGJiZGEyNWMwNzc1NTYiLCJyb2xlIjoidXNlciIsInVpZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjQsInByb2ZpbGVJZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwicHJvZmlsZU5hbWUiOiJQZXRlciIsInR6IjoiQXVzdHJhbGlhL01lbGJvdXJuZSIsImFwcCI6IlN0YW4tV2ViIiwidmVyIjoiNjljY2Y0ZiIsIm51aWQiOiIyNzFlYzk3Zjc2ODM0YWYxYTEyNWFlM2U5MTIyZjJjNiIsImFwaWQiOiJiMjZkNWI3ZS1jNzU1LWUyMTQtNjhiYy0zY2UyZGJlMWJiMGQiLCJmZWF0IjoyMzQzNzEwMjU0ODgwMCwicHJpY2VOYW1lIjoidmlwIn0.0EcsHakssTf-LOjJ8gL0G91LSqucUghkJ_tJHS0OBeM'
var jwToken jwToken-prod
var jwt-result
    os!exec 'jwt-cli' 'decode' '-t' jwToken
var token-expiry 
    ((jwt-result!left!left) (.fromJSON))!payload!exp


var URL-test-blue 

#    'https://2.18.226.155/rec/v1/blue/related?genres=%a&maxRating=PG&source=5641707%a&jwToken-test=%a'
    'https://api.stan.com.au/rec/v1/blue/related?genres=%a&maxRating=PG&source=5641707%a%a'
#        .format 'Sport%2CFootball' '' ''
#        .format 'Sport%2CFootball' '&started=true' ''
#        .format 'Sport%2CFootball' '&started=true' '&jwToken='
        .format 'Sport%2CFootball' '&started=true' ('&jwToken=%a'(.format jwToken-test))
#        .format 'Sport%2CFootball' '&started=true' jwToken-test
#        .format '' jwToken-test
        
var URL-prod-green 

    'https://api.stan.com.au/rec/v1/related?genres=%a&maxRating=PG&source=5486795%a%a' # 5486795
#        .format 'Sport%2CFootball' '&started=true' ''
#        .format 'Sport%2CFootball' '&started=true' '&jwToken='
        .format 'Sport%2CFootball' '&started=true' ('&jwToken=%a'(.format jwToken-prod)) # default
#        .format 'Sport%2CFootball' '' ('&jwToken=%a'(.format jwToken-prod))
#        .format 'Sport%2CFootball' '' '&jwToken='
#        .format 'Sport%2CFootball' '' ''
#        .format 'Sport%2CFootball' '&started=cofeffe' ''
#        .format 'Sport%2CFootball' '&started=false' ('&jwToken=%a'(.format jwToken-prod))
        
var URL URL-prod-green
print URL
os!exit

var last-body ''
while (> iterations 0)
    setq iterations (- iterations 1)
    print URL
    var response
        web:get URL #^(('Cache-Control' = 'no-store')) '1.1'
    var headers (tag Alist response!right!left)
    u:format "jwtoken.exp: %a\n" token-expiry
    u:format "status: %a\n" response!right!right
    for H in headers
        u:format "   %a\n" H
    var body (response!left(.readAll))
    cond
        (equal? '' last-body) nil
        (not (equal? body last-body))
            print 'body has changed'
    setq last-body body
    var bodi (body(.fromJSON))
    cond 
        (bodi (bound? ^.errors))
            u:format "%s\n" body
            os!exit
        (and (bodi (bound? ^.entries)) (equal? 0 (length bodi!entries)))
            for H in response!right!left
                u:format "%s\n" H
            u:format "%s\n" bodi
            os!exit
        else
            u:format "number of entries: %a\n" (length bodi!entries)
            u:format "total: %a\n" bodi!total
            u:format "vendor: %a\n" bodi!vendor
            u:format "model: %a\n" bodi!model
            u:format "updated: %a, %a, %a\n" bodi!updated (date:format-date (* 1000 bodi!updated) "dd MMM yyyy HH:mm:ss z" "Australia/Melbourne" ) (date:format-date (* 1000 bodi!updated) "dd MMM yyyy HH:mm:ss z" "UTC" )
            print bod
    sleep (* 1 10)
