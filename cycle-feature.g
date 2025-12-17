#!/usr/bin/env genyris

@ns sys 'http://www.genyris.org/lang/system#'
@ns u 'http://www.genyris.org/lang/utilities#'
@ns web 'http://www.genyris.org/lang/web#'
@ns date 'http://www.genyris.org/lang/date#'


# https://api.test.streamco.com.au/rec/v1/related?source=2835085&feat=2

include 'features.g'



for F in feature-table
    var bitwise (power 2 F!right)    
    #print 
    #    list @LINE F bitwise
    var related-result
        web:get 
            'https://api.test.streamco.com.au/rec/v1/related?source=2835085&feat=%a'
                .format (power 2 F!right)
    var related-body (related-result!left(.readAll))
    var body (related-body(.fromJSON))
    u:format "%a bit: %a \n   total: %a\n   vendor: %a\n   entries:\n" F!left F!right body!total body!vendor
    for E in body!entries
        u:format "     %a %s\n" E!id E!title
    
