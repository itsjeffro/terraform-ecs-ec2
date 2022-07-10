dynamodb_table       = "terraform_state_lock"
bucket               = "terraform-state-bucket"
key                  = "ecs.tfstate" // path to s3 bucket key
workspace_key_prefix = "terraform-workspaces"
