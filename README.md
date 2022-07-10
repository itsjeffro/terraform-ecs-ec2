# terraform-ecs-ec2

Set up for ECS using EC2.

Resources created:

- ECS related resources
  - ecs cluster
  - task definition
  - service

- EC2 related resources
  - ec2 instance
  - launch configuration
  - auto scaling group

## Commands

```bash
terraform init -backend-config ./backend/backend.tfvars

terraform plan -var-file ./backend/backend.tfvars

terraform apply -var-file ./backend/backend.tfvars
```
