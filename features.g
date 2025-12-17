var feature-table
  tag Alist
      data
        FeatureOffline = 0
        FeatureInternal = 1
        FeatureUhd = 2
        FeatureKidsProfile = 3
        FeatureStandardPlan = 4
        FeatureQA = 5
        FeatureSport = 6
        FeatureGlobalised = 7
        FeatureAskWhoIsWatching = 8
        FeaturePremiumPlan = 9
        FeatureDynamicSitemap = 10
        FeatureFullFeeds = 11
        FeatureHDR = 12
        FeatureDolbyVision = 13
        FeatureDolbyAtmos = 14
        FeatureHEVC = 15
        FeaturePlayReadyNoOutputProtection = 16
        FeatureSportUpsell = 17
        FeatureDashWithTimeline = 18
        FeatureLive = 19
        FeatureItunesBilled = 20
        FeatureStripeBilled = 21
        FeatureSportStreamingInVenues = 24
        FeatureLiveUHD = 25
        FeatureNewProfile = 27
        FeatureItunesPurchaseAvailable = 28
        FeatureOlderProfile = 29
        FeatureClearAudio = 30
        FeatureAllowInAppPurchases = 31
        FeatureLinearStream = 32
        FeatureForceSD = 33
        FeatureStudioScreen2160 = 34
        FeatureStudioHWSecurity = 35
        FeatureStudioPartlyUnhackable = 36
        FeatureStudioUnhackable = 37
        FeatureQualityUpsell = 38
        FeatureSubhubBilled = 39
        FeatureWidevineOrPlayReady = 40
        FeatureFairPlay = 41
        FeatureSubhub = 42
        FeatureSubhubNav = 43
        FeatureEntertainment = 44
        FeatureExperimentFourthCta = 45
        FeatureOptusBasicAndSportUpsellExperiment = 46
        FeatureOptusStandardAndSportUpsellExperiment = 47
        FeatureCommonAccessToken = 48

def isBitSet? (bits bitno)
    var q (/ bits (power 2 bitno))
    not (equal? (% (- q (% q 1))2) 0)

def features-decode-aux ((bits = Bignum) ft)
    cond
        (null? ft) nil
        else
            #print (list @LINE ft!left (length ft!right))
            cond
                (isBitSet? bits ft!left!right)
                    #print (list @LINE ft!left (length ft!right))
                    cons ft!left!left
                        features-decode-aux bits ft!right
                else
                    features-decode-aux bits ft!right
#print (list @LINE (+ (power 2 48) (power 2 64)) (features-decode-aux (+ (power 2 48) (power 2 6)) feature-table))
assert
    equal? ^(FeatureSport FeatureCommonAccessToken) (features-decode-aux (+ (power 2 48) (power 2 6)) feature-table)

def features-decode ((bits = Bignum))
    sort
        features-decode-aux bits feature-table

