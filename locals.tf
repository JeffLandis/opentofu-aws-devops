locals {
  pipelines = {
    for val in var.var.pipelines: val.name => val
  }
}