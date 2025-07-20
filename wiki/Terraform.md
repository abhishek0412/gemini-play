# Terraform Infrastructure Guide

This guide covers the Terraform infrastructure components in the **gemini-play** project, including Azure resource deployment, best practices, and troubleshooting.

## 🎯 Overview

The Terraform configuration in this project demonstrates:

- **Azure Resource Management** - Resource groups and storage accounts
- **Infrastructure as Code** principles
- **State Management** best practices
- **Security Configuration** patterns
- **Compliance Integration** with policy checks

## 📁 Current Infrastructure

### Directory Structure

```
terraform/
└── main.tf    # Main Terraform configuration
```

### Resources Deployed

| Resource Type | Name | Purpose |
|---------------|------|---------|
| Resource Group | `gemini-play-rg` | Container for all resources |
| Storage Account | `geminiplaystorage` | General purpose storage |

## 🚀 Quick Start

### Prerequisites

```bash
# Install Terraform (macOS)
brew install terraform

# Install Terraform (Windows)
choco install terraform

# Verify installation
terraform version
```

### Azure Authentication

```bash
# Login to Azure
az login

# Set subscription (optional)
az account set --subscription "your-subscription-id"

# Verify authentication
az account show
```

### Deploy Infrastructure

```bash
# Navigate to Terraform directory
cd terraform

# Initialize Terraform
terraform init

# Review deployment plan
terraform plan

# Apply the infrastructure
terraform apply

# Confirm with 'yes' when prompted
```

### Clean Up

```bash
# Destroy all resources
terraform destroy

# Confirm with 'yes' when prompted
```

## 📋 Detailed Configuration

### main.tf Breakdown

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "gemini-play-rg"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name                     = "geminiplaystorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

## 🔒 Security Enhancements

### Current Security Issues

The current configuration has several security gaps that should be addressed:

#### 1. Storage Account Security

**Issues:**
- No HTTPS-only enforcement
- Missing encryption configuration
- No network access restrictions

**Recommended Fix:**
```hcl
resource "azurerm_storage_account" "storage" {
  name                     = "geminiplaystorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Security enhancements
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
  
  blob_properties {
    versioning_enabled       = true
    delete_retention_policy {
      days = 7
    }
  }
  
  network_rules {
    default_action = "Deny"
    ip_rules       = ["your.ip.address.here"]
  }
  
  tags = {
    Environment = "Development"
    Project     = "gemini-play"
  }
}
```

#### 2. Missing State Backend

**Issue:** No remote state backend configured

**Recommended Fix:**
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstatestorage"
    container_name      = "tfstate"
    key                 = "gemini-play.terraform.tfstate"
  }
}
```

## 🏗️ Advanced Infrastructure Patterns

### Multi-Environment Support

Create environment-specific configurations:

```bash
# Create environment directories
mkdir -p environments/{dev,staging,prod}

# Environment-specific variables
cat > environments/dev/terraform.tfvars << EOF
environment = "dev"
location    = "East US"
storage_sku = "Standard_LRS"
EOF

cat > environments/prod/terraform.tfvars << EOF
environment = "prod"
location    = "East US 2"
storage_sku = "Standard_ZRS"
EOF
```

### Variable Configuration

```hcl
# variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    Project   = "gemini-play"
    ManagedBy = "Terraform"
  }
}
```

### Output Configuration

```hcl
# outputs.tf
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.storage.name
}

output "storage_account_primary_key" {
  description = "Primary key of the storage account"
  value       = azurerm_storage_account.storage.primary_access_key
  sensitive   = true
}
```

## 📊 State Management

### Local State (Current)

The current setup uses local state files:

```bash
# State files created locally
terraform.tfstate
terraform.tfstate.backup
```

**⚠️ Warning:** Local state is not suitable for production or team environments.

### Remote State (Recommended)

#### Option 1: Azure Storage Backend

```bash
# Create state storage resources
az group create --name terraform-state-rg --location "East US"

az storage account create \
  --name terraformstatestorage \
  --resource-group terraform-state-rg \
  --location "East US" \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name terraformstatestorage
```

#### Option 2: Terraform Cloud

```hcl
terraform {
  cloud {
    organization = "your-org-name"
    
    workspaces {
      name = "gemini-play"
    }
  }
}
```

## 🧪 Testing and Validation

### Terraform Validation

```bash
# Format code
terraform fmt

# Validate configuration
terraform validate

# Check for security issues with tfsec
tfsec .

# Plan with specific variables
terraform plan -var-file="environments/dev/terraform.tfvars"
```

### Compliance Integration

The compliance framework checks Terraform configurations:

```bash
# Run Terraform-specific compliance checks
./compliance/scripts/check-iac-compliance.sh

# Run encryption compliance (currently fails)
./compliance/scripts/check-encryption.sh
```

## 🔄 CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Terraform CI/CD

on:
  push:
    paths: ['terraform/**']
  pull_request:
    paths: ['terraform/**']

jobs:
  terraform:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
    
    - name: Terraform Init
      run: terraform init
      working-directory: terraform
    
    - name: Terraform Validate
      run: terraform validate
      working-directory: terraform
    
    - name: Terraform Plan
      run: terraform plan
      working-directory: terraform
      env:
        ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
        ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
        ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
        ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
    
    - name: Run Compliance Checks
      run: ./compliance/scripts/check-iac-compliance.sh
```

## 📈 Monitoring and Observability

### Resource Monitoring

```hcl
resource "azurerm_monitor_diagnostic_setting" "storage" {
  name                       = "storage-diagnostics"
  target_resource_id         = azurerm_storage_account.storage.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }
}
```

### Cost Management

```hcl
resource "azurerm_consumption_budget_resource_group" "main" {
  name              = "gemini-play-budget"
  resource_group_id = azurerm_resource_group.rg.id

  amount     = 100
  time_grain = "Monthly"

  time_period {
    start_date = "2025-01-01T00:00:00Z"
    end_date   = "2025-12-31T23:59:59Z"
  }

  notification {
    enabled   = true
    threshold = 80.0
    operator  = "GreaterThan"
    
    contact_emails = [
      "admin@example.com"
    ]
  }
}
```

## 🛠️ Troubleshooting

### Common Issues

#### Authentication Errors

```bash
# Check current Azure context
az account show

# Re-authenticate if needed
az logout
az login
```

#### State Lock Issues

```bash
# Force unlock state (use with caution)
terraform force-unlock LOCK_ID

# Alternative: delete lock manually in Azure portal
```

#### Resource Naming Conflicts

```bash
# Check if storage account name is available
az storage account check-name --name geminiplaystorage
```

#### Permission Issues

```bash
# Check current user permissions
az role assignment list --assignee $(az account show --query user.name -o tsv)

# Assign Contributor role if needed
az role assignment create \
  --role "Contributor" \
  --assignee $(az account show --query user.name -o tsv) \
  --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### Debug Mode

```bash
# Enable detailed logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

terraform plan
```

## 🚀 Next Steps

### Immediate Improvements

1. **Add Security Configurations**
   - Enable HTTPS-only for storage
   - Configure network access rules
   - Add encryption settings

2. **Implement Remote State**
   - Set up Azure storage backend
   - Configure state locking

3. **Add Variables and Outputs**
   - Create `variables.tf`
   - Create `outputs.tf`
   - Support multiple environments

### Advanced Features

1. **Network Infrastructure**
   - Virtual networks and subnets
   - Network security groups
   - Load balancers

2. **Compute Resources**
   - Virtual machines
   - App services
   - Container instances

3. **Database Resources**
   - Azure SQL Database
   - Cosmos DB
   - Redis Cache

## 📚 Related Documentation

- **[[Bicep Templates|Bicep]]** - Azure-native infrastructure alternative
- **[[Compliance Framework|Compliance-Framework]]** - Policy validation
- **[[Security Policies|Security-Policies]]** - Security requirements
- **[[Deployment Guide|Deployment]]** - Production deployment strategies

---

*For Terraform-specific issues, check the [Terraform Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) or open an issue on GitHub.*
