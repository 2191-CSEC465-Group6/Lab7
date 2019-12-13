# Lab7

## setup
In order to run these scripts, you need to set up authentication credentials. Credentials for your AWS account can be found in the [IAM Console](https://console.aws.amazon.com/iam/home). You can create or use an existing user or follow the instructions below to setup a new user.

### IAM user
Create a [new IAM user](https://console.aws.amazon.com/iam/home#/users$new?step=details), give it a user name, and select **Programmatic access** for the access type.
![IAM_add_user](screenshots/IAM_add_user.png)

To see your new access key, choose **Show**. Your credentials will look something like this:

    Access key ID: AKIAIOSFODNN7EXAMPLE
    Secret access key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

To download the key pair, choose **Download .csv file**. Store the keys in a secure location.
![IAM_user_accessKey](screenshots/IAM_user_accessKey.png)

### AWS credentials
Use the AWS CLI to configure your credentials file:

    aws configure
Alternatively, you can create the credential file yourself. By default, its location is at ~/.aws/credentials:

    [default]
    aws_access_key_id = YOUR_ACCESS_KEY
    aws_secret_access_key = YOUR_SECRET_KEY
