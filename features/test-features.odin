package features

import "core:testing"
import "core:fmt"

@(test)
featuresToString_test :: proc(t: ^testing.T) {
    init()
    testing.expect_value(t, featuresToString( (u64(1) << 44) | (u64(1) << 38) | (u64(1) << 3), ","), "FeatureEntertainment,FeatureKidsProfile,FeatureQualityUpsell")
}

@(test)
featuresToString2_test :: proc(t: ^testing.T) {
    init()
    fmt.println(len(features), minFeature, maxFeature, allFeatures)

    testing.expect_value(t, featuresToPips( (u64(1) << 0), ","), "A.... ..... ..... ..... ..,,. .,... ..... ..... ..... ....")
    testing.expect_value(t, featuresToPips( (u64(1) << 0) | (u64(1) << 2), ","), "A.C.. ..... ..... ..... ..,,. .,... ..... ..... ..... ....")
    testing.expect_value(t, featuresToPips( (u64(1) << maxFeature), ","), "..... ..... ..... ..... ..,,. .,... ..... ..... ..... ...w")
    testing.expect_value(t, featuresToPips( (u64(1) << 0) | (u64(1) << 22) | (u64(1) << maxFeature), ","), "A.... ..... ..... ..... ..W,. .,... ..... ..... ..... ...w")
}
