#!/bin/bash
# This script enumerates AWS S3 buckets using a public wordlist along with two dynamically created
# buckets

# init - checks that specific programs are installed, checks if a local copy of wordlist_full.txt
# exists, creates a smaller subset of that list called wordlist_short.txt, and creates two new s3
# buckets and appends their names to wordlist_short.txt
init() {
    # check that needed programs are installed
    i=0; n=0; progs=(aws shuf curl sed vim jq);
    for p in "${progs[@]}"; do
        if hash "$p" &>/dev/null
        then
            let i++
        else
            echo "$p is not installed"
            let n++
        fi
    done
    # exit if any programs are missing
    if [ $n -gt 0 ]
    then
        printf "%d of %d programs were installed.\n" "$i" "${#progs[@]}"
        printf "%d of %d programs were missing.\n" "$n" "${#progs[@]}"
        exit 1
    fi

    # check if full wordlist exists and if it doesn't download it
    if [ ! -s ./wordlist_full.txt ]
    then
        echo "./wordlist_full.txt not found locally, downloading now"
        # download an open-source wordlist for AWS s3 bucket names
        WORDLIST_URL='https://raw.githubusercontent.com/aljazceru/s3-bucket-scanner/master/wordlist.txt'
        curl $WORDLIST_URL -o ./wordlist_full.txt -#
        # the first 5 lines of the wordlist are not valid s3 bucket names and will throw an error
        vim -e -s -c '1d5|x' wordlist_full.txt
    fi

    # since the original wordlist is > 300,000 lines long, pick 100 random lines to
    # create a new, shorter wordlist
    shuf -n 100 ./wordlist_full.txt > ./wordlist_short.txt

    RESOURCE_PREFIX="csec-465-team6"
    # create a public s3 bucket
    PUBLIC_BUCKET=$(aws s3api create-bucket --acl public-read --bucket $RESOURCE_PREFIX-public --region us-east-1 | jq .Location | sed 's/["\/]//g')

    # append name of $PUBLIC_BUCKET to wordlist.txt
    echo $PUBLIC_BUCKET >> ./wordlist_short.txt

    # create a private s3 bucket
    PRIVATE_BUCKET=$(aws s3api create-bucket --acl private --bucket $RESOURCE_PREFIX-private --region us-east-1 | jq .Location | sed 's/["\/]//g')

    # append name of $PRIVATE_BUCKET to wordlist.txt
    echo $PRIVATE_BUCKET >> ./wordlist_short.txt

    # create a 1MB file with random contents to upload to newly created s3 buckets
    TMPFILE=$(mktemp)
    dd if=/dev/zero of=$TMPFILE count=1024 bs=1024 1>/dev/null 2>&1

    aws s3 cp $TMPFILE s3://$PUBLIC_BUCKET/foo 1>/dev/null 2>&1
    aws s3 cp $TMPFILE s3://$PRIVATE_BUCKET/bar 1>/dev/null 2>&1
}

# check_bucket - uses aws-cli to see if given bucket name is accessible, and if so prompts user
# if they want to display contents of said bucket
check_bucket() {
    RETURN_MESSAGE=$(aws s3 ls s3://$1 2>&1 >/dev/null)
    RETURN_CODE=$?
    if [ $RETURN_CODE -eq 0 ]
    then
        echo $1 is open
        if [ -t 1 ]
        then
            # some trickery is needed to prompt for user input while in a while loop
            read -p "Would you like to view the contents? (y/n): " continue </dev/tty
            if [ "$continue" == "y" ]
            then
                echo $1 contents:
                aws s3 ls s3://$1
            fi
        fi
    elif [ $RETURN_CODE -eq 255 ]
    then
        if [[ $RETURN_MESSAGE =~ "InvalidBucketName" ]]
        then
            echo $1 is not a valid bucket name
        elif [[ $RETURN_MESSAGE =~ "NoSuchBucket" ]]
        then
            echo $1 does not exist
        elif [[ $RETURN_MESSAGE =~ "AccessDenied" ]]
        then
            echo $1 is not open
        elif [[ $RETURN_MESSAGE =~ "AllAccessDisabled" ]]
        then
            echo $1 has all access disabled
        else
            echo $1: $RETURN_MESSAGE
        fi
    else
        echo Unknown error
    fi
}

# finish - exit trap function that removes wordlist_short.txt and the two dynamically created
# s3 buckets
finish() {
    rm -f ./wordlist_short.txt 1>/dev/null 2>&1
    rm -f $TMPFILE 1>/dev/null 2>&1
    aws s3 rb s3://$PRIVATE_BUCKET --force 1>/dev/null 2>&1
    aws s3 rb s3://$PUBLIC_BUCKET --force 1>/dev/null 2>&1
    exit
}
trap finish EXIT

init

while IFS= read -r line
do
    check_bucket $line
done < ./wordlist_short.txt