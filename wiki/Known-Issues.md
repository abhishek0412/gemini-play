# Known Issues & Bug Reports

This page documents known issues, bugs, and improvement opportunities in the **gemini-play** project. Issues are categorized by severity and component.

## 🚨 Critical Issues

### [CRITICAL] Missing Terraform State Management
**Component**: Terraform Infrastructure  
**Severity**: Critical  
**Status**: Open  

**Description:**
The Terraform configuration lacks proper state management and backend configuration, which can lead to state conflicts and infrastructure drift in team environments.

**Impact:**
- Risk of corrupted or lost infrastructure state
- Cannot collaborate safely in teams
- No state locking mechanism
- Potential for resource conflicts

**Files Affected:**
- `terraform/main.tf`

**Recommended Fix:**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstatestorage"
    container_name      = "tfstate"
    key                 = "gemini-play.terraform.tfstate"
  }
}
```

**Steps to Resolve:**
1. Create Azure storage account for state
2. Configure backend in Terraform
3. Migrate existing state
4. Test with team members

---

### [CRITICAL] Storage Account Security Vulnerabilities
**Component**: Azure Infrastructure  
**Severity**: Critical  
**Status**: Open  

**Description:**
The Azure Storage Account created by Terraform lacks essential security configurations including HTTPS enforcement, encryption settings, and network access restrictions.

**Impact:**
- Data transmitted over insecure connections
- No network-level access controls
- Compliance violations (SEC-001 fails)
- Potential data breaches

**Files Affected:**
- `terraform/main.tf` (lines 19-25)

**Current Configuration Issues:**
- No `enable_https_traffic_only = true`
- Missing `min_tls_version`
- No network rules configured
- No blob retention policies

**Recommended Fix:**
```hcl
resource "azurerm_storage_account" "storage" {
  # ... existing configuration ...
  
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
  
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
  }
  
  network_rules {
    default_action = "Deny"
    ip_rules       = ["allowed.ip.ranges.here"]
  }
}
```

## ⚠️ High Priority Issues

### [HIGH] Project Name Inconsistency
**Component**: .NET Application  
**Severity**: High  
**Status**: Open  

**Description:**
Mismatch between project directory name (`gemini-play`) and the RootNamespace in the .csproj file (`gemini_darling`).

**Impact:**
- Confusing for developers
- Potential namespace conflicts
- Build and deployment inconsistencies

**Files Affected:**
- `gemini-play.csproj` (line 6)

**Current State:**
```xml
<RootNamespace>gemini_darling</RootNamespace>
```

**Recommended Fix:**
```xml
<RootNamespace>gemini_play</RootNamespace>
```

---

### [HIGH] Bicep Network Security Gaps
**Component**: Azure Bicep Templates  
**Severity**: High  
**Status**: Open  

**Description:**
The Bicep virtual network template lacks essential security configurations including Network Security Groups (NSGs), security rules, and DDoS protection.

**Impact:**
- Unprotected network traffic
- No subnet-level security
- Compliance failures
- Potential network attacks

**Files Affected:**
- `bicep/network.bicep`

**Missing Components:**
- Network Security Groups
- Security rules for subnets
- DDoS protection standard
- Service endpoints

**Recommended Additions:**
```bicep
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'gemini-play-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHTTPS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
}
```

## 🔶 Medium Priority Issues

### [MEDIUM] Incomplete GitIgnore Configuration
**Component**: Version Control  
**Severity**: Medium  
**Status**: Open  

**Description:**
The `.gitignore` file is missing entries for Terraform state files, infrastructure secrets, and compliance reports.

**Impact:**
- Sensitive files may be committed
- Large binary files in repository
- Secret exposure risks

**Files Affected:**
- `.gitignore`

**Missing Entries:**
```gitignore
# Terraform
*.tfstate
*.tfstate.backup
.terraform/
*.tfvars
*.tfplan

# Compliance Reports
compliance/reports/

# Infrastructure secrets
*.pem
*.key
secrets/
```

---

### [MEDIUM] Missing CI/CD Pipeline
**Component**: DevOps  
**Severity**: Medium  
**Status**: Open  

**Description:**
No automated build, test, or deployment pipeline configured for the project.

**Impact:**
- Manual deployment processes
- No automated testing
- Risk of deployment errors
- Slower development cycles

**Recommended Solution:**
Create `.github/workflows/ci-cd.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: 8.0.x
    
    - name: Test Application
      run: dotnet test
    
    - name: Run Compliance Checks
      run: ./compliance/scripts/compliance-checker.sh
```

---

### [MEDIUM] Compliance Check Failures
**Component**: Compliance Framework  
**Severity**: Medium  
**Status**: Partially Open  

**Description:**
Current compliance framework shows 2 out of 9 rules failing (77% compliance rate).

**Failing Rules:**
- **SEC-001**: Encryption compliance (no encryption configurations found)
- **INF-003**: Backup policies (no backup configurations found)

**Impact:**
- Compliance violations
- Audit failures
- Security risks

**Resolution Steps:**
1. Fix encryption configurations in Terraform/Bicep
2. Add backup policy definitions
3. Update compliance scripts if needed

## 🔵 Low Priority Issues

### [LOW] Placeholder Ansible Roles
**Component**: Configuration Management  
**Severity**: Low  
**Status**: Open  

**Description:**
All Ansible roles contain only debug tasks without actual configuration logic.

**Files Affected:**
- `ansible/roles/*/tasks/main.yml`

**Current State:**
```yaml
---
- name: Configure cache server
  debug:
    msg: "Configuring cache server {{ inventory_hostname }}"
```

**Impact:**
- Non-functional configuration management
- Misleading documentation
- Incomplete automation

**Recommended Action:**
Implement actual configuration tasks or remove placeholder roles.

---

### [LOW] Missing Unit Tests
**Component**: .NET Application  
**Severity**: Low  
**Status**: Open  

**Description:**
No unit tests or test projects configured for the .NET application.

**Impact:**
- No test coverage
- Risk of regressions
- Quality assurance gaps

**Recommended Solution:**
```bash
# Create test project
dotnet new xunit -n gemini-play.Tests
dotnet sln add gemini-play.Tests
```

## 📊 Issue Summary

| Severity | Count | Percentage |
|----------|-------|------------|
| Critical | 2 | 25% |
| High | 2 | 25% |
| Medium | 3 | 37.5% |
| Low | 2 | 12.5% |
| **Total** | **9** | **100%** |

## 🔄 Resolution Status

| Status | Count | Issues |
|--------|-------|--------|
| Open | 9 | All issues are currently open |
| In Progress | 0 | None |
| Resolved | 0 | None |

## 🛠️ Contributing Fixes

To contribute fixes for these issues:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b fix/issue-description`
3. **Implement the fix**
4. **Test thoroughly**
5. **Run compliance checks**: `./compliance/scripts/compliance-checker.sh`
6. **Submit a pull request**

### Pull Request Template

When submitting fixes, please use this template:

```markdown
## Fix Description
Brief description of the issue being fixed.

## Issues Addressed
- [ ] [CRITICAL] Issue Name (#issue-number)

## Changes Made
- List of specific changes
- Files modified
- Configuration updates

## Testing
- [ ] Compliance checks pass
- [ ] Manual testing completed
- [ ] No regressions introduced

## Additional Notes
Any additional context or considerations.
```

## 📈 Improvement Roadmap

### Phase 1: Critical Security (Week 1-2)
- [ ] Implement Terraform state backend
- [ ] Fix storage account security settings
- [ ] Add encryption configurations

### Phase 2: Infrastructure Hardening (Week 3-4)
- [ ] Add network security groups to Bicep
- [ ] Implement proper GitIgnore entries
- [ ] Fix project naming consistency

### Phase 3: Process Improvements (Week 5-6)
- [ ] Set up CI/CD pipeline
- [ ] Resolve compliance failures
- [ ] Add comprehensive testing

### Phase 4: Feature Completion (Week 7-8)
- [ ] Implement Ansible configurations
- [ ] Add monitoring and observability
- [ ] Documentation updates

## 📞 Support

For questions about these issues or to report new bugs:

- **GitHub Issues**: [Report a bug](https://github.com/abhishek0412/gemini-play/issues/new)
- **GitHub Discussions**: [Ask questions](https://github.com/abhishek0412/gemini-play/discussions)
- **Wiki**: Browse other documentation pages

---

*This page is automatically updated when new issues are discovered or existing issues are resolved.*
