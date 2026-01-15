package features

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc () {
    feat, _ := strconv.parse_u64(os.args[1])
    for name, f in features {
        if feat & (u64(1) << f) == 0 { continue }
        fmt.printf("%d %r %s\n", f, u8_to_char(f), name)
    }

}