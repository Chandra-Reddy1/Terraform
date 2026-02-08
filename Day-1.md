# Terraform Basics — Day 1 Notes

## 1. What is Terraform?

Terraform is an **Infrastructure as Code (IaC)** tool created by HashiCorp.

It allows you to:
- Create infrastructure
- Modify infrastructure
- Delete infrastructure

using **code instead of manual clicks**.

You write configuration files (`.tf`) and Terraform interacts with cloud APIs like:
- AWS
- Azure
- GCP

Terraform reads the code and builds the infrastructure automatically.

Key idea:
> Infrastructure is defined in code and can be version controlled.

---

## 2. Why We Use Terraform

### Problem Without Terraform
Manual cloud work causes:
- Human errors  
- No version control  
- No repeatability  
- Hard to track changes  
- Slow environment setup  

### Terraform Solves

**Automation**
Create full infrastructure in seconds.

**Consistency**
Same code → same infrastructure every time.

**Version Control**
Store infra code in Git.

**Reproducibility**
Dev, QA, Prod can be identical.

**State Management**
Terraform tracks what exists and what changed.

**Multi-Cloud**
One tool works for:
- AWS
- Azure
- GCP

### Why Terraform Over Others
- Declarative syntax
- Large provider ecosystem
- State tracking
- Widely used in DevOps jobs

---

## 3. Terraform Commands

### Initialize
```bash
terraform init
```
Downloads providers and prepares working directory.

---

### Validate
```bash
terraform validate
```
Checks syntax correctness.

---

### Plan
```bash
terraform plan
```
Shows what will be created/changed/destroyed.

No resources created yet.

---

### Apply
```bash
terraform apply
```
Creates infrastructure.

Skip confirmation:
```bash
terraform apply -auto-approve
```

---

### Destroy
```bash
terraform destroy
```
Deletes all resources in state.

Skip confirmation:
```bash
terraform destroy -auto-approve
```

---

### Show State
```bash
terraform show
```

---

### Format Code
```bash
terraform fmt
```

---

## 4. Basic Setup Explanation

### Terraform File

```hcl
provider "aws" {
  region = "us-east-1"  
}

resource "aws_instance" "my-first-project" {
  ami           = "ami-06f5f29d1fe41ea03"
  instance_type = "t2.micro"
}
```

---

### Provider Block

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Purpose:
- Connect Terraform to AWS
- Defines region
- Uses AWS credentials from:
  - AWS CLI config
  - Environment variables
  - IAM role

Without provider → Terraform cannot talk to AWS.

---

### Resource Block

```hcl
resource "aws_instance" "my-first-project"
```

Structure:
```
resource "<TYPE>" "<NAME>"
```

- TYPE → aws_instance
- NAME → my-first-project (local reference name)

This tells Terraform to create an EC2 instance.

---

### AMI

```hcl
ami = "ami-06f5f29d1fe41ea03"
```

Defines OS image:
- Amazon Linux
- Ubuntu
- etc.

AMI is region specific.

---

### Instance Type

```hcl
instance_type = "t2.micro"
```

Defines:
- CPU
- Memory

`t2.micro`:
- Old generation
- Free tier
- Not compatible with some modern AMIs

Better modern option:
```
t3.micro
```

---

## Terraform Workflow

1. Write `.tf` file  
2. Run `terraform init`  
3. Run `terraform plan`  
4. Run `terraform apply`  
5. Verify in AWS  
6. Run `terraform destroy` when done  

---

## Key Learning Points

- Terraform uses HCL language
- Provider connects to cloud
- Resource creates infrastructure
- Plan shows changes before apply
- State file tracks infrastructure
- Always destroy unused resources to avoid cost

---

## Common Beginner Mistakes

- Using outdated instance types
- Not running `terraform init`
- Hardcoding values
- Ignoring error messages
- Not checking region-specific AMIs

---

## Summary

Terraform is a core DevOps tool used to automate infrastructure.  
It ensures repeatability, consistency, and version control for cloud environments.

Day 1 covered:
- What Terraform is
- Why it is used
- Basic commands
- AWS provider setup
- EC2 creation example
