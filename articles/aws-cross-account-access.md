---
layout: page
title: "Cross-Account Database Access via VPC Peering and IAM"
description: "Achieving cross-account database access through VPC peering and IAM configuration for enterprise multi-account AWS architectures."
---

![Cross-Account_Access]({{ '/assets/img/posts/aws-cross-account/cross_account_trust.png' | relative_url }})

I know this is not the normal subject matter for my blog - however I was recently faced with an interesting challenge at work, and I identified a few knowledge gaps in AWS regarding RDS and cross account access and thus after a few beers with my [hackin homie](https://onecloudemoji.github.io/) an idea for a blog no one asked for and no one needs was once again incepted.

## BUT WHY

Basically, one account has a database in Amazon [RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html), and the other account needs to access it via a lambda for marketing information.  
It sounds like this should be straight forward, however cross-account RDS access in AWS can be tricky due to AWS's built-in security between accounts. The need for cross account access often comes up when you have different AWS accounts for dev and prod or when you need to share database resources between different teams or third-party vendors.
To enable interactions between RDS instances across AWS accounts, it's necessary to configure specific trust relationships, permissions, and networking routes.
This setup ensures that cross-account interactions are both controlled and in line with the [principle of least privilege (PoLP)](https://en.wikipedia.org/wiki/Principle_of_least_privilege).


## Account Setup

We start by creating two user accounts, `aws_dev_account` (under account *2974) and `aws_engineering_account` (under account *5884). The first account, `aws_dev_account`, has the following policies attached:

- **AmazonRDSFullAccess**: Grants full access to Amazon RDS, necessary for managing RDS instances where our data resides.
- **AmazonVPCFullAccess**: Essential for setting up VPC peering to allow connectivity between the two AWS accounts.
- **IAMFullAccess**: Allows for the creation and management of IAM roles and policies, crucial for setting up cross-account access.
- **SecretsManagerReadWrite**: Allows for the creation and management of database secrets in AWS Secrets Manager.

The second account, `aws_engineering_account`, has the following policies attached:

- **CrossAccountRDSAccessRole_ougoing**: This custom policy, grants scoped permissions to assume the cross-account role, enabling access to a resource in `aws_dev_account`.
- **AmazonVPCFullAccess**: Essential for setting up VPC peering to allow connectivity between the two AWS accounts.


## Cross Account Role Creation:

Creating a cross-account role is a crucial step to allow different account development and engineering accounts. This role will specifically enable the engineering team to access the RDS instance in the development account while adhering to AWS's principle of least privilege (PoLP).

Login to `aws_dev_account`, `navigate to IAM Dashboard` > `Roles` > `Create role`.
Select `Another AWS account` under the `Select trusted entity` section and enter the account ID of `aws_engineering_account`.

![create_crossaccountrdsaccessrole]({{ '/assets/img/posts/aws-cross-account/create_crossaccountrdsaccessrole.png' | relative_url }})

Edit the trust policy to restrict access to the specified account only.

![select_trusted_entity]({{ '/assets/img/posts/aws-cross-account/select_trusted_entity.png' | relative_url }})


Create a custom policy in aws_engineering_account to allow assuming the CrossAccountRDSAccessRole, and attach it to the engineering user.
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::xxxxxxx5884:user/aws_engineering_account"
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
        }
    ]
}
```

![edit_trust_policy]({{ '/assets/img/posts/aws-cross-account/edit_trust_policy.png' | relative_url }})

Now, log in as the admin in `aws_engineering_account`, create a custom policy to allow this account to assume the `CrossAccountRDSAccessRole` role, and attach it to the engineering user.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::xxxxxx2974:role/CrossAccountRDSAccessRole"
        }
    ]
}
```
![specify_assumerole_perms]({{ '/assets/img/posts/aws-cross-account/specify_assumerole_perms.png' | relative_url }})


## VPC Peering

### First, WHAT is a VPC?

A [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) (Virtual Private Cloud) is essentially an isolated section of AWS wherein your AWS infrastructure resides. 
When you create a new AWS account, AWS automatically sets up a default VPC for you in each region. This default VPC is configured with certain settings to simplify things, such as internet routing, connectivity between other hosts on the VPC etc.
It does not however communicate between VPCs in other regions and accounts out of the box, and this must be setup manually, the methodology behind how one sets this up is dependent on your use case and potentially org size, etc.
These methods are below - while these all practically achieve the same thing, it is worth noting that regardless of which one is used, for the purpose of accessing resources in an authorized context, we must still setup up cross-account IAM roles.

[VPC Peering](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-peering.html): Ideal for smaller-scale scenarios where direct, low-latency communication is needed between two VPCs within the same organization, like linking a development VPC with an engineering VPC :smirk:.  
[AWS Transit Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/extend-tgw.html): Best suited for large organizations with numerous VPCs and complex networking needs, where centralized management and simplified connectivity are crucial.  
[VPN Connection](https://docs.aws.amazon.com/vpc/latest/userguide/vpn-connections.html): Appropriate for scenarios requiring secure, encrypted connections between a VPC and remote networks, such as connecting a corporate office network to a VPC in AWS.  
[AWS Direct Connect](https://aws.amazon.com/directconnect/): Recommended for scenarios demanding high-throughput, consistent network performance, or when handling sensitive data, like connecting an on-premises data center to AWS infrastructure.  

### VPC Peering Setup 

Initiate VPC peering by navigating to: `VPC Dashboard` > `Peering Connections` > `Create peering connection` in either account. Fill out the details and select the VPC that your RDS is hosted on. Once done, log into the other account, go to `VPC Dashboard` > `Peering Connections` to accept the connection request. Update the route tables in both accounts to allow traffic flow: `VPC Dashboard` > `Route Tables` > select the route table associated with your requester VPC, and add a route to the peering connection.

![create_peering]({{ '/assets/img/posts/aws-cross-account/create_peering.png' | relative_url }})

![vpc_peering_requested]({{ '/assets/img/posts/aws-cross-account/vpc_peering_requested.png' | relative_url }})

![accept_peering_request]({{ '/assets/img/posts/aws-cross-account/accept_peering_request.png' | relative_url }})


## Security Group Configuration

Ensure a security group allows inbound traffic from the originating VPC CIDR block. Navigate to: `VPC Dashboard` > `Security Groups` > `Create Security Group`, and specify the inbound rules to allow traffic from the other VPC.

## Secrets Manager Setup

In `aws_dev_account`, create a secret in AWS Secrets Manager to store the database credentials. During secret creation, at the *Resource permissions* step, specify that the `CrossAccountRDSAccessRole` can access the secret.

![setup_secrets_manager]({{ '/assets/img/posts/aws-cross-account/setup_secrets_manager.png' | relative_url }})
![blog_secret_resource_permissions]({{ '/assets/img/posts/aws-cross-account/blog_secret_resource_permissions.png' | relative_url }})

```json
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : "arn:aws:iam::aws_dev_account:role/CrossAccountRDSAccessRole"
    },
    "Action" : "secretsmanager:GetSecretValue",
    "Resource" : "arn:aws:secretsmanager:us-east-1:aws_dev_account:secret:db-credentials"
  } ]
}
```


![specify_perms_secretmanager]({{ '/assets/img/posts/aws-cross-account/specify_perms_secretmanager.png' | relative_url }})


## Role Assumption and Data Retrieval

In an `ec2` instance (under account *5884) as the `aws_engineering_account` user, assume the cross-account role using the following one-liner:

```bash
eval $(aws sts assume-role --role-arn arn:aws:iam::aws_dev_account:role/CrossAccountRDSAccessRole --role-session-name cross-role-assumption --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text | awk '{print "aws configure set aws_access_key_id "$1"; aws configure set aws_secret_access_key "$2"; aws configure set aws_session_token "$3";"}')
```
![assumerole_evidence]({{ '/assets/img/posts/aws-cross-account/assumerole_evidence.png' | relative_url }})

Create and run Python scripts to fetch data from the RDS instance (we are emulating a [lambda](https://aws.amazon.com/lambda/) by doing this). Below is a script to retrieve vegetables data:

```python
import mysql.connector
import boto3
import json
import logging
from decimal import Decimal

# Set up logging to stdout for script, disable logging for boto
logging.basicConfig(level=logging.ERROR, handlers=[logging.StreamHandler()])
logging.getLogger('boto3').setLevel(logging.ERROR)
logging.getLogger('botocore').setLevel(logging.ERROR)

# Custom serialization function to handle Decimal values
def default(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError("Object of type '%s' is not JSON serializable" % type(obj).__name__)

def main():
    try:
        # Get credentials from Secrets Manager
        secrets_client = boto3.client('secretsmanager', region_name='us-east-1')
        secret_value_response = secrets_client.get_secret_value(
            SecretId='arn:aws:secretsmanager:us-east-1:xxxxxx2974:secret:blog/read-veggies'
        )
        db_credentials = json.loads(secret_value_response['SecretString'])

        # Database credentials
        db_username = db_credentials['username']
        db_password = db_credentials['password']

        # Connect to the database
        conn = mysql.connector.connect(
            host='fruit-n-veg-db.xxxxxxx.us-east-1.rds.amazonaws.com',
            user=db_username,
            password=db_password,
            database='fruits_veggies'
        )

        # Execute SQL query
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM vegetables;")
        result = cursor.fetchall()

        # Print the response in JSON format
        result_json = [dict(zip(cursor.column_names, row)) for row in result]
        print(json.dumps(result_json, indent=2, default=default))

    except Exception as e:
        print(f'Error: {e}')

    finally:
        # Close the database connection
        conn.close()

if __name__ == "__main__":
    main()
```  

![lambda success evidence]({{ '/assets/img/posts/aws-cross-account/lambda_success_evidence.png' | relative_url }})

As we can see above, we have successfully emulated lambda execution by running this data-retrieval script from a VPC in a separate account from where the database resides. The VPC peering allows our traffic to flow between these segregated VPC's. and our cross-account IAM role allows us to authorise to the secrets manager for the purpose of authenticating to the db.

### Closing Summary

All in all this was a really fun and educational little project - I hope you enjoyed and perhaps some of you may reference this for an actual project, if so please inform me so that I know I am not always simply void-posting these blogs posts :sweat_smile:


![Flexin on tha Cloud]({{ '/assets/img/posts/aws-cross-account/cloud_masta.png' | relative_url }})
