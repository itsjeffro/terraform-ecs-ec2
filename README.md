# terraform-ecs-ec2

Set up for ECS using EC2.

## Commands

```bash
terraform init -backend-config ./backend/backend.tfvars

terraform plan -var-file ./backend/backend.tfvars

terraform apply -var-file ./backend/backend.tfvars
```
