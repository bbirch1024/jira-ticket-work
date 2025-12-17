#!/usr/bin/env genyris

@ns sys 'http://www.genyris.org/lang/system#'
@ns u 'http://www.genyris.org/lang/utilities#'
@ns web 'http://www.genyris.org/lang/web#'
@ns date 'http://www.genyris.org/lang/date#'


# https://api.test.streamco.com.au/rec/v1/related?source=2835085&feat=2

include 'features.g'

var token 
    ((File!new 'tokens/testToken.jwt')(.open ^read))
        .readAll

var jwt
    ((os!exec 'jwt-cli' 'decode' '-t' token)!left!left)(.fromJSON)


def related()
    var related-result
        web:get 
            'https://api.test.streamco.com.au/rec/v1/related?source=2835085'
    var related-body (related-result!left(.readAll))
    var body (related-body(.fromJSON))

def related-feat-jwt(features token)
    var related-result
        web:get 
            'https://api.test.streamco.com.au/rec/v1/related?source=2835085&feat=%a&jwToken=%a'
                .format features token
    var related-body (related-result!left(.readAll))
    var body (related-body(.fromJSON))

def related-feat(features)
    var related-result
        web:get 
            'https://api.test.streamco.com.au/rec/v1/related?source=2835085&feat=%a'
                .format features
    var related-body (related-result!left(.readAll))
    var body (related-body(.fromJSON))

def related-jwt(token)
    var related-result
        web:get 
            'https://api.test.streamco.com.au/rec/v1/related?source=2835085&jwToken=%a'
                .format token
    var related-body (related-result!left(.readAll))
    var body (related-body(.fromJSON))


def print-related (heading body)
    u:format "%a\n   total: %a\n   vendor: %a\n   entries:\n" heading body!total body!vendor
    for E in body!entries
        u:format "     %a %s\n" E!id E!title
    u:format "\n"

print-related 'No features no token'
    related
    
print-related ('Just jwToken with features %a %a'(.format jwt!payload!feat (features-decode jwt!payload!feat)))
    related-jwt token


print-related 'Just with FeatureSport and FeatureEntertainment'
    related-feat
        + 
            power 2 (feature-table(.lookup ^FeatureSport))
            power 2 (feature-table(.lookup ^FeatureEntertainment))
            
for F in feature-table
    var bitwise (power 2 F!right)    
    var body (related-feat bitwise)
    cond
        (> body!total 0)
            print-related ("%a bit: %a"(.format F!left F!right)) body
