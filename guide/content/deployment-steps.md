---
weight: 8
title: Deployment steps
description: Deployment steps.
---

## Option 1: Launch the CloudFormation template in the AWS Organizations management account {#launch-cfn}


1. Download the [CloudFormation template](https://raw.githubusercontent.com/aws-ia/cfn-abi-crowdstrike-fcs/main/templates/crowdstrike_init_stack.yaml).
2. Launch the CloudFormation template in your [AWS Control Tower home Region](https://docs.aws.amazon.com/controltower/latest/userguide/region-how.html).
    * Stack name: `template-crowdstrike-enable-integrations`
    * Update the follwoing parameters as needed:
        * Account Type  
        **Note:** if `Falcon Account Type` = `govcloud` and `AWS Account Type` = `commercial`, then you must launch this solution in `us-east-1`
            * **Falcon Account Type**: Your Falcon Cloud type.  Allowed values include `commercial` or `govcloud`
            * **AWS Account Type**: Your AWS Cloud type.  Allowed values include `commercial` or `govcloud`
        * Permissions Boundary
            * **Permissions Boundary Policy Name**: If your Organization requires a PermissionsBoundary policy applied to IAM Roles, enter the **Name** (not the ARN) of your Permissions Boundary policy
        * CrowdStrike Falcon API Key
            * **Falcon API Client ID**: Your CrowdStrike Falcon API Client ID
            * **Falcon API Secret**: Your CrowdStrike Falcon API Client Secret
            * **CrowdStrike Cloud**: Your Falcon Cloud region.  Allowed values include: `us1`, `us2`, `eu1`, `usgov1`, `usgov2`
            * **Secrets Manager Secret Name**: Name of the Secrets Manager Secret that will store the Falcon API Credentials.
        * Configure Indicator of Attack Scanning
            * **Enable IOA Scanning**: Whether to enable IOA Scanning.  Allowed vlaues include `true` or `false`.  Default is `true`
            * **StackSet Administration Role**: Name of StackSet Administration role.  Default is `AWSCloudFormationStackSetAdministrationRole`
            * **StackSet Execution Role**: Name of StackSet Execution role.  Default is `AWSCloudFormationStackSetExecutionRole`
            * **Create Optional Organization CloudTrail**: Whether to create an additional CLoudTrail to enable ReadOnly IOAs.  Allowed values include `true` or `false`. The default is `false`
            * **Exclude Prohibited Regions**: List of regions to exclude from deployment. Use this when SCPs cause stacksets to fail.  Eg. `[<region-1>,<region-2>,....]`
        * Provision OUs
            * **The Organization Root ID or Organizational Unit (OU) IDs to Provision**: Comma Delimited List of AWS OU(s) to provision. If you are provisioning the entire organization, please enter the Root OU `r-******`
        * Deploy Falcon Sensors with SSM Distributor
            * **EnableSSMDistributor**: Whether to deploy SSM Associations in each AWS Region to automatically deploy the CrowdStrike Distributor Package against SSM-Managed Ec2 Instances. Allowed values include `true` or `false`. The default is `false`
            * **SSM Execution Role**: If EnableSSMDistributor is `true`: Define the name of the SSM Automation Execution Role. The default is `crowdstrike-distributor-deploy-role`
            * **Apply Only At Cron Interval**: If EnableSSMDistributor is `true`: Whether to wait for cron interval to initiate SSM Distributor installation.  Allowed values include `true` or `false`. The default is `false`
            * **Cron Schedule Expression**: If EnableSSMDistributor is `true`: Define the schedule or rate by which the SSM Automation runs. The default is `cron(0 0 */1 * * ? *)` (runs every hour)
            * **Max Errors Allowed**: If EnableSSMDistributor is `true`: The number or percent of errors that are allowed before the system stops sending requests to run the association on additional targets. The default is `10%`
            * **Max Concurrency Allowed**: If EnableSSMDistributor is `true`: The maximum number or percent of targets allowed to run the association at the same time. The default is `20%`
        * Sensor Management
            * **Enable Sensor Management**
            * **API Credentials Storage Mode**
    
    * Use the default values for the following parameters:
        * AWS S3 Bucket
            * **Source S3 Bucket Name**
            * **S3 Bucket Region**
            * **Source S3 Bucket Name Prefix**
        * AWS Organization ID - Lambda Function Properties
            * **AWS Organization ID - Lambda Role Name**
            * **AWS Organization ID - Lambda Function Name**
        * Advanced Configuration Properties
            * **pControlTower**
            * **pGovernedRegions**
            * **pSecurityAccountId**
            * **pLogArchiveAccountId**

3. Select both of the following capabilities and choose **Submit** to launch the stack.

    [] I acknowledge that AWS CloudFormation might create IAM resources with custom names.

    [] I acknowledge that AWS CloudFormation might require the following capability: CAPABILITY_AUTO_EXPAND

Wait for the CloudFormation status to change to `CREATE_COMPLETE` state.


## Option 2: Launch using Customizations for Control Tower {#launch-cfct}


[Customizations for AWS Control Tower](https://aws.amazon.com/solutions/implementations/customizations-for-aws-control-tower/) (CfCT) combines AWS Control Tower and other AWS services to help you set up an AWS environment. You can deploy the templates provided with the ABI solution using CfCT.

#### Prerequisites

Create an IAM role with the required permissions in the AWS management account to allow the CfCT solution to launch resources.

#### How it works

To deploy the sample partner integration page, add the following blurb to the `manifest.yaml` file from your CfCT solution and update the account and organizational unit (OU) names as needed.

```yaml
resources:
  - name: deploy-crowdstrike-init-stack
    resource_file: https://aws-abi.s3.us-east-1.amazonaws.com/cfn-abi-crowdstrike-fcs/templates/crowdstrike_init_stack.yaml
    deploy_method: stack_set
    parameters:
      - parameter_key: FalconClientID
        parameter_value: $[alfred_ssm_/crowdstrike/falcon_client_id] # Create SSM parameter with the CrowdStrike API client ID
      - parameter_key: FalconSecret
        parameter_value: $[alfred_ssm_/crowdstrike/falcon_secret] # Create SSM parameter with the CrowdStrike API secret
      - parameter_key: ProvisionOU
        parameter_value: $[alfred_ssm_/crowdstrike/provision-ou] # Create SSM parameter with the OU name
      - parameter_key: ExcludeRegions
        parameter_value: $[alfred_ssm_/crowdstrike/exclude_regions] # Create SSM parameter with regions to exclude
      - parameter_key: SourceS3BucketName
        parameter_value: aws-abi
      - parameter_key: S3BucketRegion
        parameter_value: us-east-1 # Update as needed
      - parameter_key: CreateOrgTrail
        parameter_value: "true" # Update as needed. Set to "false" if you already have an organization trail.
    regions:
      - us-east-1 # Update as needed
    deployment_targets:
      accounts:
        - [[MANAGEMENT-AWS-ACCOUNT-ID]]
```


**Next:** Choose [Post deployment options](/post-deployment-steps/index.html).