# Terraform Learning Guide

## Table of Contents
1. [Lifecycle Management in Terraform](#lifecycle-management)
2. [Targeted Resource Deletion](#targeted-resource-deletion)
3. [Terraform Format Command](#terraform-format)
4. [Terraform Validate Command](#terraform-validate)
5. [Running Multiple Commands](#multiple-commands)
6. [Code Examples Explained](#code-examples)
   - [Using count Meta-Argument](#example-1-count)
   - [Using for_each Meta-Argument](#example-2-for_each)
   - [Using depends_on Meta-Argument](#example-3-depends_on)

---

## 1. Lifecycle Management in Terraform {#lifecycle-management}

### What is Lifecycle Management?

Lifecycle management in Terraform allows you to customize how Terraform creates, updates, and destroys resources. It gives you fine-grained control over resource behavior during infrastructure changes.

### Uses of Lifecycle Management

#### a) **create_before_destroy**
- Creates a new resource before destroying the old one
- Prevents downtime during resource replacement
- Useful for resources that cannot have downtime

```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}
```

**Use Case:** When updating a production server where you need zero downtime.

#### b) **prevent_destroy**
- Prevents accidental deletion of critical resources
- Terraform will error if you try to destroy this resource
- Great for protecting databases and other critical infrastructure

```hcl
resource "aws_db_instance" "production" {
  allocated_storage = 20
  engine            = "mysql"
  
  lifecycle {
    prevent_destroy = true
  }
}
```

**Use Case:** Protecting production databases from accidental deletion.

#### c) **ignore_changes**
- Tells Terraform to ignore changes to specific attributes
- Useful when external systems modify resources
- Prevents Terraform from reverting manual changes

```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  tags = {
    Name = "My Instance"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
```

**Use Case:** When auto-scaling groups or external tools modify tags, and you don't want Terraform to overwrite them.

#### d) **replace_triggered_by**
- Forces resource replacement when specific resources or attributes change
- Available in Terraform 1.2+

```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  lifecycle {
    replace_triggered_by = [
      aws_security_group.example.id
    ]
  }
}
```

**Use Case:** When you need to recreate instances whenever security group changes.

### Summary of Lifecycle Uses

| Lifecycle Argument | Purpose | Common Use Case |
|-------------------|---------|-----------------|
| `create_before_destroy` | Create new before destroying old | Zero-downtime deployments |
| `prevent_destroy` | Protect from deletion | Production databases |
| `ignore_changes` | Ignore specific attribute changes | Externally managed attributes |
| `replace_triggered_by` | Force replacement on dependency change | Cascade updates |

---

## 2. Targeted Resource Deletion {#targeted-resource-deletion}

### Command to Delete Only Targeted Resource or Service

To delete a specific resource without affecting others, use the `-target` flag with `terraform destroy`.

### Syntax

```bash
terraform destroy -target=RESOURCE_TYPE.RESOURCE_NAME
```

### Examples

#### Delete a single EC2 instance:
```bash
terraform destroy -target=aws_instance.mydemo-test
```

#### Delete a specific S3 bucket:
```bash
terraform destroy -target=aws_s3_bucket.MY-ONE
```

#### Delete multiple specific resources:
```bash
terraform destroy -target=aws_instance.web_server -target=aws_s3_bucket.my_bucket
```

#### Delete a specific instance from a count-based resource:
```bash
terraform destroy -target='aws_instance.mydemo-test[0]'
```

#### Delete a specific instance from a for_each resource:
```bash
terraform destroy -target='aws_instance.mydemo-test["dev"]'
```

### Important Notes

⚠️ **Warnings:**
- Targeted destroy can leave your infrastructure in an inconsistent state
- Dependencies may break if you destroy a resource that others depend on
- Always review the plan before confirming
- Use with caution in production environments

### Best Practice

Always preview before destroying:
```bash
terraform plan -destroy -target=aws_instance.mydemo-test
terraform destroy -target=aws_instance.mydemo-test
```

---

## 3. Terraform Format Command {#terraform-format}

### What is `terraform fmt`?

The `terraform fmt` command formats Terraform configuration files to a canonical format and style. It ensures consistent formatting across your Terraform code.

### How to Use

```bash
# Format files in current directory
terraform fmt

# Format files recursively in all subdirectories
terraform fmt -recursive

# Check if files are formatted (doesn't modify files)
terraform fmt -check

# Show differences between original and formatted
terraform fmt -diff
```

### What Does It Do?

1. **Indentation**: Standardizes indentation (2 spaces)
2. **Alignment**: Aligns equals signs in assignments
3. **Spacing**: Removes unnecessary spaces
4. **Line breaks**: Organizes multi-line blocks consistently

### Before and After Example

**Before formatting:**
```hcl
resource "aws_instance" "example"{
ami="ami-12345678"
  instance_type   =    "t2.micro"
    tags={
Name="MyInstance"
    }
}
```

**After formatting:**
```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  tags = {
    Name = "MyInstance"
  }
}
```

### Common Options

| Option | Description | Example |
|--------|-------------|---------|
| `-recursive` | Format all subdirectories | `terraform fmt -recursive` |
| `-check` | Check if formatting is needed | `terraform fmt -check` |
| `-diff` | Show formatting differences | `terraform fmt -diff` |
| `-write=false` | Don't write changes (dry run) | `terraform fmt -write=false` |

### When to Use

- Before committing code to version control
- As part of CI/CD pipeline checks
- When onboarding new team members to ensure code consistency
- After making manual edits to configuration files

---

## 4. Terraform Validate Command {#terraform-validate}

### What is `terraform validate`?

The `terraform validate` command checks your Terraform configuration files for syntax errors and internal consistency. It validates the configuration without accessing remote services.

### How to Use

```bash
# Basic validation
terraform validate

# Validate with JSON output
terraform validate -json

# Validate without colored output
terraform validate -no-color
```

### What Does It Validate?

1. **Syntax Errors**: Checks for proper HCL syntax
2. **Argument Names**: Verifies correct argument names for resources
3. **Attribute References**: Checks if referenced attributes exist
4. **Required Arguments**: Ensures required arguments are present
5. **Type Constraints**: Validates variable types and values

### What It Does NOT Validate

❌ Does not check:
- Provider credentials
- If resources actually exist in cloud
- State file consistency
- Remote API accessibility
- Actual resource configurations in the cloud

### Examples

#### Successful Validation
```bash
$ terraform validate
Success! The configuration is valid.
```

#### Failed Validation
```bash
$ terraform validate

Error: Unsupported argument

  on main.tf line 5, in resource "aws_instance" "example":
   5:   invalid_argument = "value"

An argument named "invalid_argument" is not expected here.
```

### Typical Validation Workflow

```bash
# 1. Initialize Terraform (required before validate)
terraform init

# 2. Format your code
terraform fmt

# 3. Validate configuration
terraform validate

# 4. Plan your changes
terraform plan

# 5. Apply changes
terraform apply
```

### Use Cases

- **Pre-commit checks**: Validate before committing to Git
- **CI/CD pipelines**: Automated validation in build processes
- **Quick syntax check**: Fast feedback during development
- **Learning**: Understand configuration errors quickly

### Benefits

✅ Fast feedback loop
✅ No cloud credentials needed
✅ Catches errors before planning
✅ Free to run (no API calls)
✅ Works offline

---

## 5. Running Multiple Commands in Single Terminal {#multiple-commands}

### How to Use Multiple Commands

In a single terminal session, you can run multiple Terraform commands sequentially using different methods.

### Method 1: Semicolon Separator (;)

Runs commands one after another, regardless of success/failure.

```bash
terraform fmt ; terraform validate
```

**Behavior**: Runs both commands even if the first one fails.

### Method 2: AND Operator (&&)

Runs the second command only if the first succeeds.

```bash
terraform fmt && terraform validate
```

**Behavior**: If `terraform fmt` fails, `terraform validate` won't run.

### Method 3: OR Operator (||)

Runs the second command only if the first fails.

```bash
terraform validate || echo "Validation failed!"
```

**Behavior**: If validation succeeds, the echo command won't run.

### Common Command Chains

#### Complete Workflow Chain
```bash
terraform init && terraform fmt && terraform validate && terraform plan
```

#### Format and Validate with Status
```bash
terraform fmt -check && terraform validate && echo "All checks passed!"
```

#### Conditional Apply
```bash
terraform plan -out=tfplan && terraform apply tfplan
```

#### Full Deployment Chain
```bash
terraform init && \
terraform fmt -recursive && \
terraform validate && \
terraform plan -out=tfplan && \
terraform apply tfplan
```

### Examples Specific to Your Question

#### Example 1: Format then Validate
```bash
terraform fmt ; terraform validate
```
**What happens**: Formats all files, then validates configuration regardless of format success.

#### Example 2: Format then Validate (stop on error)
```bash
terraform fmt && terraform validate
```
**What happens**: Formats files, validates only if formatting succeeds.

#### Example 3: Complete Pre-deployment Check
```bash
terraform fmt -recursive && terraform validate && terraform plan
```
**What happens**: Formats all files recursively, validates if format succeeds, plans if validation succeeds.

### Multi-line Commands (Cleaner for Complex Workflows)

```bash
terraform init && \
  terraform fmt -recursive && \
  terraform validate && \
  terraform plan -out=plan.tfplan && \
  echo "Ready to apply!"
```

### Using Scripts for Reusable Workflows

Create a file `deploy.sh`:
```bash
#!/bin/bash

echo "Starting Terraform deployment..."

terraform init || exit 1
terraform fmt -recursive || exit 1
terraform validate || exit 1
terraform plan -out=tfplan || exit 1

echo "Plan created successfully. Review and run: terraform apply tfplan"
```

Make it executable and run:
```bash
chmod +x deploy.sh
./deploy.sh
```

### Comparison Table

| Operator | Symbol | Behavior | Use When |
|----------|--------|----------|----------|
| Sequential | `;` | Always runs next command | Independent commands |
| AND | `&&` | Runs next only if previous succeeds | Dependent workflow |
| OR | `||` | Runs next only if previous fails | Error handling |
| Pipe | `|` | Passes output to next command | Processing output |

---

## 6. Code Examples Explained {#code-examples}

---

### Example 1: Using `count` Meta-Argument {#example-1-count}

```hcl
provider "aws" { 
  region = "us-east-1" 
} 

resource "aws_instance" "mydemo-test" { 
  ami           = "ami-06f5f29d1fe41ea03" 
  instance_type = "t2.micro" 
  count         = 2 
 
  tags = { 
    Name = "mydemo-test-${count.index}" 
  } 
}
```

#### How It Works

1. **Provider Block**: Configures AWS provider to use `us-east-1` region
2. **count = 2**: Creates 2 identical EC2 instances
3. **count.index**: Provides an index (0, 1) for each instance
4. **Resource Naming**: Creates two instances with different names

#### What Gets Created

| Instance | Internal ID | Tag Name | count.index |
|----------|-------------|----------|-------------|
| 1st | `aws_instance.mydemo-test[0]` | `mydemo-test-0` | 0 |
| 2nd | `aws_instance.mydemo-test[1]` | `mydemo-test-1` | 1 |

#### Referencing Resources

```hcl
# Reference first instance
output "first_instance_id" {
  value = aws_instance.mydemo-test[0].id
}

# Reference second instance
output "second_instance_id" {
  value = aws_instance.mydemo-test[1].id
}

# Reference all instances
output "all_instance_ids" {
  value = aws_instance.mydemo-test[*].id
}
```

#### When to Use `count`

✅ **Use count when:**
- Creating identical resources
- You need a specific number of resources
- Resources are simple duplicates
- You want numeric indexing (0, 1, 2...)

❌ **Don't use count when:**
- Resources need different configurations
- You need named instances (use `for_each` instead)
- The number might change (removing middle items causes issues)

#### Limitations of count

**Problem with removing middle items:**
```hcl
# If you change count from 3 to 2:
count = 2  # Changed from 3

# Terraform destroys instance[2] (the last one)
# But if you wanted to remove instance[1], you're out of luck!
```

---

### Example 2: Using `for_each` Meta-Argument {#example-2-for_each}

```hcl
provider "aws" { 
  region = "us-east-1" 
} 

resource "aws_instance" "mydemo-test" { 
  for_each      = toset(["dev", "mo", "prod"]) 
  ami           = "ami-06f5f29d1fe41ea03" 
  instance_type = "t2.micro" 
 
  tags = { 
    Name = "mydemo-test-${each.key}" 
  } 
}
```

#### How It Works

1. **toset()**: Converts the list to a set (removes duplicates, orders alphabetically)
2. **for_each**: Iterates over each element in the set
3. **each.key**: Current element value ("dev", "mo", or "prod")
4. **Creates 3 instances**: One for each environment

#### What Gets Created

| Instance | Internal ID | Tag Name | each.key |
|----------|-------------|----------|----------|
| Dev | `aws_instance.mydemo-test["dev"]` | `mydemo-test-dev` | "dev" |
| Mo | `aws_instance.mydemo-test["mo"]` | `mydemo-test-mo` | "mo" |
| Prod | `aws_instance.mydemo-test["prod"]` | `mydemo-test-prod` | "prod" |

#### each.key vs each.value

```hcl
# For a set: each.key == each.value
for_each = toset(["dev", "prod"])
# each.key = "dev", each.value = "dev"

# For a map: each.key is the key, each.value is the value
for_each = {
  dev  = "t2.micro"
  prod = "t2.large"
}
# each.key = "dev", each.value = "t2.micro"
```

#### Advanced for_each with Map

```hcl
resource "aws_instance" "mydemo-test" { 
  for_each = {
    dev  = "t2.micro"
    staging = "t2.small"
    prod = "t2.large"
  }
  
  ami           = "ami-06f5f29d1fe41ea03" 
  instance_type = each.value  # Different instance types!
 
  tags = { 
    Name        = "mydemo-test-${each.key}"
    Environment = each.key
  } 
}
```

#### Referencing for_each Resources

```hcl
# Reference specific instance
output "dev_instance_id" {
  value = aws_instance.mydemo-test["dev"].id
}

# Reference all instances as a map
output "all_instances" {
  value = {
    for k, instance in aws_instance.mydemo-test : k => instance.id
  }
}
```

#### When to Use `for_each`

✅ **Use for_each when:**
- Creating resources for different environments
- Each resource needs a meaningful identifier
- You might add/remove resources in the middle
- Resources have different configurations
- You need named access (not numeric)

❌ **Don't use for_each when:**
- You just need a fixed number of identical resources
- Simple counting is sufficient

#### Advantages Over count

**Adding/Removing Items:**
```hcl
# Remove "mo" environment
for_each = toset(["dev", "prod"])  # Just removed "mo"

# Terraform only destroys the "mo" instance
# "dev" and "prod" instances are untouched!

# With count, removing middle item would recreate resources!
```

---

### Example 3: Using `depends_on` Meta-Argument {#example-3-depends_on}

```hcl
provider "aws" { 
  region = "us-east-1" 
} 

resource "aws_instance" "mydemo-test" { 
  ami           = "ami-06f5f29d1fe41ea03" 
  instance_type = "t2.micro" 
 
  tags = { 
    Name = "mydemo-test" 
  } 
} 
 
resource "aws_s3_bucket" "MY-ONE" { 
  bucket     = "my-test" 
  depends_on = [aws_instance.mydemo-test] 
}
```

#### How It Works

1. **Explicit Dependency**: `depends_on` creates a manual dependency
2. **Creation Order**: Terraform creates EC2 instance FIRST, then S3 bucket
3. **Destruction Order**: Terraform destroys S3 bucket FIRST, then EC2 instance (reverse)

#### Dependency Flow

```
Creation Order:
1. aws_instance.mydemo-test (created first)
   ↓
2. aws_s3_bucket.MY-ONE (created after instance)

Destruction Order:
1. aws_s3_bucket.MY-ONE (destroyed first)
   ↓
2. aws_instance.mydemo-test (destroyed after bucket)
```

#### Implicit vs Explicit Dependencies

**Implicit Dependency (Automatic):**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  subnet_id     = aws_subnet.main.id  # References subnet
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

# Terraform automatically knows:
# Create VPC → Create Subnet → Create Instance
```

**Explicit Dependency (Manual):**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  
  depends_on = [aws_s3_bucket.config]  # Manual dependency
}

resource "aws_s3_bucket" "config" {
  bucket = "my-config-bucket"
}

# Even though web instance doesn't reference the bucket,
# Terraform creates bucket first
```

#### When to Use `depends_on`

✅ **Use depends_on when:**
- There's a logical dependency not expressed in code
- Resources need to be created in specific order
- External systems need time to propagate changes
- You're working with eventual consistency

❌ **Don't use depends_on when:**
- There's already a reference (implicit dependency exists)
- You're overusing it (makes code complex)

#### Real-World Use Cases

**Use Case 1: IAM Role Propagation**
```hcl
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  # ... role configuration
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "my_function" {
  function_name = "my-function"
  role          = aws_iam_role.lambda_role.arn
  
  # Ensure policy is attached before Lambda tries to use the role
  depends_on = [aws_iam_role_policy_attachment.lambda_policy]
}
```

**Use Case 2: Database and Application**
```hcl
resource "aws_db_instance" "database" {
  allocated_storage = 20
  engine            = "mysql"
  # ... database config
}

resource "aws_instance" "app_server" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  # Ensure database is ready before launching app
  depends_on = [aws_db_instance.database]
}
```

**Use Case 3: Networking Prerequisites**
```hcl
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_instance" "web" {
  ami           = "ami-12345678"
  subnet_id     = aws_subnet.public.id
  
  # Ensure internet routing is configured
  depends_on = [aws_route.internet_access]
}
```

#### Multiple Dependencies

```hcl
resource "aws_instance" "app" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  depends_on = [
    aws_db_instance.database,
    aws_s3_bucket.config,
    aws_iam_role.app_role
  ]
}
```

---

## Comparison: count vs for_each vs depends_on

| Feature | count | for_each | depends_on |
|---------|-------|----------|------------|
| **Purpose** | Create multiple copies | Create named resources | Control creation order |
| **Indexing** | Numeric (0, 1, 2) | Named (key-based) | N/A |
| **Flexibility** | Low | High | N/A |
| **Use for** | Identical resources | Environment-specific | Dependencies |
| **Removal** | Risky (reindexing) | Safe (by name) | N/A |

---

## Best Practices Summary

### 1. Lifecycle Management
- Use `prevent_destroy` for critical resources
- Use `create_before_destroy` for zero-downtime updates
- Document why you're using lifecycle blocks

### 2. Resource Management
- Prefer `for_each` over `count` for named resources
- Use `count` only for simple identical resources
- Always preview before targeted destroy

### 3. Command Workflow
- Always run: `init → fmt → validate → plan → apply`
- Use `&&` for dependent commands
- Automate with scripts for consistency

### 4. Dependencies
- Let Terraform handle implicit dependencies
- Use `depends_on` sparingly
- Document why explicit dependencies exist

---

## Quick Reference Commands

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Initialize working directory
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# Destroy specific resource
terraform destroy -target=resource_type.resource_name

# Complete workflow
terraform init && terraform fmt && terraform validate && terraform plan
```

---

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---

**Document Created**: February 2026  
**Purpose**: Terraform Learning Reference  
**Version**: 1.0
