variable "bucket" {
  type = string
  description = "S3 bucket that will store our terraform state"
}

variable "key" {
  type = string
  description = "Path to our s3 key"
}

variable "workspace_key_prefix" {
  type = string
}

variable "dynamodb_table" {
  type = string
  description = "Where we create our lock when applying changes. The bucket name will be used as the table record name"
}

locals {
  cluster_name = "demo"
}
