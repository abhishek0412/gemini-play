#!/bin/bash

# Multi-Factor Authentication Compliance Check (SEC-002)
# Validates that MFA requirements are configured

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Check for MFA configurations in Terraform files
check_terraform_mfa() {
    local terraform_dir="$PROJECT_ROOT/terraform"
    local mfa_found=false
    
    if [[ -d "$terraform_dir" ]]; then
        # Check for IAM MFA requirements
        if grep -r "aws_iam.*mfa\|require_mfa\|mfa_delete" "$terraform_dir" >/dev/null 2>&1; then
            echo "✓ Found MFA configuration in Terraform IAM policies"
            mfa_found=true
        fi
        
        # Check for MFA on S3 buckets
        if grep -r "mfa_delete.*true" "$terraform_dir" >/dev/null 2>&1; then
            echo "✓ Found S3 MFA delete configuration in Terraform"
            mfa_found=true
        fi
        
        # Check for conditional access/MFA policies
        if grep -r "condition.*mfa\|aws:MultiFactorAuthPresent" "$terraform_dir" >/dev/null 2>&1; then
            echo "✓ Found conditional MFA policies in Terraform"
            mfa_found=true
        fi
    fi
    
    return $([ "$mfa_found" = true ] && echo 0 || echo 1)
}

# Check for MFA configurations in Bicep files
check_bicep_mfa() {
    local bicep_dir="$PROJECT_ROOT/bicep"
    local mfa_found=false
    
    if [[ -d "$bicep_dir" ]]; then
        # Check for Azure AD conditional access or MFA policies
        if grep -r "conditionalAccess\|mfaRequired\|strongAuthentication" "$bicep_dir" >/dev/null 2>&1; then
            echo "✓ Found MFA configuration in Bicep templates"
            mfa_found=true
        fi
    fi
    
    return $([ "$mfa_found" = true ] && echo 0 || echo 1)
}

# Check for MFA configurations in Ansible
check_ansible_mfa() {
    local ansible_dir="$PROJECT_ROOT/ansible"
    local mfa_found=false
    
    if [[ -d "$ansible_dir" ]]; then
        # Check for MFA or 2FA related tasks
        if grep -r "mfa\|2fa\|two.*factor\|totp" "$ansible_dir" >/dev/null 2>&1; then
            echo "✓ Found MFA configuration in Ansible playbooks"
            mfa_found=true
        fi
    fi
    
    return $([ "$mfa_found" = true ] && echo 0 || echo 1)
}

# Check for GitHub repository security settings
check_github_mfa() {
    local github_found=false
    
    # Check if this is a GitHub repository
    if [[ -d "$PROJECT_ROOT/.git" ]]; then
        local remote_url=$(git -C "$PROJECT_ROOT" remote get-url origin 2>/dev/null || echo "")
        
        if [[ "$remote_url" =~ github\.com ]]; then
            echo "✓ GitHub repository detected - MFA should be enforced at organization level"
            github_found=true
        fi
    fi
    
    return $([ "$github_found" = true ] && echo 0 || echo 1)
}

# Main MFA compliance check
main() {
    echo "Running MFA compliance check (SEC-002)..."
    local checks_passed=0
    local total_checks=0
    
    # Check Terraform configurations
    if check_terraform_mfa; then
        ((checks_passed++))
    else
        echo "⚠ No MFA configuration found in Terraform files"
    fi
    ((total_checks++))
    
    # Check Bicep configurations
    if check_bicep_mfa; then
        ((checks_passed++))
    else
        echo "⚠ No MFA configuration found in Bicep files"
    fi
    ((total_checks++))
    
    # Check Ansible configurations
    if check_ansible_mfa; then
        ((checks_passed++))
    else
        echo "⚠ No MFA configuration found in Ansible files"
    fi
    ((total_checks++))
    
    # Check GitHub repository settings
    if check_github_mfa; then
        ((checks_passed++))
    else
        echo "⚠ Not a GitHub repository or no MFA enforcement detected"
    fi
    ((total_checks++))
    
    # Evaluate results
    if [[ $checks_passed -gt 0 ]]; then
        echo "✅ MFA compliance check PASSED ($checks_passed/$total_checks checks passed)"
        echo "📝 Note: Verify MFA is actually enabled in your cloud provider console"
        return 0
    else
        echo "❌ MFA compliance check FAILED (no MFA configurations found)"
        echo "📋 Recommendation: Implement MFA policies in your infrastructure code"
        return 1
    fi
}

# Execute main function
main "$@"
