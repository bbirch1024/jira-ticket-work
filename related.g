#!/usr/bin/env genyris
#
#
# Script to excercise production /rec/v1/related
# - optional program id parameter
# - runs one time
# - modify lines 23-30 as needed
#
# Example
# $ ./related.g 
# ~ 'https://api.stan.com.au/rec/v1/related?vendor=google&genres=Sport%2CFootball&maxRating=PG&source=5686315&started=true&jwToken='
# status: ((200 OK))
#   (Content-Type = application/json; charset=utf-8)    (Vary = Accept-Encoding)    (Cache-Control = max-age=300)    
#    (Date = Tue, 02 Dec 2025 05:05:56 GMT)    (Connection = keep-alive)    (Access-Control-Allow-Origin = *) 
#    (dict (.correlationId = 'ChQxNDIzMzM4NTQ3NzQ4MDI3MzA4Nxolc3Rhbi1tb3JlLWxpa2UtdGhpcy1jdnJfMTY4OTg5NDgyNzY3OCILbWx0LWN2ci1zcnYoADACOginoZ03oaGdNw') 
#    (.entries = nil) (.model = 'mlt-cvr-srv') (.title = 'More Like This') (.total = 0) (.updated = 1764651956) (.vendor = 2))
#

@ns sys 'http://www.genyris.org/lang/system#'
@ns u 'http://www.genyris.org/lang/utilities#'
@ns web 'http://www.genyris.org/lang/web#'
@ns date 'http://www.genyris.org/lang/date#'

var programsJSON (((File!new 'production.sport.programs.json')(.open ^read))(.readAll))
var programs (programsJSON(.fromJSON))

var id programs!left!id
cond
    (equal? 2 (length sys:argv))
        setq id (parse (nth 1 sys:argv))

var URL
    'https://api.stan.com.au/rec/v1/related?vendor=google&genres=%a&maxRating=PG&source=%a%a%a'
         .format 'Sport%2CFootball' id '&started=true' '&jwToken='
#        .format 'Sport%2CFootball' id '&started=true' ('&jwToken=%a'(.format jwToken-prod)) # default
#        .format 'Sport%2CFootball' '' ('&jwToken=%a'(.format jwToken-prod))
#        .format 'Sport%2CFootball' '' '&jwToken='
#        .format 'Sport%2CFootball' '' ''
#        .format 'Sport%2CFootball' '&started=cofeffe' ''
#        .format 'Sport%2CFootball' '&started=false' ('&jwToken=%a'(.format jwToken-prod))
print URL
var response
    web:get URL # ^(('Cache-Control' = 'no-store')) '1.1'

var headers (tag Alist response!right!left)
u:format "status: %a\n" response!right!right
for H in headers
    u:format "   %a " H
print
var body (response!left(.readAll))
var bodi (body(.fromJSON))
cond 
    (bodi (bound? ^.errors))
        u:format "%s\n" body
        os!exit
    (and (bodi (bound? ^.entries)) (equal? 0 (length bodi!entries)))
        u:format "%s\n" bodi
    else
        u:format "id: %a\n" P!id
        u:format "number of entries: %a\n" (length bodi!entries)
        u:format "total: %a\n" bodi!total
        u:format "vendor: %a\n" bodi!vendor
        u:format "model: %a\n" bodi!model
        u:format "updated: %a, %a, %a\n" bodi!updated (date:format-date (* 1000 bodi!updated) "dd MMM yyyy HH:mm:ss z" "Australia/Melbourne" ) (date:format-date (* 1000 bodi!updated) "dd MMM yyyy HH:mm:ss z" "UTC" )
        for E in bodi!entries
            u:format "%a: %s, " E!id E!title
        print
