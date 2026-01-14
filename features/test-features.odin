package features

import "core:testing"

@(test)
my_test :: proc(t: ^testing.T) {
    init()
    testing.expect_value(t, featuresToString( (u64(1) << 44) | (u64(1) << 38), ","), "FeatureEntertainment,FeatureQualityUpsell")
}
