# Terraform Complete Topics & Subtopics

---

## 1. Introduction to Terraform

- What is Terraform & IaC (Infrastructure as Code)
- Terraform vs other IaC tools (Ansible, Pulumi, CloudFormation)
- Terraform architecture (Core, Providers, State)
- Installation & setup

---

## 2. Terraform Basics

- HCL (HashiCorp Configuration Language) syntax
- Terraform files structure (`.tf`, `.tfvars`)
- `terraform init`, `plan`, `apply`, `destroy`
- Formatting & validation (`fmt`, `validate`)

---

## 3. Providers

- What are providers
- Configuring providers (AWS, Azure, GCP, etc.)
- Provider versioning & locking
- Multiple provider configurations (aliases)

---

## 4. Resources

- Resource block syntax
- Resource arguments & attributes
- Resource dependencies (implicit vs explicit)
- `depends_on` meta-argument
- Resource lifecycle (`create_before_destroy`, `prevent_destroy`, `ignore_changes`)

---

## 5. Variables

- Input variables (`variable` block)
- Variable types (string, number, bool, list, map, object, tuple)
- Default values & validation rules
- Passing variables (CLI, `.tfvars`, environment variables)
- Output values (`output` block)
- Local values (`locals`)

---

## 6. State Management

- What is Terraform state
- `terraform.tfstate` file
- Remote state backends (S3, Azure Blob, GCS, Terraform Cloud)
- State locking
- `terraform state` commands (list, show, mv, rm, pull, push)
- State import (`terraform import`)
- Sensitive data in state

---

## 7. Modules

- What are modules
- Creating reusable modules
- Module sources (local, Git, Terraform Registry)
- Module inputs & outputs
- Module versioning
- Root vs child modules

---

## 8. Data Sources

- `data` block syntax
- Using data sources to fetch existing resources
- Common data sources (AMI, VPC, IAM, etc.)

---

## 9. Expressions & Functions

- Conditional expressions (`condition ? true : false`)
- `for` expressions
- Splat expressions (`[*]`)
- Built-in functions (string, numeric, collection, filesystem, date/time, encoding, IP network)
- `dynamic` blocks
- `count` meta-argument
- `for_each` meta-argument

---

## 10. Terraform Workspaces

- What are workspaces
- Creating & switching workspaces
- Use cases (dev, staging, prod)
- Workspaces vs modules

---

## 11. Provisioners

- `local-exec` provisioner
- `remote-exec` provisioner
- `file` provisioner
- When to use vs avoid provisioners
- `null_resource`

---

## 12. Terraform CLI Advanced

- `terraform taint` & `terraform untaint`
- `terraform refresh`
- `terraform output`
- `terraform graph`
- `terraform console`
- `-target` flag
- `-replace` flag

---

## 13. Remote Backends & Collaboration

- Backend configuration
- Terraform Cloud / Terraform Enterprise
- Remote execution
- Team collaboration & locking

---

## 14. CI/CD Integration

- Terraform in GitHub Actions / GitLab CI / Jenkins
- Automated `plan` & `apply`
- Atlantis (pull request automation)
- Policy as Code (Sentinel, OPA)

---

## 15. Security & Best Practices

- Secrets management (Vault, AWS Secrets Manager)
- Least privilege for provider credentials
- `.gitignore` for Terraform files
- Sensitive variables & outputs
- Terraform code scanning (tfsec, checkov)

---

## 16. Testing Terraform

- `terraform validate`
- Linting with `tflint`
- Unit testing (Terratest)
- Integration testing
- End-to-end testing strategies

---

## 17. Terraform Registry & Ecosystem

- Public module registry
- Publishing modules
- Provider development basics
- CDK for Terraform (CDKTF)

---

## 18. Advanced Patterns

- Terragrunt (DRY Terraform)
- Monorepo vs multi-repo structure
- Multi-region & multi-account deployments
- Blue/Green & zero-downtime infrastructure changes
- Managing drift detection

---

*This document covers the full spectrum of Terraform topics from beginner to advanced.*
