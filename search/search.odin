package client_example

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strings"

import json "core:encoding/json"

import client "../vendor/odin-http/client"

main :: proc() {
	get(os.args[1], os.get_env("JWT"))
}

// basic get request.
get :: proc(query: string, jwToken: string) {
	//env := "api.test.streamco.com.au"
	env := "api.stan.com.au"
	base_url := "https://%s/search/v12/search?q=%s&jwToken=%s"
    res, err := client.get( fmt.tprintf(base_url, env, query, jwToken) )

	if err != nil {
		fmt.printf("Request failed: %s", err)
		return
	}
	defer client.response_destroy(&res)

	fmt.printf("Status: %s\n", res.status)
	fmt.printf("Headers: %v\n", res.headers)
	fmt.printf("Cookies: %v\n", res.cookies)
	body, allocation, berr := client.response_body(&res)
	if berr != nil {
		fmt.printf("Error retrieving response body: %s", berr)
		return
	}
	defer client.body_destroy(body, allocation)
    plain := body.(client.Body_Plain)
    data := plain[:]
    // Parse the data into a generic json.Value
    json_val, jerr := json.parse(transmute([]u8)(data))
    if jerr != .None {
        fmt.printf("JSON parse error: %v\n", jerr)
        return
    }
    defer json.destroy_value(json_val) // Remember to clean up the allocated memory

    pprint( json_val, 0 )
    fmt.println()

}

indent :: proc(level: int) {
    fmt.printf("%d %s", level, strings.repeat("  ", level))
}

pprint :: proc(tree: json.Value, level: int) {
    switch v in tree {
        case json.Object:
            keys := make([dynamic]string, len(v))
            for key in v {
                k: string = key
                append(&keys, k)
            }
            slice.sort(keys[:])
            for k in keys  {
                if k != "" {
                    fmt.printf("\n")
                    indent(level)
                    fmt.printf("%s: ", k)
                    pprint(v[k], level + 1)
                }
            }
        case json.Array:
            for item, i in v {
                fmt.printf("\n")
                indent(level)
                fmt.printf("%d:", i)
                pprint(v[i], level + 1)
            }
        case json.Float:
            fmt.printf("%d", int(v))
        case i64:
            fmt.printf("%d", v)
        case bool, string:
            fmt.printf("%v", v)
        case json.Null:
            fmt.printf("null")
    }
}
