# Day 4 - Terraform Learning Activity

## Table of Contents
1. [Terraform Import](#terraform-import)
2. [Terraform Debug Logs](#terraform-debug-logs)
3. [S3 Backend Configuration](#s3-backend-configuration)
4. [Required Providers](#required-providers)
5. [Terraform Variables - All Types](#terraform-variables---all-types)
6. [Complete Variable Example Explanation](#complete-variable-example-explanation)

---

## 1. Terraform Import

### What is Terraform Import?

Terraform import is used to bring **existing infrastructure** (resources created outside of Terraform) under Terraform management. This allows you to manage resources that were manually created or created by other tools.

### Import Block Syntax

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my-test" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t2.micro"
}

import {
  to = aws_instance.my-test
  id = "i-0b0ee8f9bba27a573"
}
```

### How It Works:
1. **to** = The resource address in your Terraform configuration
2. **id** = The actual resource ID from AWS (or other provider)

### Steps to Import:

**Step 1:** Write the resource block in your configuration (without all attributes initially)

**Step 2:** Add the import block

**Step 3:** Run terraform plan

```bash
terraform plan
```

### Sample Output:

```
Terraform will perform the following actions:

  # aws_instance.my-test will be imported
    resource "aws_instance" "my-test" {
        ami                                  = "ami-0532be01f26a3de55"
        arn                                  = "arn:aws:ec2:us-east-1:123456789012:instance/i-0b0ee8f9bba27a573"
        associate_public_ip_address          = true
        availability_zone                    = "us-east-1a"
        cpu_core_count                       = 1
        cpu_threads_per_core                 = 1
        disable_api_stop                     = false
        disable_api_termination              = false
        ebs_optimized                        = false
        get_password_data                    = false
        hibernation                          = false
        id                                   = "i-0b0ee8f9bba27a573"
        instance_initiated_shutdown_behavior = "stop"
        instance_state                       = "running"
        instance_type                        = "t2.micro"
        ipv6_address_count                   = 0
        ipv6_addresses                       = []
        monitoring                           = false
        placement_partition_number           = 0
        primary_network_interface_id         = "eni-0123456789abcdef0"
        private_dns                          = "ip-172-31-45-123.ec2.internal"
        private_ip                           = "172.31.45.123"
        public_dns                           = "ec2-54-123-45-67.compute-1.amazonaws.com"
        public_ip                            = "54.123.45.67"
        secondary_private_ips                = []
        security_groups                      = ["default"]
        source_dest_check                    = true
        subnet_id                            = "subnet-0abc123def456789"
        tags                                 = {}
        tags_all                             = {}
        tenancy                              = "default"
        vpc_security_group_ids               = ["sg-0123456789abcdef"]
    }

Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
```

**Step 4:** Apply the import

```bash
terraform apply
```

### Sample Apply Output:

```
aws_instance.my-test: Importing... [id=i-0b0ee8f9bba27a573]
aws_instance.my-test: Import complete [id=i-0b0ee8f9bba27a573]

Apply complete! Resources: 1 imported, 0 added, 0 changed, 0 destroyed.
```

### Legacy Import Command (Still Works):

```bash
terraform import aws_instance.my-test i-0b0ee8f9bba27a573
```

**Output:**
```
aws_instance.my-test: Importing from ID "i-0b0ee8f9bba27a573"...
aws_instance.my-test: Import prepared!
  Prepared aws_instance for import
aws_instance.my-test: Refreshing state... [id=i-0b0ee8f9bba27a573]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

---

## 2. Terraform Debug Logs

### What are Debug Logs?

Debug logs provide detailed information about Terraform's execution process, useful for:
- **Troubleshooting** errors
- **Understanding** what Terraform is doing behind the scenes
- **Debugging** provider issues
- **Performance** analysis

### Log Levels

Terraform supports 5 log levels (from least to most verbose):

| Level | Description |
|-------|-------------|
| `ERROR` | Only errors |
| `WARN` | Errors and warnings |
| `INFO` | General informational messages |
| `DEBUG` | Detailed debugging information |
| `TRACE` | Most verbose, shows every detail |

### Enabling Debug Logs

#### Method 1: Set Environment Variable (Linux/Mac)

```bash
export TF_LOG=DEBUG
terraform plan
```

#### Method 2: Set Environment Variable (Windows - PowerShell)

```powershell
$env:TF_LOG="DEBUG"
terraform plan
```

#### Method 3: Set Environment Variable (Windows - CMD)

```cmd
set TF_LOG=DEBUG
terraform plan
```

### Sample Output with DEBUG Level:

```
2025-02-11T10:15:23.456+0530 [INFO]  Terraform version: 1.7.0
2025-02-11T10:15:23.457+0530 [DEBUG] using github.com/hashicorp/go-tfe v1.37.0
2025-02-11T10:15:23.457+0530 [DEBUG] using github.com/hashicorp/hcl/v2 v2.19.1
2025-02-11T10:15:23.458+0530 [INFO]  Go runtime version: go1.21.5
2025-02-11T10:15:23.458+0530 [INFO]  CLI args: []string{"terraform", "plan"}
2025-02-11T10:15:23.459+0530 [DEBUG] Attempting to open CLI config file: /home/user/.terraformrc
2025-02-11T10:15:23.460+0530 [DEBUG] Loading CLI configuration from: /home/user/.terraformrc
2025-02-11T10:15:23.512+0530 [INFO]  Loading Terraform configuration from: .
2025-02-11T10:15:23.525+0530 [DEBUG] checking for provisioner in "."
2025-02-11T10:15:23.526+0530 [DEBUG] checking for provisioner in "/usr/bin"
2025-02-11T10:15:23.634+0530 [DEBUG] AWS Auth provider used: "SharedConfigCredentials"
2025-02-11T10:15:23.789+0530 [DEBUG] plugin: starting plugin: path=/usr/bin/terraform-provider-aws_v5.31.0
2025-02-11T10:15:24.012+0530 [DEBUG] plugin.terraform-provider-aws_v5.31.0: 2025-02-11T10:15:24.012+0530 plugin.terraform-provider-aws_v5.31.0: plugin address: unix /tmp/plugin123456789
2025-02-11T10:15:24.234+0530 [DEBUG] plugin.terraform-provider-aws_v5.31.0: AWS EC2 DescribeInstances
2025-02-11T10:15:24.567+0530 [DEBUG] Resource state read from backend: aws_instance.my-test
2025-02-11T10:15:24.789+0530 [INFO]  backend/local: plan calling Plan
2025-02-11T10:15:24.790+0530 [DEBUG] Building and walking apply graph
```

### Exporting Logs to a File - TF_LOG_PATH

#### Set Log Path (Linux/Mac):

```bash
export TF_LOG=TRACE
export TF_LOG_PATH=./terraform-debug.log
terraform plan
```

#### Set Log Path (Windows - PowerShell):

```powershell
$env:TF_LOG="TRACE"
$env:TF_LOG_PATH=".\terraform-debug.log"
terraform plan
```

#### Set Log Path (Windows - CMD):

```cmd
set TF_LOG=TRACE
set TF_LOG_PATH=terraform-debug.log
terraform plan
```

### Sample terraform-debug.log Content:

```
2025-02-11T10:20:15.123+0530 [INFO]  Terraform version: 1.7.0
2025-02-11T10:20:15.124+0530 [INFO]  Go runtime version: go1.21.5
2025-02-11T10:20:15.125+0530 [INFO]  CLI args: []string{"terraform", "plan"}
2025-02-11T10:20:15.234+0530 [TRACE] Preserving existing state lineage "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
2025-02-11T10:20:15.345+0530 [TRACE] backend/local: requesting state manager for workspace "default"
2025-02-11T10:20:15.456+0530 [TRACE] backend/local: state manager for workspace "default" will:
2025-02-11T10:20:15.456+0530 [TRACE]  - read initial snapshot from terraform.tfstate
2025-02-11T10:20:15.456+0530 [TRACE]  - write new snapshots to terraform.tfstate
2025-02-11T10:20:15.567+0530 [TRACE] backend/local: requesting state lock for workspace "default"
2025-02-11T10:20:15.678+0530 [TRACE] statemgr.Filesystem: preparing to manage state snapshots at terraform.tfstate
2025-02-11T10:20:15.789+0530 [TRACE] providercache.fillMetaCache: scanning directory .terraform/providers
2025-02-11T10:20:15.890+0530 [TRACE] getproviders.SearchLocalDirectory: found registry.terraform.io/hashicorp/aws v5.31.0 for linux_amd64 at .terraform/providers/registry.terraform.io/hashicorp/aws/5.31.0/linux_amd64
2025-02-11T10:20:16.001+0530 [DEBUG] Building and walking validate graph
2025-02-11T10:20:16.112+0530 [TRACE] vertex "provider[\\"registry.terraform.io/hashicorp/aws\\"]": starting visit (*terraform.NodeApplyableProvider)
```

### Disable Logging:

```bash
unset TF_LOG
unset TF_LOG_PATH
```

### Practical Use Cases:

1. **API Rate Limiting Issues**: Use TRACE to see exact API calls
2. **Provider Plugin Problems**: DEBUG shows plugin communication
3. **State Lock Issues**: TRACE reveals locking mechanism details
4. **Performance Troubleshooting**: Measure time between log entries

---

## 3. S3 Backend Configuration

### What is a Backend?

A **backend** determines where Terraform stores its **state file**. By default, it's stored locally in `terraform.tfstate`, but for team collaboration and safety, remote backends like S3 are preferred.

### Configuration Explained:

```hcl
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "my-bucket-432e456"
    key    = "my-test-instance.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "my-test" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t2.micro"
}
```

### How It Works:

| Parameter | Description |
|-----------|-------------|
| `bucket` | S3 bucket name where state file will be stored |
| `key` | Path/filename within the bucket for the state file |
| `region` | AWS region where the S3 bucket exists |

### Workflow:

1. **terraform init**: Terraform initializes and configures the S3 backend
2. **terraform plan/apply**: State is read from and written to S3
3. **State locking**: Can be enabled using DynamoDB (prevents concurrent modifications)

### Sample Output - terraform init:

```
Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v5.31.0...
- Installed hashicorp/aws v5.31.0 (signed by HashiCorp)

Terraform has been successfully initialized!
```

### S3 Backend with State Locking (DynamoDB):

```hcl
terraform {
  backend "s3" {
    bucket         = "my-bucket-432e456"
    key            = "my-test-instance.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### What is `use_lockfile = true`?

**Note**: `use_lockfile` is NOT a backend configuration parameter. It's related to **dependency lock files** (`.terraform.lock.hcl`).

The dependency lock file records the exact provider versions used. When you run `terraform init`, Terraform creates/updates this file.

**Usage in terraform block:**

```hcl
terraform {
  backend "s3" {
    bucket = "my-bucket-432e456"
    key    = "my-test-instance.tfstate"
    region = "us-east-1"
  }
  
  # This is separate from backend configuration
  # use_lockfile is not a valid terraform block argument
  # Lockfile is created automatically by default
}
```

**The `.terraform.lock.hcl` file** ensures:
- Same provider versions across team members
- Reproducible builds
- Protection against malicious provider updates

### Sample `.terraform.lock.hcl`:

```hcl
# This file is maintained automatically by "terraform init".
provider "registry.terraform.io/hashicorp/aws" {
  version     = "5.31.0"
  constraints = "~> 5.0"
  hashes = [
    "h1:abc123...",
    "zh:def456...",
  ]
}
```

---

## 4. Required Providers

### What are Required Providers?

The `required_providers` block specifies which providers your configuration needs, including version constraints.

```hcl
terraform {
  required_providers {
    mycloud = {
      source  = "mycorp/mycloud"
      version = "~> 1.0"
    }
  }
}
```

### Components Explained:

| Component | Description |
|-----------|-------------|
| `mycloud` | **Local name** for the provider (used in provider blocks) |
| `source` | **Namespace/Provider name** in the Terraform Registry |
| `version` | **Version constraint** for the provider |

### Version Constraint Operators:

| Operator | Meaning | Example | Matches |
|----------|---------|---------|---------|
| `=` | Exact version | `= 1.0.0` | Only 1.0.0 |
| `!=` | Exclude version | `!= 1.0.0` | Any except 1.0.0 |
| `>` | Greater than | `> 1.0.0` | 1.0.1, 1.1.0, 2.0.0 |
| `>=` | Greater or equal | `>= 1.0.0` | 1.0.0, 1.0.1, 2.0.0 |
| `<` | Less than | `< 2.0.0` | 1.9.9, 1.0.0 |
| `<=` | Less or equal | `<= 2.0.0` | 2.0.0, 1.9.9 |
| `~>` | Pessimistic | `~> 1.0` | 1.0, 1.1, 1.9 (not 2.0) |

### Real-World Example:

```hcl
terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "random" {}

provider "null" {}
```

### Sample terraform init Output:

```
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Finding hashicorp/random versions matching ">= 3.0"...
- Finding hashicorp/null versions matching "~> 3.2"...
- Installing hashicorp/aws v5.31.0...
- Installed hashicorp/aws v5.31.0 (signed by HashiCorp)
- Installing hashicorp/random v3.6.0...
- Installed hashicorp/random v3.6.0 (signed by HashiCorp)
- Installing hashicorp/null v3.2.2...
- Installed hashicorp/null v3.2.2 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
```

---

## 5. Terraform Variables - All Types

### Overview of Variable Types

Terraform supports the following variable types:

1. **string** - Single line of text
2. **number** - Numeric values (integer or float)
3. **bool** - true or false
4. **list** - Ordered collection of values
5. **set** - Unordered collection of unique values
6. **map** - Collection of key-value pairs
7. **object** - Complex structure with named attributes
8. **tuple** - Ordered collection of values with specific types

---

### 1. String Variable

```hcl
variable "region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-east-1"
}

variable "instance_name" {
  type    = string
  default = "my-web-server"
}

# Usage
provider "aws" {
  region = var.region
}

resource "aws_instance" "web" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t2.micro"
  
  tags = {
    Name = var.instance_name
  }
}
```

**Sample terraform plan Output:**
```
Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                    = "ami-0532be01f26a3de55"
      + instance_type          = "t2.micro"
      + tags                   = {
          + "Name" = "my-web-server"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

---

### 2. Number Variable

```hcl
variable "instance_count" {
  type        = number
  description = "Number of instances to create"
  default     = 3
}

variable "volume_size" {
  type    = number
  default = 20
}

# Usage
resource "aws_instance" "servers" {
  count         = var.instance_count
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t2.micro"
  
  root_block_device {
    volume_size = var.volume_size
  }
}
```

**Sample Output:**
```
Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_ids = [
      + (known after apply),
      + (known after apply),
      + (known after apply),
    ]
```

---

### 3. Bool Variable

```hcl
variable "enable_monitoring" {
  type        = bool
  description = "Enable detailed monitoring"
  default     = false
}

variable "public_access" {
  type    = bool
  default = true
}

# Usage
resource "aws_instance" "app" {
  ami                    = "ami-0532be01f26a3de55"
  instance_type          = "t2.micro"
  monitoring             = var.enable_monitoring
  associate_public_ip_address = var.public_access
}
```

**Sample Output:**
```
# aws_instance.app will be created
  + resource "aws_instance" "app" {
      + monitoring                   = false
      + associate_public_ip_address  = true
    }
```

---

### 4. List Variable

```hcl
variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "instance_types" {
  type    = list(string)
  default = ["t2.micro", "t2.small", "t2.medium"]
}

# Usage - Access by index
resource "aws_instance" "web" {
  count             = 3
  ami               = "ami-0532be01f26a3de55"
  instance_type     = var.instance_types[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "web-${count.index + 1}"
  }
}
```

**Sample Output:**
```
Terraform will perform the following actions:

  # aws_instance.web[0] will be created
  + instance_type     = "t2.micro"
  + availability_zone = "us-east-1a"
  + tags              = { "Name" = "web-1" }

  # aws_instance.web[1] will be created
  + instance_type     = "t2.small"
  + availability_zone = "us-east-1b"
  + tags              = { "Name" = "web-2" }

  # aws_instance.web[2] will be created
  + instance_type     = "t2.medium"
  + availability_zone = "us-east-1c"
  + tags              = { "Name" = "web-3" }

Plan: 3 to add, 0 to change, 0 to destroy.
```

---

### 5. Set Variable

```hcl
variable "allowed_ports" {
  type        = set(number)
  description = "Set of allowed ports"
  default     = [22, 80, 443, 3306]
}

# Usage
resource "aws_security_group" "web" {
  name = "web-sg"
  
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

**Sample Output:**
```
# aws_security_group.web will be created
  + resource "aws_security_group" "web" {
      + name   = "web-sg"
      + ingress {
          + from_port   = 22
          + to_port     = 22
          + protocol    = "tcp"
        }
      + ingress {
          + from_port   = 80
          + to_port     = 80
          + protocol    = "tcp"
        }
      + ingress {
          + from_port   = 443
          + to_port     = 443
          + protocol    = "tcp"
        }
      + ingress {
          + from_port   = 3306
          + to_port     = 3306
          + protocol    = "tcp"
        }
    }
```

---

### 6. Map Variable

```hcl
variable "common_tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default = {
    Environment = "Production"
    Project     = "WebApp"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
  }
}

variable "instance_ami" {
  type = map(string)
  default = {
    us-east-1 = "ami-0532be01f26a3de55"
    us-west-2 = "ami-0abcdef1234567890"
    eu-west-1 = "ami-0xyz9876543210abc"
  }
}

# Usage
resource "aws_instance" "app" {
  ami           = var.instance_ami["us-east-1"]
  instance_type = "t2.micro"
  tags          = var.common_tags
}
```

**Sample Output:**
```
# aws_instance.app will be created
  + resource "aws_instance" "app" {
      + ami           = "ami-0532be01f26a3de55"
      + instance_type = "t2.micro"
      + tags          = {
          + "CostCenter"  = "Engineering"
          + "Environment" = "Production"
          + "Owner"       = "DevOps Team"
          + "Project"     = "WebApp"
        }
    }
```

---

### 7. Object Variable

```hcl
variable "server_config" {
  type = object({
    instance_type = string
    volume_size   = number
    monitoring    = bool
    tags          = map(string)
  })
  
  default = {
    instance_type = "t2.medium"
    volume_size   = 50
    monitoring    = true
    tags = {
      Application = "Database"
      Tier        = "Backend"
    }
  }
}

# Usage
resource "aws_instance" "database" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = var.server_config.instance_type
  monitoring    = var.server_config.monitoring
  
  root_block_device {
    volume_size = var.server_config.volume_size
  }
  
  tags = var.server_config.tags
}
```

**Sample Output:**
```
# aws_instance.database will be created
  + resource "aws_instance" "database" {
      + ami           = "ami-0532be01f26a3de55"
      + instance_type = "t2.medium"
      + monitoring    = true
      + tags          = {
          + "Application" = "Database"
          + "Tier"        = "Backend"
        }
      + root_block_device {
          + volume_size = 50
        }
    }
```

---

### 8. Tuple Variable

```hcl
variable "server_specs" {
  type        = tuple([string, number, bool])
  description = "Server specifications: [type, count, monitoring]"
  default     = ["t2.micro", 3, true]
}

# Usage
resource "aws_instance" "servers" {
  count         = var.server_specs[1]
  ami           = "ami-0532be01f26a3de55"
  instance_type = var.server_specs[0]
  monitoring    = var.server_specs[2]
}
```

---

### 9. List of Objects (Complex Example)

```hcl
variable "instances" {
  type = list(object({
    name          = string
    instance_type = string
    volume_size   = number
    environment   = string
  }))
  
  default = [
    {
      name          = "web-server-1"
      instance_type = "t2.micro"
      volume_size   = 20
      environment   = "dev"
    },
    {
      name          = "web-server-2"
      instance_type = "t2.small"
      volume_size   = 30
      environment   = "staging"
    },
    {
      name          = "web-server-3"
      instance_type = "t2.medium"
      volume_size   = 50
      environment   = "prod"
    }
  ]
}

# Usage
resource "aws_instance" "multi" {
  count         = length(var.instances)
  ami           = "ami-0532be01f26a3de55"
  instance_type = var.instances[count.index].instance_type
  
  root_block_device {
    volume_size = var.instances[count.index].volume_size
  }
  
  tags = {
    Name        = var.instances[count.index].name
    Environment = var.instances[count.index].environment
  }
}
```

**Sample Output:**
```
Plan: 3 to add, 0 to change, 0 to destroy.

  # aws_instance.multi[0] will be created
  + instance_type = "t2.micro"
  + tags          = { "Name" = "web-server-1", "Environment" = "dev" }
  + root_block_device { volume_size = 20 }

  # aws_instance.multi[1] will be created
  + instance_type = "t2.small"
  + tags          = { "Name" = "web-server-2", "Environment" = "staging" }
  + root_block_device { volume_size = 30 }

  # aws_instance.multi[2] will be created
  + instance_type = "t2.medium"
  + tags          = { "Name" = "web-server-3", "Environment" = "prod" }
  + root_block_device { volume_size = 50 }
```

---

### Variable Input Methods

#### 1. Command Line

```bash
terraform plan -var="region=us-west-2" -var="instance_count=5"
```

#### 2. terraform.tfvars file

```hcl
# terraform.tfvars
region         = "us-west-2"
instance_count = 5
common_tags = {
  Environment = "Production"
  Project     = "MyApp"
}
```

#### 3. Environment Variables

```bash
export TF_VAR_region="us-west-2"
export TF_VAR_instance_count=5
terraform plan
```

#### 4. Interactive Prompt

If no default value is provided, Terraform will prompt:

```
var.region
  AWS region for resources

  Enter a value: us-east-1
```

---

## 6. Complete Variable Example Explanation

### The Code:

```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_instance" {
  type    = list(string)
  default = ["t2.micro", "t2.small", "t2.medium"]
}

variable "resource" {
  type    = number
  default = 2
}

variable "map_tags" {
  type = map(string)
  default = {
    "Name"      = "Chandra-${count.index + 1}"
    Environment = "Dev"
    Project     = "Terraform"
  }
}

variable "ami" {
  type    = string
  default = "ami-0532be01f26a3de55"
}

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

### ⚠️ Important Note: This Code Has an Error!

**Problem**: The variable `map_tags` uses `${count.index + 1}` in the default value, but `count.index` is only available **inside a resource block**, not in variable defaults.

### Corrected Version:

```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_instance" {
  type    = list(string)
  default = ["t2.micro", "t2.small", "t2.medium"]
}

variable "resource" {
  type    = number
  default = 2
}

variable "environment" {
  type    = string
  default = "Dev"
}

variable "project" {
  type    = string
  default = "Terraform"
}

variable "ami" {
  type    = string
  default = "ami-0532be01f26a3de55"
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "my-test" {
  count         = var.resource
  ami           = var.ami
  instance_type = var.aws_instance[1]
  
  tags = {
    Name        = "Chandra-${count.index + 1}"
    Environment = var.environment
    Project     = var.project
  }
}
```

### Step-by-Step Explanation:

#### 1. **Variable: region**
```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}
```
- **Type**: String
- **Value**: "us-east-1"
- **Usage**: `var.region` → Sets AWS provider region

#### 2. **Variable: aws_instance**
```hcl
variable "aws_instance" {
  type    = list(string)
  default = ["t2.micro", "t2.small", "t2.medium"]
}
```
- **Type**: List of strings
- **Value**: Three instance types
- **Usage**: `var.aws_instance[1]` → Selects **second element** = "t2.small"
  - Index 0 = "t2.micro"
  - Index 1 = "t2.small" ✅ **Used**
  - Index 2 = "t2.medium"

#### 3. **Variable: resource**
```hcl
variable "resource" {
  type    = number
  default = 2
}
```
- **Type**: Number
- **Value**: 2
- **Usage**: `count = var.resource` → Creates **2 instances**

#### 4. **Variable: ami**
```hcl
variable "ami" {
  type    = string
  default = "ami-0532be01f26a3de55"
}
```
- **Type**: String
- **Value**: AMI ID for Amazon Linux 2023
- **Usage**: `var.ami` → Specifies which image to use

#### 5. **Provider Configuration**
```hcl
provider "aws" {
  region = var.region
}
```
- Sets AWS region to "us-east-1"

#### 6. **Resource with count**
```hcl
resource "aws_instance" "my-test" {
  count         = var.resource                    # Creates 2 instances
  ami           = var.ami                         # Uses ami-0532be01f26a3de55
  instance_type = var.aws_instance[1]             # Uses t2.small
  
  tags = {
    Name        = "Chandra-${count.index + 1}"    # Instance 1: "Chandra-1", Instance 2: "Chandra-2"
    Environment = var.environment                  # "Dev"
    Project     = var.project                      # "Terraform"
  }
}
```

### Sample terraform plan Output:

```
Terraform will perform the following actions:

  # aws_instance.my-test[0] will be created
  + resource "aws_instance" "my-test" {
      + ami                          = "ami-0532be01f26a3de55"
      + instance_type                = "t2.small"
      + tags                         = {
          + "Environment" = "Dev"
          + "Name"        = "Chandra-1"
          + "Project"     = "Terraform"
        }
    }

  # aws_instance.my-test[1] will be created
  + resource "aws_instance" "my-test" {
      + ami                          = "ami-0532be01f26a3de55"
      + instance_type                = "t2.small"
      + tags                         = {
          + "Environment" = "Dev"
          + "Name"        = "Chandra-2"
          + "Project"     = "Terraform"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

### Sample terraform apply Output:

```
aws_instance.my-test[0]: Creating...
aws_instance.my-test[1]: Creating...
aws_instance.my-test[0]: Still creating... [10s elapsed]
aws_instance.my-test[1]: Still creating... [10s elapsed]
aws_instance.my-test[1]: Still creating... [20s elapsed]
aws_instance.my-test[0]: Still creating... [20s elapsed]
aws_instance.my-test[0]: Creation complete after 25s [id=i-0abc123def456789a]
aws_instance.my-test[1]: Creation complete after 26s [id=i-0xyz987fed654321b]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

### What Gets Created:

| Instance | Name | Type | AMI | Region |
|----------|------|------|-----|--------|
| my-test[0] | Chandra-1 | t2.small | ami-0532be01f26a3de55 | us-east-1 |
| my-test[1] | Chandra-2 | t2.small | ami-0532be01f26a3de55 | us-east-1 |

### Key Concepts Demonstrated:

1. ✅ **String variables** for region and AMI
2. ✅ **List variables** for instance types (with index access)
3. ✅ **Number variables** for resource count
4. ✅ **Map variables** for tags (corrected version)
5. ✅ **count meta-argument** for creating multiple resources
6. ✅ **count.index** for unique naming
7. ✅ **Variable interpolation** in strings

---

## Summary

This Day 4 learning activity covered:

1. ✅ **Terraform Import** - Bringing existing resources under Terraform management
2. ✅ **Debug Logs** - Troubleshooting with TF_LOG and TF_LOG_PATH
3. ✅ **S3 Backend** - Remote state storage and collaboration
4. ✅ **Required Providers** - Version management and dependency locking
5. ✅ **Variable Types** - All 8+ variable types with examples
6. ✅ **Complex Example** - Practical multi-variable configuration

### Next Steps:

- Practice importing existing AWS resources
- Experiment with different log levels for debugging
- Set up S3 backend with DynamoDB locking
- Create variables for your infrastructure
- Build multi-environment configurations using variables

---

**End of Day 4 Learning Activity** 🚀
