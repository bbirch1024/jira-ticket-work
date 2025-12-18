#!/usr/bin/env genyris

#
# Unpack an log from https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#logsV2:log-groups/log-group/prod$252Frec/log-events$3Fstart$3D-1800000
#
@ns sys 'http://www.genyris.org/lang/system#'
@ns u 'http://www.genyris.org/lang/utilities#'
@ns web 'http://www.genyris.org/lang/web#'
@ns date 'http://www.genyris.org/lang/date#'


import csv


def left-or-nil (x)
    cond
        (not(equal? 0 (length x)))
            x!left

def de-hex (S)
    var result S
    for % in  (data ('%20' = ' ') ('%2B' = '(') ('%2C' = ',') ('%2F' = '/') ('%3A' = ':'))
        setq result (result(.replace (left %) (right %)))
    result
    
def filter(sp)
    de-hex (nth 1 sp)        

assert (equal? 'a,b' (de-hex 'a%2Cb'))

var headers
    data
        event = (asn city clientIP code correlationID country eventType host ip lat long method path profileID referer region resultCount seedId serverTime sessionAppName time userID user_agent_raw vendor)
        param = (path clipsAutoplayDisabled exclude feat feedTypes genres jwToken recToken kids maxRating nonKids offset profileId purchases source started tripleNav tz)
        jwt = (apid app concurrency exp feat iat jti kids nuid priceName profileId profileName purchases role streams tz tzOffset uid ver)
        recjwt = (concurrency exp feat iat kids profileId profileName role streams uid)

var rows
    csv!read ((File(.new (nth 1 sys:argv))) (.open ^read)) ',' '"'
#print rows

for Hs in headers
    var name Hs!left
    display 
        '\t'
            .join
                map-left Hs!right
                    lambda (f) ('%a_%a'(.format name f))
    display '\t'
display '\n'


            
var all-headers (graph)
var NR 0
for R in rows!right
    setq NR (+ NR 1)
    var message (nth 1 R)
    # "Dec  2 19:54:12 ip-10-1-213-244 rec[5063]: {
#    print message
#    assert (message(.match '^[a-zA-Z]+ +[0-9]+.[0-9]+.[0-9]+.*'))
#    assert (message(.match '^[a-zA-Z]+'))
#    print message
#    os!exit
    var tok (message(.split '\]: '))
    var msg-no-quote ((nth 1 tok)(.replace '\"' '"'))
    var msg-no-cr (msg-no-quote(.replace '\n' ' '))
#    print @LINE msg-no-cr
    var js (msg-no-cr(.fromJSON))
#    print @LINE js!vars
    cond
        (js!user_agent_raw(.match '.*curl.*'))
#        (js!user_agent_raw(.match '.*GoogleAPIError.*'))
        else
            var params (js(.asGraph ^event))
            var X (js!path(.split '[&?]'))
            for P in X
                params(.put ^param ^path X!left)
                var sp (P(.split '='))
#                #print sp
                cond
                    (equal? 2 (length sp))
                        var value (filter sp)
                        params(.put ^param (intern sp!left) value)
            var jwtoken (left-or-nil (params(.get-list ^param ^jwToken)))
            var token nil
#            print (list @LINE jwtoken)
            cond
                (not (null? jwtoken))
                    catch err                     
                        var decoded (os!exec 'jwt-cli' 'decode' '-t' jwtoken)
                        setq token (decoded!left!left(.fromJSON))
                        setq params
                            params(.union (token!payload(.asGraph ^jwt)))
                    cond
                        err
                            setq params (graph)
#                    print params
            var rectoken (left-or-nil (params(.get-list ^param ^recToken)))
            var rtoken nil
#            print (list @LINE rectoken)
            cond
                (not (null? rectoken))
                    catch err                     
                        var decoded (os!exec 'jwt-cli' 'decode' '-t' rectoken)
                        setq rtoken (decoded!left!left(.fromJSON))
                        setq params
                            params(.union (rtoken!payload(.asGraph ^recjwt)))
                    cond
                        err
                            setq params (graph)
#            for T in params
#                print T
#            os!exit
            params
                #u:format '%s\t' NR
                for Hs in headers
                    for P in Hs!right
                        var value (left-or-nil (params (.get-list Hs!left P)))
#                        cond
#                            (and (equal? ^jwToken P) (not (equal? nil value)))
#                                u:format 'redacted\t'
#                            else
                        u:format '%a\t' value 
                u:format '\n'
            for S in (params(.subjects))
                for P in (params(.predicates S))
                    all-headers(.put S P true)

        # ~ for S in (all-headers(.subjects))
            # ~ u:format '%a: ' S
            # ~ for P in (all-headers(.predicates S))
                # ~ u:format '%a ' P
            # ~ display '\n'
        # ~ print (length rows)


