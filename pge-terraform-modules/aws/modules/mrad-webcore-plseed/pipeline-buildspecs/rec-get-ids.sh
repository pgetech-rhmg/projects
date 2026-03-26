#!/bin/bash

# TO TEST THIS LOCALLY
# you will need to update sync_gateway_admin to sync_gateway and add a session cookie
echo "Started collecting ids at $(date)"

# Limit is the page size
let limit=5000

# clean up output if it already exists
rm -rf out
mkdir out

SGW_URL=0

# SWAP_ENV is one of swapdev, swapqa, or swapprd
case "${ENVIRONMENT}" in
    "dev" ) SGW_URL="admin-sgw-dev.dc.pge.com"  ;;
    "qa"  ) SGW_URL="admin-sgw-qa.dc.pge.com"   ;;
    "prod" ) SGW_URL="admin-sgw-prod.dc.pge.com" ;;
    * ) echo "Unknown or bad SWAP_ENV"; exit 1 ;;
esac

# rec_curl is a recoursive function that will download all of the ids for a channel
# seq:String -> download file:Side Effect, gunzip:Side Effect
rec_curl() {
    sleep 10s
    # $since represents the sequence id. It is the location the page starts. Every document has a sequence id
    let since=$1
    # fixing active_only=truelimit=$limit will cause seeding errors. Will need to refactor
    curl -k "https://$SGW_URL/asset360/_changes?filter=sync_gateway/bychannel&channels=$CHANNEL&include_docs=false&active_only=truelimit=$limit&since=$since" -H 'Accept-Encoding:gzip,deflate' > "./out/ids-$since-$limit.json.gz"
    gunzip ./out/*.gz;

    # Get the last swq from this batch of ids. It will be used to determine exiting the recursion
    let last_seq=`cat ./out/ids-$since-$limit.json | grep last_seq | sed -e 's/\"last_seq\"\:\"//g' -e 's/\"\}//g'`;

    # Finds files smaller than 200c with names containing "id"
    # This indicates that we have hit the end of the channel
    if [ $since -eq $last_seq ]; then
        return 0;
    else
        rec_curl $last_seq;
    fi
}
rec_curl 0

echo "completed collecting ids at $(date)"
