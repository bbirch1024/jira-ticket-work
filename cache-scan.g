#!/usr/bin/env genyris
#
#
#  Script to excercise the MLT API (production). Runs every 1 second.
#
# - Vary lines 28-34 for different parameter combinations.
# - check header Cache-Control = max-age=
#
# Example output:
#  $ ./cache-scan.g 
#  'https://api.stan.com.au/rec/v1/related?genres=Sport%2CFootball&maxRating=PG&source=5686315&started=true&jwToken='
#  status: ((200 OK))
#  (Content-Type = application/json; charset=utf-8)    (Vary = Accept-Encoding)    (Cache-Control = max-age=300)    (Date = Tue, 02 Dec 2025 05:01:01 GMT)    (Connection = keep-alive)    (Access-Control-Allow-Origin = *) (dict (.entries = nil) (.model = 'related') (.title = 'More Like This') (.total = 0) (.updated = 1764651661) (.vendor = 1))
#    
@ns sys 'http://www.genyris.org/lang/system#'
@ns u 'http://www.genyris.org/lang/utilities#'
@ns web 'http://www.genyris.org/lang/web#'
@ns date 'http://www.genyris.org/lang/date#'

var iterations (power 2 62)

cond
    (equal? 2 (length sys:argv))
        setq iterations (parse (nth 1 sys:argv))

var programsJSON (((File!new 'production.sport.programs.json')(.open ^read))(.readAll))
var programs (programsJSON(.fromJSON))

for P in programs
    var URL
        'https://api.stan.com.au/rec/v1/related?genres=%a&maxRating=PG&source=%a%a%a'
             .format 'Sport%2CFootball' P!id '&started=true' '&jwToken='
    #        .format 'Sport%2CFootball' P!id '&started=true' ('&jwToken=%a'(.format jwToken-prod)) # default
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
    sleep (* 1000 1)
