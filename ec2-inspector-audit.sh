#!/bin/bash

# Create EC2 instance running Ubuntu
aws ec2 run-instances --image-id ami-04b9e92b5572fa0d1 --count 1 --instance-type t2.micro