#!/bin/bash
RESOURCE_PREFIX="csec-465-team6"

# create a public s3 bucket
aws s3api create-bucket --acl public-read --bucket $RESOURCE_PREFIX-public --region us-east-1

# create a private s3 bucket
aws s3api create-bucket --acl private --bucket $RESOURCE_PREFIX-private --region us-east-1