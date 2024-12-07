<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.6)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.68)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6.3)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (>= 5.68)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_codestarconnections_connection.this](https://registry.terraform.io/providers/opentofu/aws/latest/docs/resources/codestarconnections_connection) (resource)

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_codestarconnections"></a> [codestarconnections](#input\_codestarconnections)

Description: List of CodeStar Connections.  
Connections are created in the PENDING state. Authentication with the connection provider must be completed in the AWS Console.  
[Update a pending connection](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-update.html).
| Attribute Name | Required?   | Default | Description                                                                                                                                                            |
|:---------------|:-----------:|:-------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name           | required    |         | The name of the connection to be created.                                                                                                                              |
| provider\_type  | conditional |         | Name of provider where your third-party code repository is configured (Bitbucket, GitHub, GitHubEnterpriseServer, GitLab, GitLabSelfManaged). Conflicts with host\_arn. |
| host\_name      | conditional |         | Name of host from codestarconnection\_hosts. Either provider\_type **or** host\_name is required but not both.                                                          |
| tags           | optional    | { }     | A map of tags to assign to the resource.                                                                                                                               |

Type:

```hcl
list(object({
    name = string
    provider_type = optional(string, null)
    host_name = optional(string, null)
    tags = optional(map(string), {})
  }))
```

Default: `[]`

### <a name="input_codestarconnection_hosts"></a> [codestarconnection\_hosts](#input\_codestarconnection\_hosts)

Description: List of CodeStar Connection Hosts.  
Hosts are created in the PENDING state. Authentication with the host provider must be completed in the AWS Console.  
[Set up a pending host](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-host-setup.html).
| Attribute Name         | Required? | Default                | Description                                                                                                 |
|:-----------------------|:---------:|:----------------------:|:------------------------------------------------------------------------------------------------------------|
| name                   | required  |                        | Name of the host to be created. The name must be unique in the calling AWS account.                         |
| provider\_endpoint      | required  |                        | Endpoint of the infrastructure where your provider type is installed.                                       |
| provider\_type          | optional  | GitHubEnterpriseServer | Name of the installed provider to be associated with your connection. Default is GitHubEnterpriseServer.    |
| vpc\_configuration\_name | optional  | null                   | Name of the VPC configuration from host\_vpc\_configurations.                                                 |

Type:

```hcl
list(object({
    name = optional(string, null)
    provider_endpoint = string
    provider_type = optional(string, "GitHubEnterpriseServer")
    vpc_configuration_name = optional(string, null)
  }))
```

Default: `[]`

### <a name="input_host_vpc_configurations"></a> [host\_vpc\_configurations](#input\_host\_vpc\_configurations)

Description: List of VPC configurations for Codestar connection hosts.
| Attribute Name     | Required? | Default | Description                                                                                                 |
|:-------------------|:---------:|:-------:|:------------------------------------------------------------------------------------------------------------|
| name               | required  |         | Unique name to identify configuration, used as vpc\_configuration\_name in codestarconnection\_hosts variable. |
| vpc\_id             | required  |         | VPC id connected to the infrastructure where your provider type is installed.                               |
| subnet\_ids         | required  |         | List of subnet ids associated with the VPC where your provider type is installed.                           |
| security\_group\_ids | required  |         | List of security group ids associated with the VPC where your provider type is installed.                   |
| tls\_certificate    | optional  | null    | Value of the TLS certificate associated with the infrastructure where your provider type is installed.      |

Type:

```hcl
list(object({
    name = string
    vpc_id = string
    subnet_ids = list(string)
    security_group_ids = list(string)
    tls_certificate = optional(string, null)
  }))
```

Default: `[]`

### <a name="input_pipelines"></a> [pipelines](#input\_pipelines)

Description: List of AWS [CodePipelines](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipeline-requirements.html).    
Resource: [aws\_codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline)
| Attribute Name       | Required? | Default | Description                                                                                                 |
|:---------------------|:---------:|:-------:|:------------------------------------------------------------------------------------------------------------|
| name                 | required  |            | Name of the pipeline.          |
| pipeline\_type        | optional  | V1         | Type of the pipeline. Possible values are: V1 and V2. Default value is V1.                           |
| role\_name            | required  |            | IAM service role name that grants CodePipeline permission to make calls to AWS services. |
| execution\_mode       | optional  | SUPERSEDED | Method pipeline will use to handle multiple executions (QUEUED, SUPERSEDED, PARALLEL).   |
| artifact\_store\_names | required  | [ ]        | List of names of pipeline\_artifact\_stores. At least 1 required.                          |
| stage\_names          | required  | [ ]        | List of names of pipeline\_stages. At least 2 required.                                   |
| trigger\_names        | optional  | [ ]        | List of names of pipeline\_triggers. Valid only when pipeline\_type is V2.                 |
| variable\_names       | optional  | [ ]        | List of names of pipeline\_variables. Valid only when pipeline\_type is V2.                |
| tags                 | optional  | { }        | A map of tags to assign to the resource.     |

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_pipeline_artifact_stores"></a> [pipeline\_artifact\_stores](#input\_pipeline\_artifact\_stores)

Description: List of artifact stores for storage of input and output artifacts. At least 1 is required.
| Attribute Name | Required? | Default | Description                                                                                     |
|:---------------|:---------:|:-------:|:------------------------------------------------------------------------------------------------|
| name           | required  |         | Unique name to identify the artifact store, used as artifact\_store\_names in pipelines variable. |
| location       | required  |         | Location where pipeline stores artifacts, currently only an S3 bucket name is supported.        |
| type           | optional  | S3      | Type of artifact store. Defaults to S3.                                                         |
| region         | optional  | null    | Region where the artifact store is located. Only required for a cross-region pipeline.          |
| encryption\_key | optional  | null    | Encryption key to use to encrypt data in artifact store. Defaults to default key for S3.        |
| &ensp; id      | required  |         | KMS key ARN or ID.                                                                              |
| &ensp; type    | optional  | KMS     | Type of key, currently only KMS is supported.                                                   |

Type:

```hcl
list(object({
    location = string
    type = optional(string, "S3")
    region = optional(string, null)
    encryption_key = optional(object({
      id = string
      type = optional(string, "KMS") }), null)
  }))
```

Default: `[]`

### <a name="input_pipeline_stages"></a> [pipeline\_stages](#input\_pipeline\_stages)

Description: List of stages that can be included in a pipeline stages.  At least 2 are required.
| Attribute Name | Required? | Default | Description                                                                   |
|:---------------|:---------:|:-------:|:------------------------------------------------------------------------------|
| name           | required  |         | Unique name to identify the stage, used as stage\_names in pipelines variable. |
| action\_name    | required  |         | Action name from pipeline\_stage\_actions to include in the stage.              |

Type:

```hcl
list(object({
    name = string
    action_name = string
  }))
```

Default: `[]`

### <a name="input_pipeline_stage_actions"></a> [pipeline\_stage\_actions](#input\_pipeline\_stage\_actions)

Description: List of actions that can be included in pipeline stages.
| Attribute Name   | Required? | Default | Description                                                                                                                                                                                                      |
|:-----------------|:---------:|:-------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name             | required  |         | Unique name to identify the action, used as action\_name in pipeline\_stages variable.                                                                                                                             |
| category         | required  |         | Category defines what kind of action can be taken in the stage (Approval, Build, Deploy, Invoke, Source and Test).                                                                                               |
| owner            | required  |         | The creator of the action being called (AWS, Custom, ThirdParty).                                                                                                                                                |
| provider         | required  |         | [Provider](https://docs.aws.amazon.com/codepipeline/latest/userguide/actions-valid-providers.html) of the service being called by the action.                                                                    |
| version          | required  |         | String that describes the action version.                                                                                                                                                                        |
| input\_artifacts  | optional  | null    | List of artifact names to be worked on.                                                                                                                                                                          |
| output\_artifacts | optional  | null    | List of artifact names to output.                                                                                                                                                                                |
| role\_name        | optional  | null    | Name of the IAM service role that performs the declared action. This is assumed through the roleArn for the pipeline.                                                                                            |
| run\_order        | optional  | null    | Order in which actions are run.                                                                                                                                                                                  |
| region           | optional  | null    | Action declaration's AWS Region, such as us-east-1.                                                                                                                                                              |
| namespace        | optional  | null    | Variable namespace associated with the action. All variables produced as output by this action fall under this namespace.                                                                                        |
| configuration    | optional  | null    | The action's configuration, key-value pairs that specify input values for an action. [Configuration Parameters](https://docs.aws.amazon.com/codepipeline/latest/userguide/structure-configuration-examples.html) |

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_pipeline_triggers"></a> [pipeline\_triggers](#input\_pipeline\_triggers)

Description: List of filter criteria and source stage that can trigger a pipeline.
| Attribute Name         | Required? | Default                  | Description                                                                                                        |
|:-----------------------|:---------:|:------------------------:|:-------------------------------------------------------------------------------------------------------------------|
| name                   | required  |                          | Unique name to identify the trigger, used as trigger\_names in pipelines variable.                                  |
| provider\_type          | optional  | CodeStarSourceConnection | The source provider for the event. Defaults to CodeStarSourceConnection.                                           |
| git\_configuration\_name | required  |                          | Name of configuration from pipeline\_trigger\_git\_configurations that provides criteria that can trigger a pipeline. |

Type:

```hcl
list(object({
    name = string
    provider_type = optional(string, "CodeStarSourceConnection")
    git_configuration_name = string
  }))
```

Default: `[]`

### <a name="input_pipeline_trigger_git_configurations"></a> [pipeline\_trigger\_git\_configurations](#input\_pipeline\_trigger\_git\_configurations)

Description: Map of Git-based Configurations for source actions that can trigger a pipeline. Requires pull\_request\_filter\_names and/or push\_filter\_names to be specified.     
[git\_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline#git_configuration-2)
| Attribute Name            | Required?   | Default  | Description                                                                                              |
|:--------------------------|:-----------:|:--------:|:---------------------------------------------------------------------------------------------------------|
| name                      | required    |          | Unique name to identify the configuration, used as git\_configuration\_name in pipeline\_triggers variable. |
| source\_action\_name        | required    |          | Name of the pipeline source action where the trigger configuration is specified.                         |  
| pull\_request\_events       | optional    | null     | List of pull request events to filter on (OPEN, UPDATED, CLOSED). Filters on all events by default.      |
| pull\_request\_filter\_names | conditional | null     | List of filters from git\_configuration\_filters to filter a pull request.                                 |
| push\_filter\_names         | conditional | null     | List of filters from git\_configuration\_filters to filter a push.                                         |

Type:

```hcl
list(object({
    name = string
    source_action_name = string
    pull_request_events = optional(list(string), null)
    pull_request_filter_names = optional(list(string), null)
    push_filter_names = optional(list(string), null)
  }))
```

Default: `[]`

### <a name="input_git_configuration_filters"></a> [git\_configuration\_filters](#input\_git\_configuration\_filters)

Description: A map that defines lists of patterns for branches, tags, or file paths that are to be included or excluded as criteria to start a pipeline.
[Examples for trigger filters](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-filter.html#pipelines-filter-examples)
| Attribute Name | Required? | Default  | Description                                                                                                                                 |
|:---------------|:---------:|:--------:|:--------------------------------------------------------------------------------------------------------------------------------------------|
| name           | required  |          | Unique name to identify the filter, used as pull\_request\_filter\_names or push\_filter\_names in pipeline\_trigger\_git\_configurations variable. |
| type           | required  |          | Type of filter (Branch, Tag, FilePath).                                                                                                     |
| includes       | optional  | [ ]      | List of patterns that are included as criteria to trigger a pipeline.                                                                       |  
| excludes       | optional  | [ ]      | List of patterns that are excluded as criteria to trigger a pipeline.                                                                       |

Type:

```hcl
list(object({
    type = string
    includes = optional(list(string), [])
    excludes = optional(list(string), [])
  }))
```

Default: `[]`

### <a name="input_pipeline_variables"></a> [pipeline\_variables](#input\_pipeline\_variables)

Description: A map that defines pipeline variables for a pipeline resource.
| Attribute Name | Required? | Default  | Description                                                                          |
|:---------------|:---------:|:--------:|:-------------------------------------------------------------------------------------|
| name           | required  |          | Give each variable a unique name. Also used as variable\_names in pipelines variable. |
| default\_value  | optional  | null     | The default value of a pipeline-level variable.                                      |
| description    | optional  | null     | The description of a pipeline-level variable.                                        |

Type:

```hcl
list(object({
    name = optional(string, null)
    default_value = optional(string, null)
    description = optional(string, null)
  }))
```

Default: `[]`

## Outputs

No outputs.
<!-- END_TF_DOCS -->