#!/usr/bin/env genyris

# from the README
# MOCK_OVERRIDES: '{"f6":{"default":[3181101,1726054,2781352];"5113695":[5084303,5116216,5014986];"2864503":[3143519,2831683,2834182]}; "7cd":{"default": [3181101,1726054,2781352];"5113695":[5084303,5116216,5014986]}}'
#
# In this example, "f6" and "7cd" represent user ID prefix patterns, with the associated values serving as recommendations for those users. 
# Each user entry is a map where the key is the program ID, and the value is an array of recommended programs.
# When the `default` key is present, its content will be used as fallback recommendations if no specific recommendations are found for the current user.

@ns sys 'http://www.genyris.org/lang/system#'
@ns u 'http://www.genyris.org/lang/utilities#'
@ns web 'http://www.genyris.org/lang/web#'
@ns date 'http://www.genyris.org/lang/date#'

# https://api.test.streamco.com.au/programs/v1/programs/1622778?jwToken=eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NjU4Nzk0ODcsImlhdCI6MTc2NTg0MzQ4NywianRpIjoiYzQ2NzdkMzMwNGNjNGE4N2I2ZTZhNGI5N2Q3NGMzM2MiLCJyb2xlIjoidXNlciIsInVpZCI6IjJlM2ZmMDQ0ZDgxMDQ3OGVhNDhiYjI5NmU1MGEzZjZmIiwic3RyZWFtcyI6InNkIiwiY29uY3VycmVuY3kiOjEsInByb2ZpbGVJZCI6IjJlM2ZmMDQ0ZDgxMDQ3OGVhNDhiYjI5NmU1MGEzZjZmIiwicHJvZmlsZU5hbWUiOiJQZXRlciIsInR6IjoiQXVzdHJhbGlhL01lbGJvdXJuZSIsImFwcCI6IlN0YW4tV2ViIiwidmVyIjoiYTNjYTUwYiIsIm51aWQiOiJmZDBiMTQ3Mjc5NWM0ZjVjYTcyYzE5ZGIzMTQ3YWNmMiIsImFwaWQiOiJjNjc0YThmZi1iMGJjLTQ3MjQtYWU2MC0zNjZmZjU4YTFlMDciLCJmZWF0IjoyMzQzNjU2NTY3NzM3OCwicHJpY2VOYW1lIjoiYmFzaWN2MiJ9.Ukg4wfbqXSKw4tBx-qWYpOKDJKkQHuPX5Jndme9bInQ

var jwtoken 'eyJhbGciOiJIUzI1NiIsImtpZCI6InBpa2FjaHUiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3NjU4Nzk0ODcsImlhdCI6MTc2NTg0MzQ4NywianRpIjoiYzQ2NzdkMzMwNGNjNGE4N2I2ZTZhNGI5N2Q3NGMzM2MiLCJyb2xlIjoidXNlciIsInVpZCI6IjJlM2ZmMDQ0ZDgxMDQ3OGVhNDhiYjI5NmU1MGEzZjZmIiwic3RyZWFtcyI6InNkIiwiY29uY3VycmVuY3kiOjEsInByb2ZpbGVJZCI6IjJlM2ZmMDQ0ZDgxMDQ3OGVhNDhiYjI5NmU1MGEzZjZmIiwicHJvZmlsZU5hbWUiOiJQZXRlciIsInR6IjoiQXVzdHJhbGlhL01lbGJvdXJuZSIsImFwcCI6IlN0YW4tV2ViIiwidmVyIjoiYTNjYTUwYiIsIm51aWQiOiJmZDBiMTQ3Mjc5NWM0ZjVjYTcyYzE5ZGIzMTQ3YWNmMiIsImFwaWQiOiJjNjc0YThmZi1iMGJjLTQ3MjQtYWU2MC0zNjZmZjU4YTFlMDciLCJmZWF0IjoyMzQzNjU2NTY3NzM3OCwicHJpY2VOYW1lIjoiYmFzaWN2MiJ9.Ukg4wfbqXSKw4tBx-qWYpOKDJKkQHuPX5Jndme9bInQ'

def properties-of (list-of-names)
    #print @LINE list-of-names
    cond
        (null? list-of-names) nil
        (member? list-of-names!left ^(.self .vars .classes)) nil
        else
            cons
                list-of-names!left
                properties-of list-of-names!right
        
        
def foo ((D = Dictionary))
    ((D(.asGraph true))(.predicates true))

var mocks-json 
    ((File!new 'mlt-mocks.json')(.open ^read))(.readAll)
var mocks (mocks-json(.fromJSON))

    
for user-id-prefix in (foo mocks)
    var programs (mocks (symbol-value (dynamic-symbol-value user-id-prefix)))
    #print @LINE programs
    for id in (foo programs)
        #print (list @LINE id (equal? ^default id))
        cond        
            (not (equal? ^default id))
                #print @LINE user-id-prefix id
                var url
                    'https://api.test.streamco.com.au/programs/v1/programs/%a?jwToken=%a'
                        .format id jwtoken
                var get-response
                    web:get url
                var get-body 
                    get-response!left(.readAll)
                var program (get-body(.fromJSON))
                display 
                    ","(.join (list @LINE user-id-prefix id program!title 'related.genres:' (nth 2 (program!related(.split '[&=?]'))) '\n'))
                for S in program!suggestions!feeds
                    cond 
                        (equal? 'More like this' S!title)
                            display 
                                ","(.join (list @LINE user-id-prefix id  S!title 'feed.genres:' (nth 2 (S!url(.split '[&=?]'))) '\n' ))

