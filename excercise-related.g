#!/usr/bin/env genyris

@ns sys 'http://www.genyris.org/lang/system#'
@ns u 'http://www.genyris.org/lang/utilities#'
@ns web 'http://www.genyris.org/lang/web#'
@ns date 'http://www.genyris.org/lang/date#'

# Example URL
# https://api.test.streamco.com.au/rec/v1/related?genres=Sport%2CFootball&maxRating=PG&source=5455243&jwToken=REDACTED
#

var runtime-url 'http://localhost:5000/related?genres=Sport&source=%a'

var program-ids-raw 
    ((File!new 'integration-test-programs.dat')(.open ^read))(.readAll)
var program-ids (program-ids-raw(.split '\n'))    
for id in program-ids
    var url 
        runtime-url 
            .format id
    u:format "%a %s " id url
    var related-response
        web:get url
    #print related-response
    var mlt (((related-response!left)(.readAll))(.fromJSON))
    u:format "%a %a\n" mlt!total (length mlt!entries)
    //
        for E in mlt!entries
            u:format "%a\n" E!id
            for V in ^(.title .bundle .genre .features)
                u:format "\t%a\t%s\n" V 
                    cond 
                        (E (bound? V))
                            (E (eval V))
        
            
