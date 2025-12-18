#!/usr/bin/env genyris

#
# Unpack an log from https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#logsV2:log-groups/log-group/prod$252Frec/log-events$3Fstart$3D-1800000
#
@ns sys 'http://www.genyris.org/lang/system#'
@ns u 'http://www.genyris.org/lang/utilities#'
@ns web 'http://www.genyris.org/lang/web#'
@ns date 'http://www.genyris.org/lang/date#'

def de-hex (S)
    var result S
    for % in  (data ('%20' = ' ') ('%2B' = '(') ('%2C' = ',') ('%2F' = '/') ('%3A' = ':'))
        setq result (result(.replace (left %) (right %)))
    result
    
def filter(sp)
    de-hex (nth 1 sp)  

def unpack-params(path)
    var params (graph)
    var X (path(.split '[&?]'))
    for P in X
        params(.put ^param ^path X!left)
        var sp (P(.split '='))
#       print sp
        cond
            (equal? 2 (length sp))
                var value (filter sp)
                params(.put ^param (intern sp!left) value)
    params
                
var input 'error-Nov.24.09.not-token.related.tsv'
var path-records-result
    os!exec '/bin/bash' '-c' 
        'duckdb -csv -noheader -c "select event_path from \'%a\';"'
            .format input
        
var paths path-records-result!left
for P in paths
    var params (unpack-params P)
    var get-response
        web:get 
            'https://api.stan.com.au/rec/v1%a'
                .format P
    var status (nth 2 get-response)
    var body (get-response!left(.readAll))
    var related (body(.fromJSON))
    cond 
        (related(bound? ^.errors))
            u:format "Errors %a\n" (params(.get-list ^param ^source)) 
            for T in params
                u:format "    %a %a\n" T!predicate T!object
            print related
        (not (related(bound? ^.total)))
            u:format "No total %a\n" (params(.get-list ^param ^source)) 
            for T in params
                u:format "    %a %a\n" T!predicate T!object
            print related
        (and (related(bound? ^.total)) (equal? 0 related!total))
            u:format "Zero entries %a\n" (params(.get-list ^param ^source)) 
            print related
        else
            u:format "Entries %a %a\n" (params(.get-list ^param ^source)) related!total
    cond
        (not (equal? 200 status!left))
            u:format "Bad request %a %a\n" (params(.get-list ^param ^source)) status
            for T in params
                u:format "    %a %a\n" T!predicate T!object
            print related
    sleep (* 1000 1) 
