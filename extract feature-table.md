# Extract feature bits from streamco-api-auth

For scripting purposes. Extract from the source:

```
cd /Users/birchb/go/src/github.com/streamco/streamco-api-auth
tr $'\t' ' ' <features.go | gawk -F ' *' '/Feature[A-Za-z0-9]+ +Features += +1 +<< +[0-9]+/{print $2,$7}' >> index.txt
tr $'\t' ' ' <features.go | gawk -F ' *' '/^ +Feature[A-Za-z0-9]+ += *1 +<< +[0-9]+/{print $2, $NF}' >> index.txt 
sort -k 2 -n <index.txt | pbcopy
```

Then paste into features.g and add header manually:
```
var feature-table
  data
    FeatureOffline = 0
```

