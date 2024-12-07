#####################################################################
# CODESTAR CONNECTIONS
#####################################################################
variable "codestarconnections" {
  type = list(object({
    name = string
    provider_type = optional(string, null)
    host_name = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = []
  description = <<-EOT
List of CodeStar Connections.
Connections are created in the PENDING state. Authentication with the connection provider must be completed in the AWS Console.    
[Update a pending connection](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-update.html). 
| Attribute Name | Required?   | Default | Description                                                                                                                                                            |
|:---------------|:-----------:|:-------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name           | required    |         | The name of the connection to be created.                                                                                                                              |
| provider_type  | conditional |         | Name of provider where your third-party code repository is configured (Bitbucket, GitHub, GitHubEnterpriseServer, GitLab, GitLabSelfManaged). Conflicts with host_arn. |
| host_name      | conditional |         | Name of host from codestarconnection_hosts. Either provider_type **or** host_name is required but not both.                                                          |
| tags           | optional    | { }     | A map of tags to assign to the resource.                                                                                                                               |
EOT
}

#####################################################################
# CODESTAR CONNECTION HOSTS
#####################################################################
variable "codestarconnection_hosts" {
  type = list(object({
    name = optional(string, null)
    provider_endpoint = string
    provider_type = optional(string, "GitHubEnterpriseServer")
    vpc_configuration_name = optional(string, null)
  }))
  default = []
  description = <<-EOT
List of CodeStar Connection Hosts.
Hosts are created in the PENDING state. Authentication with the host provider must be completed in the AWS Console.    
[Set up a pending host](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-host-setup.html). 
| Attribute Name         | Required? | Default                | Description                                                                                                 |
|:-----------------------|:---------:|:----------------------:|:------------------------------------------------------------------------------------------------------------|
| name                   | required  |                        | Name of the host to be created. The name must be unique in the calling AWS account.                         |
| provider_endpoint      | required  |                        | Endpoint of the infrastructure where your provider type is installed.                                       |
| provider_type          | optional  | GitHubEnterpriseServer | Name of the installed provider to be associated with your connection. Default is GitHubEnterpriseServer.    |
| vpc_configuration_name | optional  | null                   | Name of the VPC configuration from host_vpc_configurations.                                                 |
EOT
}

#####################################################################
# CODESTAR CONNECTION HOST VPC CONFIGURATIONS
#####################################################################
variable "host_vpc_configurations" {
  type = list(object({
    name = string
    vpc_id = string
    subnet_ids = list(string)
    security_group_ids = list(string)
    tls_certificate = optional(string, null)
  }))
  default = []
  description = <<-EOT
List of VPC configurations for Codestar connection hosts.
| Attribute Name     | Required? | Default | Description                                                                                                 |
|:-------------------|:---------:|:-------:|:------------------------------------------------------------------------------------------------------------|
| name               | required  |         | Unique name to identify configuration, used as vpc_configuration_name in codestarconnection_hosts variable. |
| vpc_id             | required  |         | VPC id connected to the infrastructure where your provider type is installed.                               |
| subnet_ids         | required  |         | List of subnet ids associated with the VPC where your provider type is installed.                           |
| security_group_ids | required  |         | List of security group ids associated with the VPC where your provider type is installed.                   |
| tls_certificate    | optional  | null    | Value of the TLS certificate associated with the infrastructure where your provider type is installed.      |
EOT
}

#####################################################################
# PIPELINES 
#####################################################################
variable "pipelines" {
  type = list(object({
    name = string
    pipeline_type = optional(string, "V1")
    role_name = string
    execution_mode = optional(string, "SUPERSEDED")
    artifact_store_names = list(string)
    stage_names = list(string)
    trigger_names = optional(list(string), [])
    variable_names = optional(list(string), [])
    tags = optional(map(string), {})
  }))
  default = []
  description = <<-EOT
List of AWS [CodePipelines](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipeline-requirements.html).    
Resource: [aws_codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline)
| Attribute Name       | Required? | Default | Description                                                                                                 |
|:---------------------|:---------:|:-------:|:------------------------------------------------------------------------------------------------------------|
| name                 | required  |            | Name of the pipeline.          |
| pipeline_type        | optional  | V1         | Type of the pipeline. Possible values are: V1 and V2. Default value is V1.                           |
| role_name            | required  |            | IAM service role name that grants CodePipeline permission to make calls to AWS services. |
| execution_mode       | optional  | SUPERSEDED | Method pipeline will use to handle multiple executions (QUEUED, SUPERSEDED, PARALLEL).   |
| artifact_store_names | required  | [ ]        | List of names of pipeline_artifact_stores. At least 1 required.                          |
| stage_names          | required  | [ ]        | List of names of pipeline_stages. At least 2 required.                                   |
| trigger_names        | optional  | [ ]        | List of names of pipeline_triggers. Valid only when pipeline_type is V2.                 |
| variable_names       | optional  | [ ]        | List of names of pipeline_variables. Valid only when pipeline_type is V2.                |
| tags                 | optional  | { }        | A map of tags to assign to the resource.     |
EOT
}

#####################################################################
## PIPELINE ARTIFACT STORES
#####################################################################
variable "pipeline_artifact_stores" {
  type = list(object({
    location = string
    type = optional(string, "S3")
    region = optional(string, null)
    encryption_key = optional(object({
      id = string
      type = optional(string, "KMS") }), null)
  }))
  default = []
  description = <<-EOT
List of artifact stores for storage of input and output artifacts. At least 1 is required.
| Attribute Name | Required? | Default | Description                                                                                     |
|:---------------|:---------:|:-------:|:------------------------------------------------------------------------------------------------|
| name           | required  |         | Unique name to identify the artifact store, used as artifact_store_names in pipelines variable. |
| location       | required  |         | Location where pipeline stores artifacts, currently only an S3 bucket name is supported.        |
| type           | optional  | S3      | Type of artifact store. Defaults to S3.                                                         |
| region         | optional  | null    | Region where the artifact store is located. Only required for a cross-region pipeline.          |
| encryption_key | optional  | null    | Encryption key to use to encrypt data in artifact store. Defaults to default key for S3.        |
| &ensp; id      | required  |         | KMS key ARN or ID.                                                                              |
| &ensp; type    | optional  | KMS     | Type of key, currently only KMS is supported.                                                   |
EOT
}

#####################################################################
## PIPELINE STAGES
#####################################################################
variable "pipeline_stages" {
  type = list(object({
    name = string
    action_name = string
  }))
  default = []
  description = <<-EOT
List of stages that can be included in a pipeline stages.  At least 2 are required. 
| Attribute Name | Required? | Default | Description                                                                   |
|:---------------|:---------:|:-------:|:------------------------------------------------------------------------------|
| name           | required  |         | Unique name to identify the stage, used as stage_names in pipelines variable. |
| action_name    | required  |         | Action name from pipeline_stage_actions to include in the stage.              |
EOT
}

#####################################################################
## PIPELINE STAGE ACTIONS
#####################################################################
variable "pipeline_stage_actions" {
  type = list(object({
    name = string
    category = string # Source | Build | Deploy | Test | Invoke | Approval | Compute
    owner = string # AWS | ThirdParty | Custom
    provider = string
    version = string
    input_artifacts = optional(list(string), null)
    output_artifacts = optional(list(string), null)
    role_name = optional(string, null)
    run_order = optional(number, null)
    region = optional(string, null)
    namespace = optional(string, null)
    configuration = optional(map(string), null)
  }))
  default = [ ]
  description = <<-EOT
List of actions that can be included in pipeline stages.
| Attribute Name   | Required? | Default | Description                                                                                                                                                                                                      |
|:-----------------|:---------:|:-------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name             | required  |         | Unique name to identify the action, used as action_name in pipeline_stages variable.                                                                                                                             |
| category         | required  |         | Category defines what kind of action can be taken in the stage (Approval, Build, Deploy, Invoke, Source and Test).                                                                                               |
| owner            | required  |         | The creator of the action being called (AWS, Custom, ThirdParty).                                                                                                                                                |
| provider         | required  |         | [Provider](https://docs.aws.amazon.com/codepipeline/latest/userguide/actions-valid-providers.html) of the service being called by the action.                                                                    |
| version          | required  |         | String that describes the action version.                                                                                                                                                                        |
| input_artifacts  | optional  | null    | List of artifact names to be worked on.                                                                                                                                                                          |
| output_artifacts | optional  | null    | List of artifact names to output.                                                                                                                                                                                |
| role_name        | optional  | null    | Name of the IAM service role that performs the declared action. This is assumed through the roleArn for the pipeline.                                                                                            |
| run_order        | optional  | null    | Order in which actions are run.                                                                                                                                                                                  |
| region           | optional  | null    | Action declaration's AWS Region, such as us-east-1.                                                                                                                                                              |
| namespace        | optional  | null    | Variable namespace associated with the action. All variables produced as output by this action fall under this namespace.                                                                                        |
| configuration    | optional  | null    | The action's configuration, key-value pairs that specify input values for an action. [Configuration Parameters](https://docs.aws.amazon.com/codepipeline/latest/userguide/structure-configuration-examples.html) |
EOT
}

#####################################################################
## PIPELINE TRIGGERS
#####################################################################
variable "pipeline_triggers" {
  type = list(object({
    name = string
    provider_type = optional(string, "CodeStarSourceConnection")
    git_configuration_name = string
  }))
  default = [ ]
  description = <<-EOT
List of filter criteria and source stage that can trigger a pipeline.
| Attribute Name         | Required? | Default                  | Description                                                                                                        |
|:-----------------------|:---------:|:------------------------:|:-------------------------------------------------------------------------------------------------------------------|
| name                   | required  |                          | Unique name to identify the trigger, used as trigger_names in pipelines variable.                                  |
| provider_type          | optional  | CodeStarSourceConnection | The source provider for the event. Defaults to CodeStarSourceConnection.                                           |
| git_configuration_name | required  |                          | Name of configuration from pipeline_trigger_git_configurations that provides criteria that can trigger a pipeline. |
EOT
}

#####################################################################
## PIPELINE TRIGGER GIT CONFIGURATIONS
#####################################################################
variable "pipeline_trigger_git_configurations" {
  type = list(object({
    name = string
    source_action_name = string
    pull_request_events = optional(list(string), null)
    pull_request_filter_names = optional(list(string), null)
    push_filter_names = optional(list(string), null)
  }))
  default = [ ]
  description = <<-EOT
Map of Git-based Configurations for source actions that can trigger a pipeline. Requires pull_request_filter_names and/or push_filter_names to be specified.       
[git_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline#git_configuration-2)
| Attribute Name            | Required?   | Default  | Description                                                                                              |
|:--------------------------|:-----------:|:--------:|:---------------------------------------------------------------------------------------------------------|
| name                      | required    |          | Unique name to identify the configuration, used as git_configuration_name in pipeline_triggers variable. |
| source_action_name        | required    |          | Name of the pipeline source action where the trigger configuration is specified.                         |    
| pull_request_events       | optional    | null     | List of pull request events to filter on (OPEN, UPDATED, CLOSED). Filters on all events by default.      |
| pull_request_filter_names | conditional | null     | List of filters from git_configuration_filters to filter a pull request.                                 |
| push_filter_names         | conditional | null     | List of filters from git_configuration_filters to filter a push.                                         |
EOT
}

#####################################################################
## PIPELINE TRIGGER GIT CONFIGURATION FILTERS
#####################################################################
variable "git_configuration_filters" {
  type = list(object({
    type = string
    includes = optional(list(string), [])
    excludes = optional(list(string), [])
  }))
  default = [ ]
  description = <<-EOT
A map that defines lists of patterns for branches, tags, or file paths that are to be included or excluded as criteria to start a pipeline.
[Examples for trigger filters](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-filter.html#pipelines-filter-examples)
| Attribute Name | Required? | Default  | Description                                                                                                                                 |
|:---------------|:---------:|:--------:|:--------------------------------------------------------------------------------------------------------------------------------------------|
| name           | required  |          | Unique name to identify the filter, used as pull_request_filter_names or push_filter_names in pipeline_trigger_git_configurations variable. |
| type           | required  |          | Type of filter (Branch, Tag, FilePath).                                                                                                     |
| includes       | optional  | [ ]      | List of patterns that are included as criteria to trigger a pipeline.                                                                       |    
| excludes       | optional  | [ ]      | List of patterns that are excluded as criteria to trigger a pipeline.                                                                       |
EOT
}

#####################################################################
## PIPELINE VARIABLES
#####################################################################
variable "pipeline_variables" {
  type = list(object({
    name = optional(string, null)
    default_value = optional(string, null)
    description = optional(string, null)
  }))
  default = [ ]
  description = <<-EOT
A map that defines pipeline variables for a pipeline resource.
| Attribute Name | Required? | Default  | Description                                                                          |
|:---------------|:---------:|:--------:|:-------------------------------------------------------------------------------------|
| name           | required  |          | Give each variable a unique name. Also used as variable_names in pipelines variable. |
| default_value  | optional  | null     | The default value of a pipeline-level variable.                                      |
| description    | optional  | null     | The description of a pipeline-level variable.                                        | 
EOT
}
