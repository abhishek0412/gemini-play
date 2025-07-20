#!/bin/bash

# Encryption Compliance Check (SEC-001)
# Validates that data encryption at rest requirements are met

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Check for encryption configurations in Terraform files
check_terraform_encryption() {
    local terraform_dir="$PROJECT_ROOT/terraform"
    local encryption_found=false
    
    if [[ -d "$terraform_dir" ]]; then
        # Check for S3 bucket encryption
        if grep -r "server_side_encryption_configuration\|kms_key_id\|sse_algorithm" "$terraform_dir" >/dev/null 2>&1; then
            echo "✓ Found S3 encryption configuration in Terraform"
            encryption_found=true
        fi
        
        # Check for RDS encryption
        if grep -r "storage_encrypted.*true\|kms_key_id" "$terraform_dir" >/dev/null 2>&1; then
            echo "✓ Found RDS encryption configuration in Terraform"
            encryption_found=true
        fi
        
        # Check for EBS encryption
        if grep -r "encrypted.*true" "$terraform_dir" >/dev/null 2>&1; then
            echo "✓ Found EBS encryption configuration in Terraform"
            encryption_found=true
        fi
    fi
    
    return $([ "$encryption_found" = true ] && echo 0 || echo 1)
}

# Check for encryption configurations in Bicep files
check_bicep_encryption() {
    local bicep_dir="$PROJECT_ROOT/bicep"
    local encryption_found=false
    
    if [[ -d "$bicep_dir" ]]; then
        # Check for storage account encryption
        if grep -r "supportsHttpsTrafficOnly.*true\|encryption" "$bicep_dir" >/dev/null 2>&1; then
            echo "✓ Found storage encryption configuration in Bicep"
            encryption_found=true
        fi
    fi
    
    return $([ "$encryption_found" = true ] && echo 0 || echo 1)
}

# Check for encryption configurations in Ansible
check_ansible_encryption() {
    local ansible_dir="$PROJECT_ROOT/ansible"
    local encryption_found=false
    
    if [[ -d "$ansible_dir" ]]; then
        # Check for vault usage or encryption tasks
        if grep -r "ansible-vault\|encrypt\|ssl\|tls" "$ansible_dir" >/dev/null 2>&1; then
            echo "✓ Found encryption/security configuration in Ansible"
            encryption_found=true
        fi
    fi
    
    return $([ "$encryption_found" = true ] && echo 0 || echo 1)
}

# Main encryption compliance check
main() {
    echo "Running encryption compliance check (SEC-001)..."
    local checks_passed=0
    local total_checks=0
    
    # Check Terraform configurations
    if check_terraform_encryption; then
        ((checks_passed++))
    else
        echo "⚠ No encryption configuration found in Terraform files"
    fi
    ((total_checks++))
    
    # Check Bicep configurations
    if check_bicep_encryption; then
        ((checks_passed++))
    else
        echo "⚠ No encryption configuration found in Bicep files"
    fi
    ((total_checks++))
    
    # Check Ansible configurations
    if check_ansible_encryption; then
        ((checks_passed++))
    else
        echo "⚠ No encryption configuration found in Ansible files"
    fi
    ((total_checks++))
    
    # Evaluate results
    if [[ $checks_passed -gt 0 ]]; then
        echo "✅ Encryption compliance check PASSED ($checks_passed/$total_checks checks passed)"
        return 0
    else
        echo "❌ Encryption compliance check FAILED (no encryption configurations found)"
        return 1
    fi
}

# Execute main function
main "$@"
