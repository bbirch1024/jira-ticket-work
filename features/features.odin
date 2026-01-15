package features

import "core:fmt"
import "core:math/bits"
import "core:slice"
import "core:strings"

features : map[string]u64

@(init)
init :: proc "contextless"() {
    features["FeatureOffline"] = 0
    features["FeatureInternal"] = 1
    features["FeatureUhd"] = 2
    features["FeatureKidsProfile"] = 3
    features["FeatureStandardPlan"] = 4
    features["FeatureQA"] = 5
    features["FeatureSport"] = 6
    features["FeatureGlobalised"] = 7
    features["FeatureAskWhoIsWatching"] = 8
    features["FeaturePremiumPlan"] = 9
    features["FeatureDynamicSitemap"] = 10
    features["FeatureFullFeeds"] = 11
    features["FeatureHDR"] = 12
    features["FeatureDolbyVision"] = 13
    features["FeatureDolbyAtmos"] = 14
    features["FeatureHEVC"] = 15
    features["FeaturePlayReadyNoOutputProtection"] = 16
    features["FeatureSportUpsell"] = 17
    features["FeatureDashWithTimeline"] = 18
    features["FeatureLive"] = 19
    features["FeatureItunesBilled"] = 20
    features["FeatureStripeBilled"] = 21
    features["FeatureSportStreamingInVenues"] = 24
    features["FeatureLiveUHD"] = 25
    features["FeatureNewProfile"] = 27
    features["FeatureItunesPurchaseAvailable"] = 28
    features["FeatureOlderProfile"] = 29
    features["FeatureClearAudio"] = 30
    features["FeatureAllowInAppPurchases"] = 31
    features["FeatureLinearStream"] = 32
    features["FeatureForceSD"] = 33
    features["FeatureStudioScreen2160"] = 34
    features["FeatureStudioHWSecurity"] = 35
    features["FeatureStudioPartlyUnhackable"] = 36
    features["FeatureStudioUnhackable"] = 37
    features["FeatureQualityUpsell"] = 38
    features["FeatureSubhubBilled"] = 39
    features["FeatureWidevineOrPlayReady"] = 40
    features["FeatureFairPlay"] = 41
    features["FeatureSubhub"] = 42
    features["FeatureSubhubNav"] = 43
    features["FeatureEntertainment"] = 44
    features["FeatureExperimentFourthCta"] = 45
    features["FeatureOptusBasicAndSportUpsellExperiment"] = 46
    features["FeatureOptusStandardAndSportUpsellExperiment"] = 47
    features["FeatureCommonAccessToken"] = 48
}

minFeature: u64
maxFeature: u64
allFeatures: u64

@(init)
initialise :: proc "contextless" ()  {
    minFeature = bits.U64_MAX
    for _, f in features {
        allFeatures |= u64(1) << f
        if f > maxFeature {
            maxFeature = f
        }
        if f < minFeature {
            minFeature = f
        }
    }
}

featuresToString :: proc(feat: u64, sep: string) -> string {
    result: [dynamic]string
    for k, v in features {
        //fmt.printf("%d %s %d %d %v\n", feat, k, v, u64(1) << v, (feat & (u64(1) << v)) != 0 )
        if (feat & (u64(1) << v)) != 0 {
            append(&result, k)
        }
    }
    //fmt.println(result)
    slice.sort(result[:])
    return strings.join(result[:], sep)
}

u8_to_char :: proc(f: u64) -> rune {
    assert(f <= maxFeature)
    if f <= u64(26) {
        return rune('A' + f)
    }
    if f <= 2 * u64(26) {
        return rune('a' + f-u64(26) )
    }
    return rune('0' + f - 2*u64(26))
}

featuresToPips :: proc(feat: u64, sep: string) -> string {
    result: string
    for f := minFeature ; f <= maxFeature ; f += 1 {
        flag: rune = '.'
        if !( (u64(1) << f) & allFeatures != 0 ) {
            flag = ','
        }
        if feat & (u64(1) << f) != 0 {
            flag = u8_to_char(f)
//            fmt.println(f,  u8_to_char(f))
        }
        flgstr := string([]u8{u8(flag)})
        result = strings.concatenate({result, flgstr})
        if (1+len(result)) % 6 == 0 {
            result = strings.concatenate({result, " "})
        }
//        fmt.println(minFeature, f, result)
    }
    return result
}
