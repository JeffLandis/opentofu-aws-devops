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
| tags           | optional    | { }      | A map of tags to assign to the resource.                                                                                                                               |

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
| Attribute Name | Attribute Description                                                                              |
|----------------|----------------------------------------------------------------------------------------------------|
| name                  | (Required) Name of the pipeline.
| pipeline\_type         | (Optional) Type of the pipeline. Possible values are: V1 and V2. Default value is V1.
| role\_name             | (Required) IAM service role name that grants CodePipeline permission to make calls to AWS services.
| execution\_mode        | (Optional) Method pipeline will use to handle multiple executions (QUEUED, SUPERSEDED, PARALLEL). Default is SUPERSEDED.
| tags                  | (Optional) A map of tags to assign to the resource.
| artifact\_store\_names  | (Required) List of names of pipeline\_artifact\_stores. At least 1 required.
| stage\_names           | (Required) List of names of pipeline\_stages. At least 2 required.
| trigger\_names         | (Optional) List of names of pipeline\_triggers. Valid only when pipeline\_type is V2.
| variable\_names        | (Optional) List of names of pipeline\_variables. Valid only when pipeline\_type is V2.

Type:

```hcl
list(object({
    name = string
    pipeline_type = optional(string, "V1")
    role_name = string
    artifact_store_names = list(string)
    execution_mode = optional(string, "SUPERSEDED")
    stage_names = list(string)
    tags = optional(map(string), {})
    trigger = optional()
    variable_names = list(string)
  }))
```

Default: `[]`

### <a name="input_pipeline_artifact_stores"></a> [pipeline\_artifact\_stores](#input\_pipeline\_artifact\_stores)

Description: Map of actions that can be included in pipeline stages.
| Attribute Name | Attribute Description                                                                              |
|----------------|----------------------------------------------------------------------------------------------------|
| location       | (Required) Location where pipeline stores artifacts, currently only an S3 bucket is supported.     |
| type           | (Optional) Type of artifact store. Defaults to S3.                                                 |
| encryption\_key | (Optional) Encryption key to use to encrypt data in artifact store. Defaults to default key for S3.|
| region         | (Optional) Region where the artifact store is located. Only required for a cross-region pipeline.  |

Type:

```hcl
map(object({
    location = string
    type = optional(string, "S3")
    encryption_key = optional(object({ id = string, type = optional(string, "KMS") }), null)
    region = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_pipeline_stages"></a> [pipeline\_stages](#input\_pipeline\_stages)

Description: Map of actions that can be included in pipeline stages.
| Attribute Name   | Attribute Description                                                        |
|------------------|------------------------------------------------------------------------------|
| name             | (Optional) The name of the stage. Defaults to the maps's key.                |
| action\_name      | (Required) List of names for pipeline\_stage\_actions to include in the stage. |

Type:

```hcl
map(object({
    name = optional(string, null)
    action_name = string
  }))
```

Default: `{}`

### <a name="input_pipeline_stage_actions"></a> [pipeline\_stage\_actions](#input\_pipeline\_stage\_actions)

Description: Map of actions that can be included in pipeline stages.
| Attribute Name   | Attribute Description                                                                                                                                   |
|------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| name             | (Optional) The action declaration's name. Defaults to the maps's key.                                                                                   |
| category         | (Required) Category defines what kind of action can be taken in the stage (Approval, Build, Deploy, Invoke, Source and Test).                           |
| owner            | (Required) The creator of the action being called (AWS, Custom, ThirdParty).                                                                            |
| provider         | (Required) [Provider](https://docs.aws.amazon.com/codepipeline/latest/userguide/actions-valid-providers.html) of the service being called by the action.|
| version          | (Required) String that describes the action version.                                                                                                    |
| input\_artifacts  | (Optional) List of artifact names to be worked on.                                                                                                      |
| output\_artifacts | (Optional) List of artifact names to output.                                                                                                            |
| role\_name        | (Optional) Name of the IAM service role that performs the declared action. This is assumed through the roleArn for the pipeline.                        |
| run\_order        | (Optional) Order in which actions are run.                                                                                                              |
| region           | (Optional) Action declaration's AWS Region, such as us-east-1.                                                                                          |
| namespace        | (Optional) Variable namespace associated with the action. All variables produced as output by this action fall under this namespace.                    |
| configuration    | (Optional) The action's configuration. These are key-value pairs that specify input values for an action.                                               |

Type:

```hcl
map(object({
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
```

Default: `{}`

### <a name="input_pipeline_triggers"></a> [pipeline\_triggers](#input\_pipeline\_triggers)

Description: Map of filter criteria and source stage that can trigger a pipeline.
| Attribute Name         | Attribute Description                                                                                               |
|------------------------|---------------------------------------------------------------------------------------------------------------------|
| provider\_type          | (Optional) The source provider for the event. Defaults to CodeStarSourceConnection.                                 |
| git\_configuration\_name | (Required) Name from pipeline\_trigger\_git\_configurations that provides filter criteria that can trigger a pipeline. |

Type:

```hcl
map(object({
    provider_type = optional(string, "CodeStarSourceConnection")
    git_configuration_name = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_pipeline_trigger_git_configurations"></a> [pipeline\_trigger\_git\_configurations](#input\_pipeline\_trigger\_git\_configurations)

Description: Map of Git-based Configurations for source actions that can trigger a pipeline.   
[git\_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline#git_configuration-2)
| Attribute Name     | Attribute Description                                                                                                   |
|--------------------|-------------------------------------------------------------------------------------------------------------------------|
| source\_action\_name | (Optional) Name of the pipeline source action where the trigger configuration is specified. Defaults to the maps's key. |
| pull\_request\_name  | (Optional) Name of the git\_configuration\_pull\_requests that can trigger a pipeline.                                     |
| push\_name          | (Optional) Name of the git\_configuration\_pushes that can trigger a pipeline.                                            |

Type:

```hcl
map(object({
    source_action_name = string
    pull_request_name = optional(string, null)
    push_name = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_git_configuration_pull_requests"></a> [git\_configuration\_pull\_requests](#input\_git\_configuration\_pull\_requests)

Description: A map of lists of events and git\_configuration\_filters on a git pull request that can trigger a pipeline.   
[Filter triggers on code push or pull requests](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-filter.html)
| Attribute Name         | Attribute Description                                                        |
|------------------------|------------------------------------------------------------------------------|
| events                 | (Optional) List of pull request events to filter on (OPEN, UPDATED, CLOSED). |
| branch\_filter\_names    | (Optional) List of names for git\_configuration\_filters to match git branches.|
| file\_path\_filter\_names | (Optional) List of names for git\_configuration\_filters to match file paths.  |

Type:

```hcl
map(object({
    events = optional(list(string), []) # OPEN | UPDATED | CLOSED
    branch_filter_names = optional(list(string), [])
    file_path_filter_names = optional(list(string), [])
  }))
```

Default: `{}`

### <a name="input_git_configuration_pushes"></a> [git\_configuration\_pushes](#input\_git\_configuration\_pushes)

Description: A map of lists of git\_configuration\_filters on a git push that can trigger a pipeline.   
[Filter triggers on code push or pull requests](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-filter.html)
| Attribute Name         | Attribute Description                                                        |
|------------------------|------------------------------------------------------------------------------|
| branch\_filter\_names    | (Optional) List of names for git\_configuration\_filters to match git branches.|
| tag\_filter\_names       | (Optional) List of names for git\_configuration\_filters to match git tags.    |
| file\_path\_filter\_names | (Optional) List of names for git\_configuration\_filters to match file paths.  |

Type:

```hcl
map(object({
    branch_filter_names = optional(list(string), [])
    tag_filter_names = optional(list(string), [])
    file_path_filter_names = optional(list(string), [])
  }))
```

Default: `{}`

### <a name="input_git_configuration_filters"></a> [git\_configuration\_filters](#input\_git\_configuration\_filters)

Description: A map that defines lists of patterns for branches, tags, or file paths that are to be included or excluded as criteria to start a pipeline.  
The lists for each entry in the map can only define one kind: branches, tags, or file paths.  
[Examples for trigger filters](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-filter.html#pipelines-filter-examples)
| Attribute Name  | Attribute Description                                                            |
|-----------------|----------------------------------------------------------------------------------|
| includes        | (Optional) List of patterns that are included as criteria to trigger a pipeline. |
| excludes        | (Optional) List of patterns that are excluded as criteria to trigger a pipeline. |

Type:

```hcl
map(object({
    includes = optional(list(string), [])
    excludes = optional(list(string), [])
  }))
```

Default: `{}`

### <a name="input_pipeline_variables"></a> [pipeline\_variables](#input\_pipeline\_variables)

Description: A map that defines pipeline variables for a pipeline resource.
| Attribute Name  | Attribute Description                                                         |
|-----------------|-------------------------------------------------------------------------------|
| name            | (Optional) Give each variable a unique name. Defaults to the maps's key.      |
| default\_value   | (Optional) The default value of a pipeline-level variable.                    |
| description     | (Optional) The description of a pipeline-level variable.                      |

Type:

```hcl
map(object({
    name = optional(string, null) # defaults to map's key
    default_value = optional(string, null)
    description = optional(string, null)
  }))
```

Default: `{}`

## Outputs

No outputs.
<!-- END_TF_DOCS -->