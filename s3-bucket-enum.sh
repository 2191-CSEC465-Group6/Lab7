#!/bin/bash
RESOURCE_PREFIX="csec-465-team6"

# download an open-source wordlist for AWS s3 bucket names
curl 'https://raw.githubusercontent.com/aljazceru/s3-bucket-scanner/master/wordlist.txt' -o ./wordlist_full.txt

# since the original wordlist is > 300,000 lines long, pick 100 random lines to
# create a new, shorter wordlist
shuf -n 100 ./wordlist_full.txt > ./wordlist_short.txt

# create a public s3 bucket
PRIVATE_BUCKET = $(aws s3api create-bucket --acl public-read --bucket $RESOURCE_PREFIX-public --region us-east-1 | jq .Location | sed 's/["\/]//g')

# append name of $PRIVATE_BUCKET to wordlist.txt
echo $PRIVATE_BUCKET >> ./wordlist_short.txt

# create a private s3 bucket
PUBLIC_BUCKET = $(aws s3api create-bucket --acl private --bucket $RESOURCE_PREFIX-private --region us-east-1 | jq .Location | sed 's/["\/]//g')

# append name of $PUBLIC_BUCKET to wordlist.txt
echo $PUBLIC_BUCKET >> ./wordlist_short.txt
