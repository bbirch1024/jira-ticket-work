package cloudwatchlog

import "core:encoding/csv"
import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
//import jwt "../  whatever /jwt/jwtdecode"
main :: proc() {

    //
    if len(os.args) < 2 {
        panic("missing filename")
    }
    filename := os.args[1]

    //  read in the input CVS file TODO proc
	r: csv.Reader
	r.trim_leading_space  = true
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
    // all the data
    rows: [dynamic]map[string]string

    // process line-by-line
	for r, NR in records[1:] {
        //fmt.printfln("Record %d, %v", NR, r)
        result: map[string]string
        // unpack the two columns of log records, ie timestamp,message e.g. # 1768188872111,"Jan 12 03:34:31 ip-10-1-147-121 search[5528]: {""appName"" . . .
        // add the first column event_timestamp
        result["event_timestamp"] = r[0]
        fieldNames["event_timestamp"] = {}

        // split message into two halves
        tok := strings.split(r[1], " ")
        fields: map[string]string = make(map[string]string)
        eventData := strings.join(tok[5:], " ")

        // the message part, parse and return
        unpackEvent(eventData)

//        // accumulate field names and values
//        for k, v in event {
//            key := "event_" + k
//            fieldNames[key] = struct{}
//            result[key] = v
//        }
//        // extract the param fields
//        params, ok := result["event_params"]
//        if paramFields, ok := unpackParams(params); ok {
//            for k, v in paramFields {
//                key := "param_" + k
//                fieldNames[key] = struct{}
//                result[key] = v
//            }
//        }
//
//        // extract the JWT fields
//        jwToken := params["jwToken"]
//        if jwToken != "" {
//            if jwtFields, ok := jwt.decode(jwToken); ok {
//                for k, v in jwtFields {
//                    key := "jwt_" + k
//                    paramFields[key] = struct{}
//                    result[key] = v
//                }
//
//            }
//        }
//// TODO        // extract the rec JWT fields
////        if jwtFields, ok := decodeJWT(jwToken); ok {
////         . . .
////        }
        // save the unpacked data
        append(&rows, result)
//
//    }
//
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
    for R in rows {
        columns: for col, NF in columnNames {
            if !(col in R) {
                fmt.printf("\t")
                continue columns
            }
            fmt.printf("\"%s\"", R[col])
            if NF != len(columnNames)-1{
                fmt.printf("\t")
            }
        }
        fmt.println()
    }
}

unpackEvent ::proc(message: string) { // -> (params: map[string]string ){
        // remove unwanted characters
//        msg_no_quote, _ := strings.replace_all(message, "\\\"",  "\"")
//        msg_no_cr, _ := strings.replace_all(msg_no_quote, "\n", " ")
        // parse the JSON
        v, err := json.parse(transmute([]u8)message)
        fmt.printf("%#v", v)
//        var js (msg-no-cr(.fromJSON))
//        // divvy up . .
//            // ignore curl user agent records
//                cond
//                    (js!user_agent_raw(.match '.*curl.*'))
//            // get the 'params' field and upack it
//
//                        var X (js!path(.split '[&?]'))
//                        for P in X
//                            params(.put ^param ^path X!left)
//                            var sp (P(.split '='))
//            #                #print sp
//                            cond
//                                (equal? 2 (length sp))
//                                    var value (filter sp)
//                                    params(.put ^param (intern sp!left) value)
//
//
//    return v
}