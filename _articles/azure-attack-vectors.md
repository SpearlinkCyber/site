---
layout: page
title: "Azuredly Attacking Azure: Cloud Privilege Escalation"
description: "Using AzureGoat to demonstrate Azure privilege escalation through automation accounts and RBAC misconfigurations in cloud environments."
---

![LeMe_LeAzure]({{ '/assets/img/posts/azure-attack-vectors/LeAzure.jpg' | relative_url }})

For the second part in our attacking cloud series, we will attack [AzureGoat](https://github.com/ine-labs/AzureGoat) which is an intentionally vulnerable Azure lab environment with multiple paths to privilege escalation. I came in here as a noob so this was pretty informative and I hope you glean some new information from this post.     

Just real quick before we get into this: I was looking for some puns to start this blog off with, however, upon looking up the definition of azure, I discovered the below:  

![where_are_they]({{ '/assets/img/posts/azure-attack-vectors/where_are_the_clouds.jpg' | relative_url }})  

Azure means clear sky and NO clouds??? Anyway, let's move on.  

## Discovering the Application

Once we successfully deploy our environment via terraform, we will have access to the application URL, and navigating here shows a blog website. This is much the same as what we did in Part 1 where we attacked AWS.  
**Note: If you are planning on running through this yourself, the easiest way is to use the Azure CLI within the Azure Web console to deploy with Terraform.**

![blog_landing_page]({{ '/assets/img/posts/azure-attack-vectors/blog.jpg' | relative_url }})

Again, we use the public sign up feature that allows us to create our own account which will expose the application to us, including a dashboard where we can create new blog posts.  

![register]({{ '/assets/img/posts/azure-attack-vectors/signup.jpg' | relative_url }})  
![new_post]({{ '/assets/img/posts/azure-attack-vectors/newpost.jpg' | relative_url }})  

After poking around and realising that the app appears to be more or less identical to what we saw on AWSGoat, we once again seek to exploit the file upload feature, as the fact we can upload a file via presenting a URL indicates that either the server will be embedding a link to the image on the blog, or retrieving the data at the specified URL and storing it somewhere. This will present a clear vector once again for SSRF.  

## Getting a Foothold

Where the attack chain differs from what we did previously against AWSGoat (we retrieved `/proc/self/environ`), is the file we retrieve. The file is `/home/site/wwwroot/local.settings.json`, which as per [Microsoft](https://learn.microsoft.com/en-us/azure/azure-functions/functions-develop-local#local-settings-file) can contain connection strings and secrets.  

![localsettings]({{ '/assets/img/posts/azure-attack-vectors/local_settings.jpg' | relative_url }}) 

As we did on the AWS version of the blog app, we abuse the `value` GET parameter to achieve an LFI via SSRF:  

![ssrf_localsettings_lfi]({{ '/assets/img/posts/azure-attack-vectors/ssrf_local_settings.jpg' | relative_url }})  

We download the stored file and `cat` the contents, revealing a connection string and secrets:  

![ssrf_localsettings_loot]({{ '/assets/img/posts/azure-attack-vectors/ssrf_local_settings_loot.jpg' | relative_url }})    

We use this connection string to access Azure storage by installing the Azure Storage extension in Visual Studio code, right clicking and selecting `Attach Storage Account`, then in the prompt for a connection string paste `"CON_STR"` value that was extracted from `/home/site/wwwroot/local.settings.json`.  

![sh_keys]({{ '/assets/img/posts/azure-attack-vectors/ssh_keys.jpg' | relative_url }})  

We use the extracted `.ssh config` and keys to ssh to an Azure endpoint.

![ssh_session]({{ '/assets/img/posts/azure-attack-vectors/ssh_as_justin.jpg' | relative_url }})  

Now that we have a foothold in the targets Azure environment, we start by seeing if we can view resources with `az resource list` which we can, we will then run `az role assignment list -g azuregoat_app` to list the role assignments that exist at a resource group scope. So, basically, we are enumerating who has access to the `azuregoat_app` resource group.  

_Azure role-based access control (Azure RBAC) is the authorization system you use to manage access to Azure resources. To determine what resources users, groups, service principals, or managed identities have access to, you list their role assignments._
Taken from: [https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-list-cli](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-list-cli)

### The first two screenshots are outputs of interest from listing resources when compared against listing role assignments, which is exhibited in the third screenshot. 

#### Screenshot 1
![resourcelist_vm]({{ '/assets/img/posts/azure-attack-vectors/get_vmname_princ_id.jpg' | relative_url }})  

#### Screenshot 2
![resourcelist_automation_account]({{ '/assets/img/posts/azure-attack-vectors/owner_princ_id.jpg' | relative_url }})   

#### Screenshot 3
![role_assignments]({{ '/assets/img/posts/azure-attack-vectors/role_assignments.jpg' | relative_url }})   

It appears an automation account has owner privileges over the entire azuregoat_app resource group.  
A brief readthrough on [Microsoft's](https://learn.microsoft.com/en-us/azure/automation/overview#process-automation) knowledge page on Automation Accounts concedes the below information:  

![automation_purpose]({{ '/assets/img/posts/azure-attack-vectors/automation_account_purpose.jpg' | relative_url }}) 

This looks like an attractive vector for any malcious actor, and we will attempt to weaponise this by creating a `PowershellwWorkflow` [runbook](https://learn.microsoft.com/en-us/azure/automation/automation-powershell-workflow) to be executed by the Automation Account, as doing so will allow us to execute commands under the context of `owner` as per the role assignments.

## Abusing Runbooks to Escalate Privileges  
Similar to how we abused Lambda in AWSGoat to escalate our privileges, we will write a Powershellworkflow and save it to the target machine as `escalation.ps1` code before creating, updating, publishing, and finally, running the runbook.  

![escalation_ps1]({{ '/assets/img/posts/azure-attack-vectors/escalation_ps1.jpg' | relative_url }})  

```
az automation runbook create --automation-account-name "dev-automation-account-appazgoatxxxxxx" -g azuregoat_app --name "dev-vm-test" --type "PowerShellWorkflow" --location "East US"
az automation runbook replace-content --automation-account-name dev-automation-account-appazgoatxxxxxx --resource-group azuregoat_app --name dev-vm-test --content @escalation.ps1
az automation runbook publish --automation-account-name dev-automation-account-appazgoatxxxxxx --resource-group azuregoat_app --name dev-vm-test
az automation runbook start --automation-account-name dev-automation-account-appazgoatxxxxxx1 --resource-group azuregoat_app --name dev-vm-test
```
![runbook_replace_publish_start]({{ '/assets/img/posts/azure-attack-vectors/runbook_replace_publish_start.jpg' | relative_url }})  


We can see that we successfuly escalated our role to `owner` over the entire `azuregoat_app` resource group by again running `az role assignment list -g azuregoat_app` and seeing that the principal id of the virtual machine (which we are executing under the context of) now has the owner role assigned.  

![escalation_success]({{ '/assets/img/posts/azure-attack-vectors/escalation_success.jpg' | relative_url }})  

_So, why is this a big deal? And why do we care that someone has just taken ownership of one our resource groups?_  

**Well, why don't we ask ChatGPT (lol)**  

Having owner-level permissions on a resource group in Azure is highly dangerous and opens up the potential for multiple attacks. With this level of access, an attacker could:

### 1. Steal or manipulate sensitive data stored in the resource group:  
Example: An attacker gains owner-level permissions on a resource group containing a database storing personal information of customers. The attacker could access and potentially exfiltrate this sensitive information, leading to a data breach.  

### 2. Modify the configuration of resources within the group, potentially leading to service disruptions or outages:  
Example: An attacker gains owner-level permissions on a resource group containing multiple virtual machines and storage accounts used for a company's e-commerce website. The attacker could modify the configuration of these resources, causing the website to become unavailable and resulting in significant downtime for the company.  

### 3. Use the resource group as a launching pad for further attacks:  
Example: An attacker gains owner-level permissions on a resource group containing a virtual machine used as a web server for a company's internal applications. The attacker could use this virtual machine as a pivot point to launch further attacks on other resources within the organization's Azure environment or on-premises network.  

### 4. Gain access to billing information, potentially allowing for unauthorized charges to be incurred:  
Example: An attacker gains owner-level permissions on a resource group associated with an Azure subscription. The attacker could access the billing information for the subscription and modify the configuration of resources within the group, increasing usage and driving up the costs associated with the subscription. This could result in unauthorized charges being incurred, potentially causing financial harm to the affected organization.  

### 5. Delete critical resources within the group, causing permanent data loss and potentially resulting in costly downtime:  
Example: An attacker gains owner-level permissions on a resource group containing critical virtual machines and storage accounts used by a company. The attacker could delete these resources, causing permanent data loss and significant downtime for the company. This could result in costly business disruption and potentially long-term damage to the organization's reputation.  

## TA-DA!! That concludes this blog post, I hope you learnt something about Azure, I sure did.

Stayyyy tuned for the final installment to this series, in the form of a runthrough of [GCPGoat](https://github.com/ine-labs/GCPGoat).  

![celebr8]({{ '/assets/img/posts/azure-attack-vectors/high_five.gif' | relative_url }})  
