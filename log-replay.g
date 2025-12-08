#!/usr/bin/env genyris

#
# See what the users got 
#
@ns sys 'http://www.genyris.org/lang/system#'
@ns u 'http://www.genyris.org/lang/utilities#'
@ns web 'http://www.genyris.org/lang/web#'
@ns date 'http://www.genyris.org/lang/date#'

import csv

var jwToken-prod 'eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NzQ1ODg5NTksImlhdCI6MTc2NDIyMDk1OSwianRpIjoiNTcwYzZiNWFjZTVkNDIyMGFmZGJiZGEyNWMwNzc1NTYiLCJyb2xlIjoidXNlciIsInVpZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwic3RyZWFtcyI6ImhkIiwiY29uY3VycmVuY3kiOjQsInByb2ZpbGVJZCI6IjU4MTE1MmVkMjhmNjRjZjJhMWU1MmU3ODk3MjViZjBhIiwicHJvZmlsZU5hbWUiOiJQZXRlciIsInR6IjoiQXVzdHJhbGlhL01lbGJvdXJuZSIsImFwcCI6IlN0YW4tV2ViIiwidmVyIjoiNjljY2Y0ZiIsIm51aWQiOiIyNzFlYzk3Zjc2ODM0YWYxYTEyNWFlM2U5MTIyZjJjNiIsImFwaWQiOiJiMjZkNWI3ZS1jNzU1LWUyMTQtNjhiYy0zY2UyZGJlMWJiMGQiLCJmZWF0IjoyMzQzNzEwMjU0ODgwMCwicHJpY2VOYW1lIjoidmlwIn0.0EcsHakssTf-LOjJ8gL0G91LSqucUghkJ_tJHS0OBeM'

var rows
    csv!read ((File(.new (nth 1 sys:argv))) (.open ^read)) ',' '"'

var sources (graph)
for R in rows
    var path (nth (- (length R) 1) R)
    cond
        (not (path(.match '^/.*')))
            #print path
        else
            var source ''
            for param in (path(.split "&"))
                var kv (param(.split '='))
                #print kv
                cond
                    (equal? 'source' kv!left)
                        setq source (nth 1 kv)
                        sources(.put (intern source) true true)
print 
    sources(.length)
    sources(.subjects)

#var random-selection (os!exec 'jot' '-r' '30' '1' '9999')!left

var MLTs (graph)
for source in (sources(.subjects))
    var URL
        'https://api.stan.com.au/rec/v1/related?genres=Sport%2CFootball&maxRating=PG&source=%a&jwToken=%a'
            .format source jwToken-prod
    var response
        web:get URL
    var headers (tag Alist response!right!left)
    u:format "%a\n  status: %a\n  headers:\n" URL response!right!right
    for H in headers
        u:format "    %a: %s\n" H!left H!right
    print
    var body (response!left(.readAll)) 
    var bdec (body(.fromJSON))
    MLTs
        .add (intern source) ^model bdec!model
        .add (intern source) ^total bdec!total
        .add (intern source) ^vendor bdec!vendor
    print "body:"
    for V in ^(.model .total .vendor)
        u:format "   %a: %s\n" V (bdec (eval V))
    sleep (* 1000 3)

for T in (MLTs(.select nil ^total 0))
    print T

print ((MLTs(.select nil ^total 0))(.length))
print ((MLTs(.length))

