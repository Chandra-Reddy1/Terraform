# 🏗️ Terraform Complete Guide — Variables, Environments, Workspaces & Outputs

> **How to execute this file in PowerShell:**
> ```powershell
> # View the file
> Get-Content .\terraform-guide.md
>
> # Or open it in VS Code directly
> code .\terraform-guide.md
>
> # To run Terraform commands from PowerShell
> Set-Location C:\path\to\your\terraform\project
> terraform init
> terraform plan -var-file="dev.tfvars"
> terraform apply -var-file="dev.tfvars"
> ```

---

## 📁 Project Folder Structure

```
terraform-project/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── dev.tfvars
├── uat.tfvars
└── prod.tfvars
```

---

## 📌 Section 1 — How `main.tf`, `variables.tf`, and `dev.tfvars` Work Together

### 🔷 `main.tf` — The Core Configuration

```hcl
provider "aws" {
  region = var.region
}

resource "aws_instance" "my-test" {
  count         = var.resource
  ami           = var.ami
  instance_type = var.aws_instance[1]
  tags          = var.map_tags
}
```

**How it works:**

| Line | Explanation |
|------|-------------|
| `provider "aws"` | Tells Terraform to use AWS as the cloud provider |
| `region = var.region` | Pulls the region value from `variables.tf` / `.tfvars` file |
| `count = var.resource` | Creates N number of EC2 instances (from variable) |
| `ami = var.ami` | Uses the AMI ID passed from the `.tfvars` file |
| `instance_type = var.aws_instance[1]` | Picks index `[1]` from the list — i.e., `"t2.small"` |
| `tags = var.map_tags` | Applies all key-value tag pairs from the map variable |

> ⚠️ **Important:** `var.aws_instance[1]` always picks the **second** item in the list (index starts at 0).
> So from `["t2.micro", "t2.small", "t2.medium"]` → it picks **`t2.small`**

---

### 🔷 `variables.tf` — Variable Declarations

```hcl
variable "region" {
  type = string
}

variable "aws_instance" {
  type = list(string)
}

variable "resource" {
  type    = number
  default = 2
}

variable "map_tags" {
  type = map(string)
}

variable "ami" {
  type = string
}
```

**How it works:**

| Variable | Type | Purpose | Default |
|----------|------|---------|---------|
| `region` | string | AWS region to deploy | None (required) |
| `aws_instance` | list(string) | List of instance types | None (required) |
| `resource` | number | How many EC2 instances to create | `2` |
| `map_tags` | map(string) | Key-value pairs for AWS tags | None (required) |
| `ami` | string | AMI ID for the EC2 instance | None (required) |

> 💡 Variables declared here are like **empty containers** — they get filled in by the `.tfvars` file at runtime.

---

### 🔷 `dev.tfvars` — Variable Values for Dev Environment

```hcl
region       = "us-east-1"
aws_instance = ["t2.micro", "t2.small", "t2.medium"]
ami          = "ami-0532be01f26a3de55"
resource     = 1
map_tags = {
  "Name"      = "Chandra-Dev"
  description = "This is for tags"
  Environment = "Dev"
  Project     = "Terraform"
}
```

**How it works:**

- This file **fills in** all the variable values defined in `variables.tf`
- `resource = 1` → Only **1 EC2 instance** will be created in Dev
- `aws_instance[1]` → From the list, index 1 = **`t2.small`**
- `map_tags` → These become the **AWS resource tags** on your EC2 instance

---

### ▶️ How to Run for Dev (PowerShell)

```powershell
# Step 1: Initialize Terraform (downloads AWS provider)
terraform init

# Step 2: Preview what will be created
terraform plan -var-file="dev.tfvars"

# Step 3: Apply / Create the resources
terraform apply -var-file="dev.tfvars"

# Step 4: Destroy when done
terraform destroy -var-file="dev.tfvars"
```

### 📤 Sample Output for Dev

```
Terraform will perform the following actions:

  # aws_instance.my-test[0] will be created
  + resource "aws_instance" "my-test" {
      + ami                    = "ami-0532be01f26a3de55"
      + instance_type          = "t2.small"
      + count                  = 1
      + tags                   = {
          + "Environment" = "Dev"
          + "Name"        = "Chandra-Dev"
          + "Project"     = "Terraform"
          + "description" = "This is for tags"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

---

## 📌 Section 2 — Dev, UAT, and Prod Environments

### 🟢 `dev.tfvars` — Development

```hcl
region       = "us-east-1"
aws_instance = ["t2.micro", "t2.small", "t2.medium"]
ami          = "ami-0532be01f26a3de55"
resource     = 1
map_tags = {
  "Name"        = "Chandra-Dev"
  "description" = "This is for tags"
  "Environment" = "Dev"
  "Project"     = "Terraform"
}
```

**PowerShell — Run Dev:**
```powershell
terraform init
terraform plan  -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars" -auto-approve
```

**Sample Output — Dev:**
```
aws_instance.my-test[0]: Creating...
aws_instance.my-test[0]: Creation complete after 32s [id=i-0a1b2c3d4e5f60001]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Instance Type  : t2.small        ← Index [1] from the list
Region         : us-east-1
AMI            : ami-0532be01f26a3de55
Count          : 1
Tag Name       : Chandra-Dev
Environment    : Dev
```

---

### 🟡 `uat.tfvars` — User Acceptance Testing

```hcl
region       = "us-west-1"
aws_instance = ["t2.micro", "t2.small", "t2.medium"]
ami          = "ami-0532be01f26a3de55"
resource     = 2
map_tags = {
  "Name"        = "Chandra-UAT"
  "description" = "This is for tags"
  "Environment" = "UAT"
  "Project"     = "Terraform"
}
```

**PowerShell — Run UAT:**
```powershell
terraform init
terraform plan  -var-file="uat.tfvars"
terraform apply -var-file="uat.tfvars" -auto-approve
```

**Sample Output — UAT:**
```
aws_instance.my-test[0]: Creating...
aws_instance.my-test[1]: Creating...
aws_instance.my-test[0]: Creation complete after 30s [id=i-0a1b2c3d4e5f60002]
aws_instance.my-test[1]: Creation complete after 31s [id=i-0a1b2c3d4e5f60003]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Instance Type  : t2.small        ← Index [1] from the list
Region         : us-west-1
AMI            : ami-0532be01f26a3de55
Count          : 2
Tag Name       : Chandra-UAT
Environment    : UAT
```

---

### 🔴 `prod.tfvars` — Production

```hcl
region       = "eu-west-1"
aws_instance = ["t2.micro", "t2.small", "t2.medium"]
ami          = "ami-0532be01f26a3de55"
resource     = 3
map_tags = {
  "Name"        = "Chandra-Prod"
  "description" = "This is for tags"
  "Environment" = "Prod"
  "Project"     = "Terraform"
}
```

**PowerShell — Run Prod:**
```powershell
terraform init
terraform plan  -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars" -auto-approve
```

**Sample Output — Prod:**
```
aws_instance.my-test[0]: Creating...
aws_instance.my-test[1]: Creating...
aws_instance.my-test[2]: Creating...
aws_instance.my-test[0]: Creation complete after 28s [id=i-0a1b2c3d4e5f60004]
aws_instance.my-test[1]: Creation complete after 29s [id=i-0a1b2c3d4e5f60005]
aws_instance.my-test[2]: Creation complete after 30s [id=i-0a1b2c3d4e5f60006]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Instance Type  : t2.small        ← Index [1] from the list
Region         : eu-west-1
AMI            : ami-0532be01f26a3de55
Count          : 3
Tag Name       : Chandra-Prod
Environment    : Prod
```

---

### 📊 Environment Comparison Summary

| Environment | Region | Count | Instance Type | Tag Name |
|-------------|--------|-------|---------------|----------|
| Dev | us-east-1 | 1 | t2.small | Chandra-Dev |
| UAT | us-west-1 | 2 | t2.small | Chandra-UAT |
| Prod | eu-west-1 | 3 | t2.small | Chandra-Prod |

---

## 📌 Section 3 — Terraform Workspace Commands

Terraform **Workspaces** allow you to manage multiple environments (Dev, UAT, Prod) using the **same configuration files** but with **separate state files**.

---

### 🔧 All Workspace Commands

```powershell
# List all available workspaces
terraform workspace list

# Show current active workspace
terraform workspace show

# Create a new workspace
terraform workspace new dev
terraform workspace new uat
terraform workspace new prod

# Switch to a workspace
terraform workspace select dev
terraform workspace select uat
terraform workspace select prod

# Delete a workspace (must not be the active one)
terraform workspace delete uat
```

---

### 📤 Sample Output of Workspace Commands

```powershell
# terraform workspace list
  default
* dev        ← (* = currently active)
  uat
  prod

# terraform workspace show
dev

# terraform workspace new prod
Created and switched to workspace "prod"!
You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

---

### 🔄 Using Workspaces in `main.tf`

You can use `terraform.workspace` inside your code to automatically pick values per environment:

```hcl
locals {
  instance_count = {
    dev  = 1
    uat  = 2
    prod = 3
  }
  instance_name = {
    dev  = "Chandra-Dev"
    uat  = "Chandra-UAT"
    prod = "Chandra-Prod"
  }
}

resource "aws_instance" "my-test" {
  count         = local.instance_count[terraform.workspace]
  ami           = var.ami
  instance_type = var.aws_instance[1]
  tags = {
    Name        = local.instance_name[terraform.workspace]
    Environment = terraform.workspace
  }
}
```

**PowerShell — Run with Workspaces:**
```powershell
# Switch to Dev and apply
terraform workspace select dev
terraform apply -var-file="dev.tfvars"

# Switch to UAT and apply
terraform workspace select uat
terraform apply -var-file="uat.tfvars"

# Switch to Prod and apply
terraform workspace select prod
terraform apply -var-file="prod.tfvars"
```

---

### 📅 When to Use Workspaces vs `.tfvars` Files

| Scenario | Use Workspaces | Use `.tfvars` Files |
|----------|---------------|---------------------|
| Same config, different state | ✅ Yes | ✅ Yes |
| Slightly different resource values | ✅ Yes | ✅ Yes |
| Very different configs per env | ❌ No | ✅ Preferred |
| Quick team collaboration | ✅ Yes | ✅ Yes |
| CI/CD pipelines | ✅ Common | ✅ Very Common |
| Isolated state files per env | ✅ Built-in | ❌ Manual management |

> 💡 **Best Practice:** For small-to-medium teams, use `.tfvars` per environment. For larger setups with remote backends (like Terraform Cloud or S3), use **Workspaces** with separate state files.

---

## 📌 Section 4 — Provider + Resource + Output Block Explained

### 🔷 The Code

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t2.micro"
  tags = {
    name      = "web"
    terraform = "terraform"
  }
}

output "To-find_ip" {
  value       = aws_instance.web.public_ip
  description = "This is to find the ip address"
}
```

---

### 🔍 Block-by-Block Explanation

**1. Provider Block**
```hcl
provider "aws" {
  region = "us-east-1"
}
```
- Tells Terraform: *"I am working with AWS"*
- `region = "us-east-1"` — All resources will be created in the **US East (N. Virginia)** region
- Terraform downloads the AWS provider plugin during `terraform init`

---

**2. Resource Block**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t2.micro"
  tags = {
    name      = "web"
    terraform = "terraform"
  }
}
```

| Argument | Value | Explanation |
|----------|-------|-------------|
| `resource type` | `aws_instance` | Creates an **EC2 instance** on AWS |
| `resource name` | `web` | Local name used to reference this resource |
| `ami` | `ami-0532be01f26a3de55` | The machine image (OS) to use |
| `instance_type` | `t2.micro` | Small instance — **Free tier eligible** |
| `tags` | map of strings | Labels shown on the AWS console |

---

**3. Output Block**
```hcl
output "To-find_ip" {
  value       = aws_instance.web.public_ip
  description = "This is to find the ip address"
}
```

- After `terraform apply` completes, this **prints the Public IP** of the created EC2 instance
- `aws_instance.web.public_ip` — Reads the `public_ip` attribute from the resource we just created
- The output is shown **in the terminal** and also stored in the **Terraform state file**

---

### ▶️ How to Run (PowerShell)

```powershell
# Step 1: Initialize — Download AWS provider
terraform init

# Step 2: Plan — See what will be created
terraform plan

# Step 3: Apply — Actually create the EC2 instance
terraform apply -auto-approve

# Step 4: See all outputs
terraform output

# Step 5: See a specific output
terraform output To-find_ip

# Step 6: Destroy when done
terraform destroy -auto-approve
```

---

### 📤 Full Sample Output

```
Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                    = "ami-0532be01f26a3de55"
      + arn                    = (known after apply)
      + instance_type          = "t2.micro"
      + public_ip              = (known after apply)
      + tags                   = {
          + "name"      = "web"
          + "terraform" = "terraform"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

aws_instance.web: Creating...
aws_instance.web: Still creating... [10s elapsed]
aws_instance.web: Still creating... [20s elapsed]
aws_instance.web: Creation complete after 32s [id=i-0a1b2c3d4e5f67890]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

To-find_ip = "54.210.167.45"
```

> ✅ **`54.210.167.45`** — This is the **Public IP** of your newly created EC2 instance printed via the `output` block.

---

### 🔍 How to Use the Output Value

```powershell
# Get the IP directly in PowerShell and store it in a variable
$ip = terraform output -raw To-find_ip
Write-Host "My EC2 Public IP is: $ip"

# SSH into the instance using the output IP (if key pair is configured)
ssh -i "my-key.pem" ec2-user@$ip
```

---

## 🚀 Quick Reference — All Key Terraform Commands

```powershell
terraform init                          # Initialize project / download providers
terraform validate                      # Check config files for syntax errors
terraform fmt                           # Auto-format .tf files
terraform plan -var-file="dev.tfvars"   # Preview changes for Dev
terraform apply -var-file="dev.tfvars"  # Create/update resources for Dev
terraform apply -auto-approve           # Skip confirmation prompt
terraform destroy -var-file="dev.tfvars"# Destroy Dev resources
terraform output                        # Show all output values
terraform output To-find_ip             # Show specific output
terraform state list                    # List all resources in state
terraform workspace list                # List all workspaces
terraform workspace new dev             # Create new workspace
terraform workspace select prod         # Switch to Prod workspace
```

---

*Generated for Terraform AWS EC2 Multi-Environment Guide*
