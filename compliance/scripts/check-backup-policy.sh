#!/bin/bash

# Backup and Recovery Check (INF-003)
# This script checks the backup and recovery configurations for compliance

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Check for backup configurations in Terraform
check_terraform_backup() {
    local terraform_dir="$PROJECT_ROOT/terraform"
    local backup_found=false
    
    if [[ -d "$terraform_dir" ]]; then
        # Check for AWS backup solutions
        if grep -r "aws_backup_plan\|aws_backup_vault" "$terraform_dir" > /dev/null 2>&1; then
            echo "✓ AWS Backup configuration found"
            backup_found=true
        fi
        
        # Check for Azure Recovery Services
        if grep -r "azurerm_recovery_services_vault" "$terraform_dir" > /dev/null 2>&1; then
            echo "✓ Azure Recovery Services configuration found"
            backup_found=true
        fi
    fi
    
    return $([ "$backup_found" = true ] && echo 0 || echo 1)
}

# Check for backup and recovery configurations in Ansible
check_ansible_backup() {
    local ansible_dir="$PROJECT_ROOT/ansible"
    local backup_found=false
    
    if [[ -d "$ansible_dir" ]]; then
        # Check for backup related tasks
        if grep -r "backup\|restore\|snapshot" "$ansible_dir" > /dev/null 2>&1; then
            echo "✓ Backup/Restore tasks found in Ansible"
            backup_found=true
        fi
    fi
    
    return $([ "$backup_found" = true ] && echo 0 || echo 1)
}

# Main backup and recovery compliance check
main() {
    echo "Running backup and recovery compliance check (INF-003)..."
    local checks_passed=0
    local total_checks=0
    
    # Check Terraform configurations
    if check_terraform_backup; then
        ((checks_passed++))
    else
        echo "⚠ No backup configuration found in Terraform files"
    fi
    ((total_checks++))
    
    # Check Ansible configurations
    if check_ansible_backup; then
        ((checks_passed++))
    else
        echo "⚠ No backup configuration found in Ansible files"
    fi
    ((total_checks++))
    
    # Evaluate results
    if [[ $checks_passed -gt 0 ]]; then
        echo "✅ Backup and recovery compliance check PASSED ($checks_passed/$total_checks checks passed)"
        return 0
    else
        echo "❌ Backup and recovery compliance check FAILED (no backup configurations found)"
        return 1
    fi
}

# Execute main function
main "$@"
