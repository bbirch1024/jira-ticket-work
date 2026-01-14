#!/bin/bash

set -euo pipefail
set -x

cd cloudwatch
./cloud-watch-logs.g search.userID.eq.1.csv > search.userID.eq.1.tsv
./cloud-watch-logs.g search.userID.eq.1.vendor.neq.2.csv > search.userID.eq.1.vendor.neq.2.tsv

