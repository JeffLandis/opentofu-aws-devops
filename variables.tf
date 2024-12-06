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
Map of actions that can be included in pipeline stages.
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
  type = map(object({
    name = optional(string, null)
    action_name = string
  }))
  default = {}
  description = <<-EOT
Map of actions that can be included in pipeline stages.
| Attribute Name   | Attribute Description                                                        |
|------------------|------------------------------------------------------------------------------|
| name             | (Optional) The name of the stage. Defaults to the maps's key.                |
| action_name      | (Required) List of names for pipeline_stage_actions to include in the stage. |
EOT
}

#####################################################################
## PIPELINE STAGE ACTIONS
#####################################################################
variable "pipeline_stage_actions" {
  type = map(object({
    name = optional(string, null) # defaults to map's key
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
  default = {}
  description = <<-EOT
Map of actions that can be included in pipeline stages.
| Attribute Name   | Attribute Description                                                                                                                                   |
|------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| name             | (Optional) The action declaration's name. Defaults to the maps's key.                                                                                   |
| category         | (Required) Category defines what kind of action can be taken in the stage (Approval, Build, Deploy, Invoke, Source and Test).                           |
| owner            | (Required) The creator of the action being called (AWS, Custom, ThirdParty).                                                                            |
| provider         | (Required) [Provider](https://docs.aws.amazon.com/codepipeline/latest/userguide/actions-valid-providers.html) of the service being called by the action.|
| version          | (Required) String that describes the action version.                                                                                                    |
| input_artifacts  | (Optional) List of artifact names to be worked on.                                                                                                      |
| output_artifacts | (Optional) List of artifact names to output.                                                                                                            |
| role_name        | (Optional) Name of the IAM service role that performs the declared action. This is assumed through the roleArn for the pipeline.                        |
| run_order        | (Optional) Order in which actions are run.                                                                                                              |
| region           | (Optional) Action declaration's AWS Region, such as us-east-1.                                                                                          |
| namespace        | (Optional) Variable namespace associated with the action. All variables produced as output by this action fall under this namespace.                    |
| configuration    | (Optional) The action's configuration. These are key-value pairs that specify input values for an action.                                               |
EOT
}

#####################################################################
## PIPELINE TRIGGERS
#####################################################################
variable "pipeline_triggers" {
  type = map(object({
    provider_type = optional(string, "CodeStarSourceConnection")
    git_configuration_name = optional(string, null)
  }))
  default = {}
  description = <<-EOT
Map of filter criteria and source stage that can trigger a pipeline.
| Attribute Name         | Attribute Description                                                                                               |
|------------------------|---------------------------------------------------------------------------------------------------------------------|
| provider_type          | (Optional) The source provider for the event. Defaults to CodeStarSourceConnection.                                 |
| git_configuration_name | (Required) Name from pipeline_trigger_git_configurations that provides filter criteria that can trigger a pipeline. |
EOT
}

#####################################################################
## PIPELINE TRIGGER GIT CONFIGURATIONS
#####################################################################
variable "pipeline_trigger_git_configurations" {
  type = map(object({
    source_action_name = string
    pull_request_name = optional(string, null)
    push_name = optional(string, null)
  }))
  default = {}
  description = <<-EOT
Map of Git-based Configurations for source actions that can trigger a pipeline.   
[git_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline#git_configuration-2)
| Attribute Name     | Attribute Description                                                                                                   |
|--------------------|-------------------------------------------------------------------------------------------------------------------------|
| source_action_name | (Optional) Name of the pipeline source action where the trigger configuration is specified. Defaults to the maps's key. |
| pull_request_name  | (Optional) Name of the git_configuration_pull_requests that can trigger a pipeline.                                     |
| push_name          | (Optional) Name of the git_configuration_pushes that can trigger a pipeline.                                            |
EOT
}

#####################################################################
## PIPELINE TRIGGER GIT CONFIGURATION PULL REQUESTS
#####################################################################
variable "git_configuration_pull_requests" {
  type = map(object({
    events = optional(list(string), []) # OPEN | UPDATED | CLOSED
    branch_filter_names = optional(list(string), [])
    file_path_filter_names = optional(list(string), [])
  }))
  default = {}
  description = <<-EOT
A map of lists of events and git_configuration_filters on a git pull request that can trigger a pipeline.   
[Filter triggers on code push or pull requests](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-filter.html)
| Attribute Name         | Attribute Description                                                        |
|------------------------|------------------------------------------------------------------------------|
| events                 | (Optional) List of pull request events to filter on (OPEN, UPDATED, CLOSED). |
| branch_filter_names    | (Optional) List of names for git_configuration_filters to match git branches.|
| file_path_filter_names | (Optional) List of names for git_configuration_filters to match file paths.  |
EOT
}

#####################################################################
## PIPELINE TRIGGER GIT CONFIGURATION PUSHES
#####################################################################
variable "git_configuration_pushes" {
  type = map(object({
    branch_filter_names = optional(list(string), [])
    tag_filter_names = optional(list(string), [])
    file_path_filter_names = optional(list(string), [])
  }))
  default = {}
  description = <<-EOT
A map of lists of git_configuration_filters on a git push that can trigger a pipeline.   
[Filter triggers on code push or pull requests](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-filter.html)
| Attribute Name         | Attribute Description                                                        |
|------------------------|------------------------------------------------------------------------------|
| branch_filter_names    | (Optional) List of names for git_configuration_filters to match git branches.|
| tag_filter_names       | (Optional) List of names for git_configuration_filters to match git tags.    |
| file_path_filter_names | (Optional) List of names for git_configuration_filters to match file paths.  |
EOT
}

#####################################################################
## PIPELINE TRIGGER GIT CONFIGURATION FILTERS
#####################################################################
variable "git_configuration_filters" {
  type = map(object({
    includes = optional(list(string), [])
    excludes = optional(list(string), [])
  }))
  default = {}
  description = <<-EOT
A map that defines lists of patterns for branches, tags, or file paths that are to be included or excluded as criteria to start a pipeline.
The lists for each entry in the map can only define one kind: branches, tags, or file paths.  
[Examples for trigger filters](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-filter.html#pipelines-filter-examples)
| Attribute Name  | Attribute Description                                                            |
|-----------------|----------------------------------------------------------------------------------|
| includes        | (Optional) List of patterns that are included as criteria to trigger a pipeline. |
| excludes        | (Optional) List of patterns that are excluded as criteria to trigger a pipeline. |
EOT
}

#####################################################################
## PIPELINE VARIABLES
#####################################################################
variable "pipeline_variables" {
  type = map(object({
    name = optional(string, null) # defaults to map's key
    default_value = optional(string, null)
    description = optional(string, null)
  }))
  default = {}
  description = <<-EOT
A map that defines pipeline variables for a pipeline resource.
| Attribute Name  | Attribute Description                                                         |
|-----------------|-------------------------------------------------------------------------------|
| name            | (Optional) Give each variable a unique name. Defaults to the maps's key.      |
| default_value   | (Optional) The default value of a pipeline-level variable.                    |
| description     | (Optional) The description of a pipeline-level variable.                      |
EOT
}
