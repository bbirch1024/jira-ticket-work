package cloudwatchlog

import "core:encoding/csv"
import "core:encoding/json"
import "core:fmt"
import "core:net"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

import feat "../features"
import jwt "../../../birchb1024/jwt/jwtdecode"
main :: proc() {

    // open the file
    if len(os.args) < 2 {
        panic("missing filename")
    }
    filename := os.args[1]

    //  read in the input CVS file TODO proc
	r: csv.Reader
	r.trim_leading_space  = true
	r.lazy_quotes = true
	defer csv.reader_destroy(&r)

	csv_data, ok := os.read_entire_file(filename)
	if ok {
		csv.reader_init_with_string(&r, string(csv_data))
	} else {
		fmt.printfln("Unable to open file: %v", filename)
		return
	}
	defer delete(csv_data)

	records, err := csv.read_all(&r)
	if err != nil {
	    panic(fmt.tprintf("%#v", err))
	}

	defer {
		for rec in records {
			delete(rec)
		}
		delete(records)
	}


    // all  field names in a set
    fieldNames: map[string]struct{}
    fieldNames = make(map[string]struct{})
    fieldNames["event_timestamp"] = {}
    fieldNames["jwt_raw"] = {}
    fieldNames["jwt_features"] = {}

    // all the data
    rows: [dynamic]map[string]string

    // process line-by-line
	for r, NR in records[1:] {
        //fmt.printfln("Record %d, %v", NR, r)
        result: map[string]string
        // unpack the two columns of log records, ie timestamp,message e.g. # 1768188872111,"Jan 12 03:34:31 ip-10-1-147-121 search[5528]: {""appName"" . . .
        // add the first column event_timestamp
        result["event_timestamp"] = r[0]

        // split message into two halves
        tok := strings.split(r[1], " ")
        fields: map[string]string = make(map[string]string)
        eventData := strings.join(tok[5:], " ")

        // the message part, parse and return
        event := unpackEvent(eventData)

        // accumulate field names and values
        for k, v in event {
            key := strings.concatenate({"event_" , k})
            fieldNames[key] = {}
            result[key] = v
        }
        // extract the parameters from the path
        params := result["event_path"]
        paramsDecoded := net.percent_decode(params) or_else params
        unidecoded, _ := strings.replace_all(paramsDecoded, "\u0026", "&")
        paramFields := unpackParams(unidecoded)
        for k, v in paramFields {
            key := strings.concatenate({"param_", k})
            fieldNames[key] = {}
            result[key] = v
        }

        // extract the JWT fields
        jwToken := strings.clone(result["param_jwToken"])
        // fmt.eprintf("NR: %d >%s<\n", NR, jwToken)
        jwtFields, jwtRaw, err := unpackJWT(NR, jwToken)
        result["jwt_raw"] = jwtRaw
        if err != nil && err != unpackErrorKind.EmptyToken {
            fmt.eprintf("%d error decoding JWT %v %s\n", NR, err, jwtRaw)
            append(&rows, result)
            continue
        }
        else {
            for k, v in jwtFields {
                //fmt.printf("NR: %d %s %s\n", NR, k, v)
                key := strings.concatenate({"jwt_", k})
                fieldNames[key] = {}
                result[key] = v
            }
        }
        // decode jwt features
        if ft, ok := strconv.parse_uint(result["jwt_feat"]); ok {
            result["jwt_features"] = feat.featuresToPips(u64(ft), ",")
        }
        // save the unpacked data
        append(&rows, result)
    }
    // sort the column names
    columnNames: [dynamic]string
    for key, _ in fieldNames {
        append_elem(&columnNames, key)
    }
    slice.sort(columnNames[:])
    // print header line
    fmt.println(strings.join(columnNames[:] , "\t"))

    // print each row
    for R, NR in rows {
        columns: for col, NF in columnNames {
            if !(col in R) {
                fmt.printf("\t")
                continue columns
            }
            //fmt.eprintf("%d %d %s %v\n", NR, NF, col, R[col])
            fmt.printf("%s", R[col])
            if NF != len(columnNames)-1{
                fmt.printf("\t")
            }
        }
        fmt.println()
    }
}

unpackEvent ::proc(message: string) -> map[string]string {
    // TODO ? remove unwanted characters
    //        msg_no_quote, _ := strings.replace_all(message, "\\\"",  "\"")
    //        msg_no_cr, _ := strings.replace_all(msg_no_quote, "\n", " ")
    result := make(map[string]string)
    // parse the JSON
    v, err := json.parse(transmute([]u8)message)
    if err != nil {
        panic(fmt.tprintf("%v",err))
    }
    // unpack
    topMap := v.(json.Object)
    for k, v in topMap {
        str := jsonAtomToString(v)
        result[k] = str
    }
    return result
}

unpackParams::proc(path: string) -> map[string]string {
    result: map[string]string
    ptok := strings.split(path, "?")
    if len(ptok) < 2 {
        return result
    }
    ps := strings.split(ptok[1], "&")
    for p in ps {
        kv := strings.split(p, "=")
        if len(kv) > 1  {
            key := kv[0]
            value := strings.join(kv[1:], "=") // TODO filter %3C etc
            result[key] = value
        }
    }
    return result
}

unpackErrorKind :: enum {
    EmptyToken,
    BadJSON,
    UnknownJSONstructure
}

unpackError :: union {
    jwt.JWTError,
    unpackErrorKind,
    json.Error
}

unpackJWT::proc(NR: int, jwToken: string) -> (res: map[string]string, raw: string, err: unpackError) {
    result: map[string]string
    if len(jwToken) == 0 {
        //fmt.eprintf("%d empty jwToken\n", NR)
        return nil, raw, unpackErrorKind.EmptyToken
    }
    raw = jwt.decode(jwToken) or_return
    if hasBadJSON(raw) {
        return nil, raw, unpackErrorKind.BadJSON
    }
    jwtFields := json.parse(transmute([]u8)raw) or_return
    jsonBranches(jwtFields, &result)
    return result, raw, nil
}
hasBadJSON :: proc(s: string) -> bool {
    for b in s {
        if b < 0x20 {
            return true
        }
    }
    return false
}

jsonBranches :: proc(tree: json.Value, result: ^map[string]string)  {
    #partial switch v in tree {
        case json.Object:
            for k in v {
                if k == "payload" {
                    p := v[k].(json.Object)
                    for pk, pv in p {
                        result[pk] = jsonAtomToString(pv)
                    }
                }
            }
        case:
    }
}
jsonAtomToString :: proc(tree: json.Value) -> (string) {

    #partial switch v in tree {
        case json.Array:
            tmp: [dynamic]string
            for x, i in v {
                append_elem(&tmp, jsonAtomToString(x))
            }
            return strings.join(tmp[:], ",")
        case json.Float:
            return fmt.tprintf("%d", int(v))
        case i64:
            return fmt.tprintf("%d", v)
        case bool, string:
            return fmt.tprintf("%v", v)
        case json.Null:
            return fmt.tprintf("null")
    }
    return fmt.tprintf("unsupported type %v", tree)
}
