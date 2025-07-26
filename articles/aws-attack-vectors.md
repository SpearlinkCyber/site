---
layout: page
title: "IAM Hacking AWS: Multi-Cloud Attack Vectors"
description: "Practical demonstration of AWS privilege escalation paths using real-world misconfigurations and IAM vulnerabilities through AWSGoat lab environment."
---

![chillin_on_a_cloud]({{ '/assets/img/posts/aws-attack-vectors/chillin_on_a_cloud.jpg' | relative_url }})

After identifying a knowledge gap in pentesting AWS (and cloud in general), I decided to spin up and attack [AWSGoat](https://github.com/ine-labs/AWSGoat) which is an intentionally vulnerable AWS lab environment with multiple paths to privilege escalation.   

I learnt a ton about IAM and how to attack it and, more importantly, had an absolute blast. So much in fact, that I have decided to make this a 3-part series to include [AzureGoat](https://github.com/ine-labs/AzureGoat) and [GCPGoat](https://github.com/ine-labs/GCPGoat).  


## Discovering the Application

Once we successfully deploy our environment via terraform, we will have access to the application URL, and navigating here shows a blog website.  

![blog_landing_page]({{ '/assets/img/posts/aws-attack-vectors/Blog_landing_page.jpg' | relative_url }})

We do not have any credentials at this stage, there is however, a sign up feature that allows us to create our own account to gain access to a dashboard where we can create new blog posts.  

![register]({{ '/assets/img/posts/aws-attack-vectors/Sign_up.jpg' | relative_url }})  
![new_post]({{ '/assets/img/posts/aws-attack-vectors/newpost.jpg' | relative_url }})  

The first thing that jumps out at us is the file upload feature, and to be more precise, the fact that we can upload via a url. This indicates that either the server will be embedding a link to the image on the blog, or retrieving the data at the specified URL and storing it somewhere. Hopefully it is the later, as this will present a clear vector for SSRF.  

![file_upload_feature]({{ '/assets/img/posts/aws-attack-vectors/fileupload.jpg' | relative_url }})  

So to test this, we feed it a page containing an image, and view the response in burp to better understand the application logic:

![retrieved_data_stored_on_s3]({{ '/assets/img/posts/aws-attack-vectors/upload_url_feature.jpg' | relative_url }})  

We visit the returned s3 link to confirm it contains the original linked image and lo and behold, the best case scenario is true, and we are able to make requests in some capacity within the context of the server (aka Server Side Request Forgery, an often overlooked vulnerability)  

![CATE]({{ '/assets/img/posts/aws-attack-vectors/kitten_image.jpg' | relative_url }})  

## Getting a Foothold

The most obvious step from here is to attempt a metadata v1 attack, where we trick the underlying EC2 instance to hit the AWS metadata endpoint to retrieve privileged information.

![ssrf_v1_attempt]({{ '/assets/img/posts/aws-attack-vectors/ssrf_v1_attempt.jpg' | relative_url }})  

This however does not work and returns a server error immediately. Further testing revealed that the application required a `200` response to be successful. This indicates either that metadata v2 was in use which requires more sophisticated techniques, or, that the webapp may be running on lambda.  

After trying a few different approaches, I discovered an LFI (local file inclusion) escalation which allowed for the retrieval of files within the ephemeral environment.  
As a common way to feed credentials to lambda functions is via environment variables, we attempt to continue our chain of attacks by retrieving a copy of `/proc/self/environ` (although the environment that runs the Lambda functions is ephemeral, the credentials remain valid for a period of time)  

![ssrf_4_real]({{ '/assets/img/posts/aws-attack-vectors/SSRF.JPG' | relative_url }})  

We download the stored file on the S3 bucket and `cat` the contents, revealing the AWS secrets of the role running the application:  

![ssrf_loot]({{ '/assets/img/posts/aws-attack-vectors/SSRF_LOOT.JPG' | relative_url }})  

We store these secrets in our environment variables for our terminal session and successfully make a call to AWS:  

![stolen_key_auth_success]({{ '/assets/img/posts/aws-attack-vectors/stolen_key_auth_success.jpg' | relative_url }})  

Unfortunately from here however, we discover the account does not have IAM list privileges after trying to list policies. I even tried to enumerate with an AWS exploit tool called [PACU](https://github.com/RhinoSecurityLabs/pacu) to see if I was missing anything, it was however a dead-end on the IAM front. When this happened I said "IAM disappointed"  

![dissapointed]({{ '/assets/img/posts/aws-attack-vectors/dissapointed.gif' | relative_url }})  
![list_policy_fail]({{ '/assets/img/posts/aws-attack-vectors/list_policy_fail.jpg' | relative_url }})  
![pacu_IAM_enum_fail]({{ '/assets/img/posts/aws-attack-vectors/pacu_iam_enum_fail.jpg' | relative_url }})  

## Exploring S3

We know that our file is being stored on the production S3 bucket, so we run `aws s3api list-buckets` to see what other buckets there are and how much access we have. After revealing a potentially interesting bucket, we attempt to list the objects and find some rather interesting files. It appears that this bucket has been used to store sensitive information pertaining to users accessing the AWS environment via SSH.

![s3_list-buckets]({{ '/assets/img/posts/aws-attack-vectors/s3_enum_dev_bucket.jpg' | relative_url }})  
![s3_list_objects]({{ '/assets/img/posts/aws-attack-vectors/s3_list_objects_loot.jpg' | relative_url }})  

Although we were unable to enumerate our own level of permissions, we can determine we have a high level of access to the `S3` service as not only can we list these objects, but we can access and download them as well.

![s3_download_objects]({{ '/assets/img/posts/aws-attack-vectors/s3_download_loot.jpg' | relative_url }})
![s3_stolen_config]({{ '/assets/img/posts/aws-attack-vectors/ssh_config.jpg' | relative_url }})

The stolen information in the exposed bucket allow us to SSH straight into an EC2 instance which did not have proper [rules for inbound traffic](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/authorizing-access-to-an-instance.html) setup.  

![ssh_successful]({{ '/assets/img/posts/aws-attack-vectors/ssh_successful.jpg' | relative_url }})

## Reviewing IAM

A quick explanation of why we run `aws sts get-caller-identity` followed by `aws iam list-attached-role-policies --role-name AWS_GOAT_ROLE` after connecting via `ssh` is as follows: First, `sts get-caller-identity`, allows us to discover which credentials are being used to call `aws` operations, we can determine the specifics of what we are dealing with by matching the output against the `IAM` `ARN` syntaxes from the [AWS reference page](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html)

SO after looking at this, we know that the _assumed role_ syntax is as below, and that the rolename must be `AWS_GOAT_ROLE`, as the _role-session-name_ is simply used [uniquely identify](https://docs.aws.amazon.com/cli/latest/reference/sts/assume-role.html#:~:text=Use%20the%20role%20session%20name,account%20that%20owns%20the%20role.) a session when the role is assumed.

![ssh_succesful]({{ '/assets/img/posts/aws-attack-vectors/understanding_output_of_getcalleridentity.jpg' | relative_url }})  

Running `aws iam list-attached-role-policies --role-name AWS_GOAT_ROLE` will return the names and ARNs of the managed policies attached to the IAM role, which in this case as we have determined, is `AWS_GOAT_ROLE`. Think of this as kind of like enumerating which Active Directory groups a user is a member of.    

We retrieve the policy document for the `dev-ec2-lambda-policies` policy which will show us the actions the policy allows us to perform and which resources we can perform them against. Note we specified the version in our command, this can be retrieved with `aws iam get-policy --policy-arn`

![dev-ec2-lambda-policies]({{ '/assets/img/posts/aws-attack-vectors/dev-ec2-lambda-policies.jpg' | relative_url }})

So reviewing the above output we can see that this policy has access to attach policies to other roles, this is granted by the `iam:AttachRolePolcy` action.  
The resource it can perform this action against is restricted to `blog_app_lambda_data` which just so happens to be the other role we have access to via the previously explored SSRF attack. This policy also has the `iam:CreatePolicy` action set, which presents a very interesting escalation vector - allow me to explain below:  
If we are looking at a policy right now to determine what this role can and cannot do, and through doing so we have discovered that the policy itself allows for the creation of NEW polices, and that we can attach those policies to the `blog_app_lambda_data` role which we have access to, this means that we can grant a policy allowing for ALL actions against ALL resources, so basically Administrator access without actually attaching the AWS managed `AdministratorAccess` policy, which, in a real setting would likely raise alarm bells if we were to add ourselves to it.

## Abusing Lambda to escalate privileges

### Think of Lambda as "Function as a Service", it is based on a "micro-VM" architecture called [Firecracker](https://github.com/firecracker-microvm/firecracker)

I decided to go down the route of abusing these actions via Lambda, as I thought [Cloudtrail](https://docs.aws.amazon.com/cli/latest/reference/cloudtrail/index.html) may be less likely to be configured to feed Lambda logs into [GuardDuty](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_data-sources.html) in a "real" environment (I could be way off here), nevertheless the following is a valuable exercise in understanding IAM and Lambda.  
Let's take another look at the `blog_app_lambda_data` role now that we have an account with sufficient `iam` actions to effectively enumerate.

![dev-ec2-lambda-policies]({{ '/assets/img/posts/aws-attack-vectors/lambda-data-role-policies.jpg' | relative_url }})

The `blog_app_lambda_data` role has full lambda access, meaning we can create functions. If we look back at `dev-ec2-lambda-policies` we see that `iam:PassRole` is present. The `iam:PassRole` allows for the creation of functions which will execute under the context of another role.  
With the above in mind, if the `blog_app_lambda_data` role had the same level of permissions that the `AWS_GOAT_ROLE` role did through the `dev-ec2-lambda-policies` policy, we could effectively create a lambda function that creates a new policy and attaches it to the `blog_app_lambda_data` role.  
We could then abuse the presence of `iam:PassRole` to execute a new lambda function with the `dev-ec2-lambda-policies` level of permissions.  
Luckily the `iam:AttachRolePolcy` action will allow us to simply attach the `dev-ec2-lambda-policies` policy to `blog_app_lambda_data`, we do this as below:  

![blog_app_lambda_data_attachrole]({{ '/assets/img/posts/aws-attack-vectors/blog_app_lambda_data_attachrole.jpg' | relative_url }})  

Now that we have the permissions of both policies attached to one role, let's create a malicious lambda function as below:  

![lambda_priv_esc_function]({{ '/assets/img/posts/aws-attack-vectors/lambda_priv_esc_function.jpg' | relative_url }})  

We zip the `.py` file up and create a lambda function before invoking it. Running `aws iam list-attached-role-policies --role-name blog_app_lambda_data` after doing this shows that we have successfully managed to create a new policy and attach it, all from within a lambda function.  

**IMPORTANT NOTE** _Although for the purpose of this exercise I opted to perform these actions from a local terminal with the exported secrets, best practice would be to run commands from an EC2 instance wherever possible so that it doesn't look like actions are being performed from outside AWS. so, in other words, I should have created, invoked, and deleted the function from my ssh session via exporting the secrets as was done earlier in this post_  

![lambda_priv_esc_success]({{ '/assets/img/posts/aws-attack-vectors/lambda_priv_esc_success.jpg' | relative_url }})  

Don't forget to remove the function afterwards:  

![cleanup]({{ '/assets/img/posts/aws-attack-vectors/cleanup.jpg' | relative_url }})  

We can double check the actions we can perform and the resources we can perform them against via our new policy, and as we can see, it is quite permissive (an asterisk denotes any action/resource)  

![full_perms]({{ '/assets/img/posts/aws-attack-vectors/full_perms.jpg' | relative_url }})  

So after this reading this post, you should no longer have your head in the clouds with regards to `IAM` at the very least.  

### STAY TUNED FOR THE NEXT EPISODE  
![tv]({{ '/assets/img/posts/aws-attack-vectors/adventure_time_tv.jpg' | relative_url }})  
