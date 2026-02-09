# Day 3 - Terraform Advanced Concepts

## Table of Contents
1. [Multi-Region Provider Configuration with Dependencies](#multi-region-provider-configuration)
2. [Lifecycle Rules](#lifecycle-rules)
3. [Parallelism in Terraform](#parallelism)
4. [Replace Resources](#replace-resources)
5. [Drift Detection](#drift-detection)
6. [Refresh-Only Mode](#refresh-only-mode)

---

## 1. Multi-Region Provider Configuration with Dependencies

### Code Explanation
```hcl
provider "aws" { 
  region = "us-east-1" 
} 

resource "aws_instance" "mydemo-test" { 
  ami           = "ami-06f5f29d1fe41ea03" 
  instance_type = "t2.micro" 
  depends_on    = [aws_instance.mydemo-test-1] 
 
  tags = { 
    Name = "Us-east-1" 
  } 
} 

provider "aws" { 
  region = "us-east-2" 
  alias  = "us-east" 
} 

resource "aws_instance" "mydemo-test-1" { 
  provider      = aws.us-east 
  ami           = "ami-03ea746da1a2e36e7" 
  instance_type = "t2.micro" 
 
  tags = { 
    Name = "east2-application" 
  } 
}
```

### How It Works

1. **Multiple Providers**: You can define multiple instances of the same provider (AWS in this case) for different regions
2. **Default Provider**: The first provider without an `alias` becomes the default (us-east-1)
3. **Aliased Provider**: The second provider has `alias = "us-east"` for us-east-2 region
4. **Provider Reference**: Resources use `provider = aws.us-east` to specify which provider to use
5. **Dependencies**: `depends_on` ensures `mydemo-test-1` is created before `mydemo-test`

### Execution Flow
```
1. Terraform reads both provider configurations
2. Creates EC2 instance in us-east-2 first (mydemo-test-1)
3. Then creates EC2 instance in us-east-1 (mydemo-test)
```

### Example Output
```bash
$ terraform plan

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.mydemo-test will be created
  + resource "aws_instance" "mydemo-test" {
      + ami                          = "ami-06f5f29d1fe41ea03"
      + instance_type                = "t2.micro"
      + region                       = "us-east-1"
      + tags                         = {
          + "Name" = "Us-east-1"
        }
    }

  # aws_instance.mydemo-test-1 will be created
  + resource "aws_instance" "mydemo-test-1" {
      + ami                          = "ami-03ea746da1a2e36e7"
      + instance_type                = "t2.micro"
      + region                       = "us-east-2"
      + tags                         = {
          + "Name" = "east2-application"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

```bash
$ terraform apply -auto-approve

aws_instance.mydemo-test-1: Creating...
aws_instance.mydemo-test-1: Still creating... [10s elapsed]
aws_instance.mydemo-test-1: Creation complete after 45s [id=i-0a1b2c3d4e5f6g7h8]
aws_instance.mydemo-test: Creating...
aws_instance.mydemo-test: Still creating... [10s elapsed]
aws_instance.mydemo-test: Creation complete after 42s [id=i-0x9y8z7w6v5u4t3s2]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

### Use Cases
- Multi-region deployments for disaster recovery
- Cross-region resource dependencies
- Deploying resources in different regions for latency optimization

---

## 2. Lifecycle Rules

### What is Lifecycle?

Lifecycle meta-arguments control how Terraform creates, updates, and destroys resources. They provide fine-grained control over resource management.

### Types of Lifecycle Rules

#### 2.1 `prevent_destroy`
```hcl
resource "aws_instance" "production_server" {
  ami           = "ami-06f5f29d1fe41ea03"
  instance_type = "t2.micro"
  
  lifecycle {
    prevent_destroy = true
  }
  
  tags = {
    Name = "Production-Server"
  }
}
```

**How It Works**: Prevents accidental deletion of critical resources

**Example Output**:
```bash
$ terraform destroy

Error: Instance cannot be destroyed

  on main.tf line 5:
   5: resource "aws_instance" "production_server" {

Resource aws_instance.production_server has lifecycle.prevent_destroy set,
but the plan calls for this resource to be destroyed. To avoid this error
and continue with the plan, either disable lifecycle.prevent_destroy or
reduce the scope of the plan using the -target flag.
```

#### 2.2 `create_before_destroy`
```hcl
resource "aws_instance" "app_server" {
  ami           = "ami-06f5f29d1fe41ea03"
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true
  }
}
```

**How It Works**: Creates the new resource before destroying the old one (prevents downtime)

**Example Output**:
```bash
$ terraform apply

aws_instance.app_server: Creating...
aws_instance.app_server (new): Creation complete after 45s [id=i-new123456]
aws_instance.app_server (old): Destroying... [id=i-old654321]
aws_instance.app_server (old): Destruction complete after 30s

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

#### 2.3 `ignore_changes`
```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-06f5f29d1fe41ea03"
  instance_type = "t2.micro"
  
  lifecycle {
    ignore_changes = [tags]
  }
  
  tags = {
    Name = "WebServer"
  }
}
```

**How It Works**: Ignores changes to specified attributes (useful when external systems modify resources)

**Example Output**:
```bash
# Someone manually changed tags in AWS Console
$ terraform plan

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```

### Benefits of Lifecycle Rules

✅ **prevent_destroy**: Protects production databases, stateful resources  
✅ **create_before_destroy**: Zero-downtime deployments  
✅ **ignore_changes**: Works with external automation/manual changes  
✅ **replace_triggered_by**: Triggers recreation based on other resources  

---

## 3. Parallelism in Terraform

### Command
```bash
terraform apply -parallelism=20
```

### What is Parallelism?

By default, Terraform operates on up to **10 resources concurrently**. The `-parallelism` flag changes this limit.

### How It Works

```
Default (parallelism=10):
[Resource 1] [Resource 2] [Resource 3] ... [Resource 10] → Wait → [Resource 11]...

With parallelism=20:
[Resource 1] [Resource 2] ... [Resource 20] → More resources processed simultaneously
```

### Example Scenario

**Configuration**: Creating 50 EC2 instances

```hcl
resource "aws_instance" "servers" {
  count         = 50
  ami           = "ami-06f5f29d1fe41ea03"
  instance_type = "t2.micro"
  
  tags = {
    Name = "Server-${count.index}"
  }
}
```

### Example Output Comparison

**Default (parallelism=10)**:
```bash
$ terraform apply -auto-approve

aws_instance.servers[0]: Creating...
aws_instance.servers[1]: Creating...
aws_instance.servers[2]: Creating...
...
aws_instance.servers[9]: Creating...
# Waits for some to complete before starting more
aws_instance.servers[10]: Creating...
...

Apply complete! Resources: 50 added, 0 changed, 0 destroyed.
Execution time: 8 minutes 30 seconds
```

**With parallelism=20**:
```bash
$ terraform apply -parallelism=20 -auto-approve

aws_instance.servers[0]: Creating...
aws_instance.servers[1]: Creating...
...
aws_instance.servers[19]: Creating...
# Processing 20 resources simultaneously
aws_instance.servers[20]: Creating...
...

Apply complete! Resources: 50 added, 0 changed, 0 destroyed.
Execution time: 5 minutes 15 seconds
```

### Benefits

✅ **Faster Deployments**: Especially beneficial for large infrastructures  
✅ **API Optimization**: Better utilization of provider API rate limits  
✅ **Time Savings**: Can reduce deployment time by 30-50%  

### Considerations

⚠️ **API Rate Limits**: Too high can trigger provider rate limiting  
⚠️ **Resource Constraints**: May overwhelm your machine's resources  
⚠️ **Recommended Range**: 10-30 for most use cases  

---

## 4. Replace Resources (`-replace` flag)

### What is `-replace`?

Formerly known as `taint`, the `-replace` flag forces Terraform to destroy and recreate a specific resource, even if no configuration changes exist.

### Command Syntax
```bash
terraform plan -replace="aws_instance.mydemo-test"
terraform apply -replace="aws_instance.mydemo-test"
```

### When to Use

- Resource is in a corrupted state
- Manual changes broke the resource
- Need to test recreation logic
- Force update of user data or initialization scripts

### Example Scenario

```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-06f5f29d1fe41ea03"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"
  }
}
```

### Example Output

**Step 1: Plan with Replace**
```bash
$ terraform plan -replace="aws_instance.web_server"

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_instance.web_server will be replaced, as requested
-/+ resource "aws_instance" "web_server" {
      ~ id                           = "i-0123456789abcdef" -> (known after apply)
      ~ instance_state               = "running" -> (known after apply)
        ami                          = "ami-06f5f29d1fe41ea03"
        instance_type                = "t2.micro"
      # (30 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

**Step 2: Apply Replace**
```bash
$ terraform apply -replace="aws_instance.web_server" -auto-approve

aws_instance.web_server: Destroying... [id=i-0123456789abcdef]
aws_instance.web_server: Still destroying... [id=i-0123456789abcdef, 10s elapsed]
aws_instance.web_server: Destruction complete after 35s
aws_instance.web_server: Creating...
aws_instance.web_server: Still creating... [10s elapsed]
aws_instance.web_server: Creation complete after 42s [id=i-0fedcba9876543210]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

### Multiple Resources
```bash
$ terraform apply -replace="aws_instance.server1" -replace="aws_instance.server2"
```

---

## 5. Drift Detection

### What is Drift?

**Drift** occurs when the actual state of infrastructure differs from what's defined in Terraform configuration. This happens due to:
- Manual changes via AWS Console
- Changes by other automation tools
- External scripts or processes
- Team members making direct modifications

### How to Detect Drift

#### Method 1: `terraform plan`
```bash
$ terraform plan
```

**Example Output (Drift Detected)**:
```bash
$ terraform plan

aws_instance.mydemo-test: Refreshing state... [id=i-0123456789abcdef]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.mydemo-test will be updated in-place
  ~ resource "aws_instance" "mydemo-test" {
        id            = "i-0123456789abcdef"
      ~ instance_type = "t2.large" -> "t2.micro"  # Drift detected!
      ~ tags          = {
          ~ "Name"        = "Modified-Manually" -> "Us-east-1"
          + "Environment" = "Production"  # Someone added this tag
        }
        # (28 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
```

#### Method 2: `terraform plan -detailed-exitcode`
```bash
$ terraform plan -detailed-exitcode
```

**Exit Codes**:
- `0` = No changes (no drift)
- `1` = Error
- `2` = Changes detected (drift exists)

**Example Output**:
```bash
$ terraform plan -detailed-exitcode
# ... plan output ...
$ echo $?
2  # Drift detected!
```

#### Method 3: `terraform show`
```bash
$ terraform show
```

**Example Output**:
```bash
# aws_instance.mydemo-test:
resource "aws_instance" "mydemo-test" {
    ami                    = "ami-06f5f29d1fe41ea03"
    instance_type          = "t2.large"  # Shows actual state
    id                     = "i-0123456789abcdef"
    tags                   = {
        "Name"        = "Modified-Manually"
        "Environment" = "Production"
    }
    # ... other attributes
}
```

### Real-World Drift Scenario

**Scenario**: Someone manually changed instance type from t2.micro to t2.large in AWS Console

```bash
# Before manual change
$ terraform show | grep instance_type
    instance_type = "t2.micro"

# After manual change in AWS Console
$ terraform plan

aws_instance.mydemo-test: Refreshing state... [id=i-0123456789abcdef]

  # aws_instance.mydemo-test will be updated in-place
  ~ resource "aws_instance" "mydemo-test" {
      ~ instance_type = "t2.large" -> "t2.micro"  # Will revert to config
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

### Handling Drift

**Option 1**: Fix the drift (revert to Terraform config)
```bash
$ terraform apply  # Reverts instance_type back to t2.micro
```

**Option 2**: Accept the drift (update Terraform config)
```hcl
# Update your .tf file to match reality
resource "aws_instance" "mydemo-test" {
  instance_type = "t2.large"  # Update to match current state
  # ...
}
```

**Option 3**: Ignore specific changes
```hcl
resource "aws_instance" "mydemo-test" {
  instance_type = "t2.micro"
  
  lifecycle {
    ignore_changes = [instance_type]  # Ignore future instance_type changes
  }
}
```

---

## 6. Refresh-Only Mode

### Command
```bash
terraform plan -refresh-only
terraform apply -refresh-only
```

### What Does It Do?

`-refresh-only` updates Terraform's state file to match real infrastructure **without making any changes** to the actual resources. It's a read-only operation.

### How It Works

```
Normal terraform plan:
1. Refresh state from provider
2. Compare with configuration
3. Plan changes

terraform plan -refresh-only:
1. Refresh state from provider
2. Update state file only
3. NO changes to infrastructure
```

### When to Use

✅ Detect what has changed outside Terraform  
✅ Update state file after manual changes  
✅ Verify current infrastructure state  
✅ Safe way to sync state without modifying resources  

### Example Scenario

**Situation**: Someone manually added a tag to an EC2 instance

**Configuration**:
```hcl
resource "aws_instance" "mydemo-test" {
  ami           = "ami-06f5f29d1fe41ea03"
  instance_type = "t2.micro"
  
  tags = {
    Name = "Us-east-1"
  }
}
```

**Someone manually added tag**: `Environment = "Dev"` via AWS Console

### Example Output

**Step 1: Detect Changes with Refresh-Only Plan**
```bash
$ terraform plan -refresh-only

aws_instance.mydemo-test: Refreshing state... [id=i-0123456789abcdef]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the
last "terraform apply" which are not currently tracked:

  # aws_instance.mydemo-test has changed
  ~ resource "aws_instance" "mydemo-test" {
        id            = "i-0123456789abcdef"
      ~ tags          = {
          + "Environment" = "Dev"  # Was added manually
            "Name"        = "Us-east-1"
        }
        # (28 unchanged attributes hidden)
    }

This is a refresh-only plan, so Terraform will not take any actions to undo
these. If you were expecting these changes then you can apply this plan to
record the updated values in the Terraform state without changing any remote
objects.
```

**Step 2: Apply Refresh to Update State**
```bash
$ terraform apply -refresh-only -auto-approve

aws_instance.mydemo-test: Refreshing state... [id=i-0123456789abcdef]

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

# State file now reflects the "Environment" tag
```

**Step 3: Verify State Was Updated**
```bash
$ terraform show | grep -A3 tags
    tags = {
        "Environment" = "Dev"
        "Name"        = "Us-east-1"
    }
```

**Step 4: Next Plan Shows Drift**
```bash
$ terraform plan

  # aws_instance.mydemo-test will be updated in-place
  ~ resource "aws_instance" "mydemo-test" {
      ~ tags = {
          - "Environment" = "Dev" -> null  # Will remove the manual tag
            "Name"        = "Us-east-1"
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

### Comparison Table

| Command | Updates State? | Changes Infrastructure? | Use Case |
|---------|---------------|------------------------|----------|
| `terraform plan` | Yes (temporarily) | No (just shows plan) | See what changes are needed |
| `terraform apply` | Yes | Yes | Apply configuration changes |
| `terraform plan -refresh-only` | No | No | Preview state updates only |
| `terraform apply -refresh-only` | Yes | No | Update state to match reality |

### Benefits

✅ **Safe**: Never modifies actual infrastructure  
✅ **Visibility**: See what changed outside Terraform  
✅ **State Sync**: Update state file without risk  
✅ **Audit**: Track manual changes  

---

## Summary Cheat Sheet

| Concept | Command | Purpose |
|---------|---------|---------|
| **Multi-Region** | `provider "aws" { alias = "..." }` | Deploy across multiple regions |
| **Lifecycle** | `lifecycle { prevent_destroy = true }` | Control resource lifecycle |
| **Parallelism** | `terraform apply -parallelism=20` | Speed up large deployments |
| **Replace** | `terraform apply -replace="resource"` | Force resource recreation |
| **Drift Detection** | `terraform plan` | Detect manual changes |
| **Refresh-Only** | `terraform apply -refresh-only` | Update state without changes |

---

## Best Practices

1. **Always run `terraform plan`** before `apply`
2. **Use `prevent_destroy`** for critical resources (databases, production servers)
3. **Monitor for drift** regularly with scheduled `terraform plan`
4. **Use `-refresh-only`** to safely update state after manual changes
5. **Set appropriate parallelism** based on your infrastructure size (10-30)
6. **Document why** you use `-replace` (add comments)
7. **Use version control** for all Terraform configurations
8. **Enable state locking** to prevent concurrent modifications

---

## Common Issues & Solutions

### Issue 1: Resource Recreation Instead of Update
**Solution**: Use `lifecycle { create_before_destroy = true }`

### Issue 2: Accidental Deletion of Production Resources
**Solution**: Use `lifecycle { prevent_destroy = true }`

### Issue 3: Slow Deployments
**Solution**: Increase parallelism with `-parallelism=20`

### Issue 4: Drift Not Detected
**Solution**: Run `terraform plan` or `terraform apply -refresh-only`

### Issue 5: State Out of Sync
**Solution**: Use `terraform apply -refresh-only` to sync state safely

---

**End of Day 3 Lesson** 🎓
