#!/bin/bash

# Infrastructure as Code Compliance Check (INF-001)
# Validates that infrastructure follows IaC principles

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Check if infrastructure code exists and is properly structured
check_iac_structure() {
    local iac_found=false
    local structure_score=0
    
    # Check for Terraform
    if [[ -d "$PROJECT_ROOT/terraform" ]]; then
        echo "✓ Terraform directory found"
        iac_found=true
        ((structure_score++))
        
        # Check for proper Terraform structure
        if [[ -f "$PROJECT_ROOT/terraform/main.tf" ]]; then
            echo "  ✓ main.tf file exists"
            ((structure_score++))
        fi
        
        if [[ -f "$PROJECT_ROOT/terraform/variables.tf" ]]; then
            echo "  ✓ variables.tf file exists"
            ((structure_score++))
        fi
        
        if [[ -f "$PROJECT_ROOT/terraform/outputs.tf" ]]; then
            echo "  ✓ outputs.tf file exists"
            ((structure_score++))
        fi
    fi
    
    # Check for Bicep
    if [[ -d "$PROJECT_ROOT/bicep" ]]; then
        echo "✓ Bicep directory found"
        iac_found=true
        ((structure_score++))
        
        if find "$PROJECT_ROOT/bicep" -name "*.bicep" -type f | head -1 >/dev/null 2>&1; then
            echo "  ✓ Bicep template files exist"
            ((structure_score++))
        fi
    fi
    
    # Check for Ansible
    if [[ -d "$PROJECT_ROOT/ansible" ]]; then
        echo "✓ Ansible directory found"
        iac_found=true
        ((structure_score++))
        
        if [[ -d "$PROJECT_ROOT/ansible/roles" ]]; then
            echo "  ✓ Ansible roles directory exists"
            ((structure_score++))
        fi
    fi
    
    echo "IaC structure score: $structure_score"
    return $([ "$iac_found" = true ] && echo 0 || echo 1)
}

# Check for version control of infrastructure code
check_version_control() {
    local vc_compliant=false
    
    if [[ -d "$PROJECT_ROOT/.git" ]]; then
        echo "✓ Git version control detected"
        
        # Check if infrastructure files are tracked
        local tracked_files=0
        
        if git -C "$PROJECT_ROOT" ls-files | grep -E "terraform/.*\.tf$|bicep/.*\.bicep$|ansible/.*\.yml$" >/dev/null 2>&1; then
            tracked_files=$(git -C "$PROJECT_ROOT" ls-files | grep -E "terraform/.*\.tf$|bicep/.*\.bicep$|ansible/.*\.yml$" | wc -l)
            echo "  ✓ $tracked_files infrastructure files are version controlled"
            vc_compliant=true
        fi
        
        # Check for .gitignore with appropriate entries
        if [[ -f "$PROJECT_ROOT/.gitignore" ]]; then
            if grep -E "\.tfstate|\.tfvars|\.terraform/" "$PROJECT_ROOT/.gitignore" >/dev/null 2>&1; then
                echo "  ✓ Proper .gitignore entries for Terraform found"
            fi
        fi
    fi
    
    return $([ "$vc_compliant" = true ] && echo 0 || echo 1)
}

# Check for proper documentation
check_documentation() {
    local docs_found=false
    
    if [[ -f "$PROJECT_ROOT/README.md" ]]; then
        echo "✓ README.md exists"
        
        # Check if README contains infrastructure documentation
        if grep -iE "terraform|bicep|ansible|infrastructure" "$PROJECT_ROOT/README.md" >/dev/null 2>&1; then
            echo "  ✓ README contains infrastructure documentation"
            docs_found=true
        fi
    fi
    
    return $([ "$docs_found" = true ] && echo 0 || echo 1)
}

# Check for testing or validation
check_testing() {
    local testing_found=false
    
    # Check for Terraform validation
    if [[ -d "$PROJECT_ROOT/terraform" ]]; then
        # Look for validation scripts or GitHub Actions
        if [[ -d "$PROJECT_ROOT/.github/workflows" ]]; then
            if grep -r "terraform.*validate\|terraform.*plan" "$PROJECT_ROOT/.github" >/dev/null 2>&1; then
                echo "✓ Terraform validation/testing found in CI/CD"
                testing_found=true
            fi
        fi
    fi
    
    # Check for test files or validation scripts
    if find "$PROJECT_ROOT" -name "*test*" -o -name "*validate*" -type f | head -1 >/dev/null 2>&1; then
        echo "✓ Test or validation files found"
        testing_found=true
    fi
    
    return $([ "$testing_found" = true ] && echo 0 || echo 1)
}

# Main IaC compliance check
main() {
    echo "Running Infrastructure as Code compliance check (INF-001)..."
    local checks_passed=0
    local total_checks=0
    
    # Check IaC structure
    if check_iac_structure; then
        ((checks_passed++))
    else
        echo "❌ No Infrastructure as Code structure found"
    fi
    ((total_checks++))
    
    # Check version control
    if check_version_control; then
        ((checks_passed++))
    else
        echo "❌ Infrastructure code not properly version controlled"
    fi
    ((total_checks++))
    
    # Check documentation
    if check_documentation; then
        ((checks_passed++))
    else
        echo "❌ Insufficient infrastructure documentation"
    fi
    ((total_checks++))
    
    # Check testing
    if check_testing; then
        ((checks_passed++))
    else
        echo "⚠ No infrastructure testing or validation found"
    fi
    ((total_checks++))
    
    # Evaluate results
    if [[ $checks_passed -ge 3 ]]; then
        echo "✅ IaC compliance check PASSED ($checks_passed/$total_checks checks passed)"
        return 0
    else
        echo "❌ IaC compliance check FAILED ($checks_passed/$total_checks checks passed)"
        echo "📋 Minimum 3/4 checks required for compliance"
        return 1
    fi
}

# Execute main function
main "$@"
