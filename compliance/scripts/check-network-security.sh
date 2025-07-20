#!/bin/bash

# Network Security Compliance Check (SEC-003)
# Validates network security configurations

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Check for network security in Terraform
check_terraform_network_security() {
    local terraform_dir="$PROJECT_ROOT/terraform"
    local security_found=false
    
    if [[ -d "$terraform_dir" ]]; then
        # Check for VPC/Network configurations
        if grep -r "aws_vpc\|aws_subnet\|azurerm_virtual_network" "$terraform_dir" >/dev/null 2>&1; then
            echo "✓ VPC/Virtual Network configuration found"
            security_found=true
        fi
        
        # Check for security groups/NSGs
        if grep -r "aws_security_group\|azurerm_network_security_group" "$terraform_dir" >/dev/null 2>&1; then
            echo "✓ Security group/NSG configuration found"
            security_found=true
        fi
        
        # Check for firewall rules
        if grep -r "ingress\|egress\|from_port\|to_port\|security_rule" "$terraform_dir" >/dev/null 2>&1; then
            echo "✓ Firewall/Network rules configuration found"
            security_found=true
        fi
        
        # Check for NAT gateways or similar
        if grep -r "aws_nat_gateway\|azurerm_nat_gateway" "$terraform_dir" >/dev/null 2>&1; then
            echo "✓ NAT Gateway configuration found"
            security_found=true
        fi
    fi
    
    return $([ "$security_found" = true ] && echo 0 || echo 1)
}

# Check for network security in Bicep
check_bicep_network_security() {
    local bicep_dir="$PROJECT_ROOT/bicep"
    local security_found=false
    
    if [[ -d "$bicep_dir" ]]; then
        # Check for Virtual Network configurations
        if grep -r "Microsoft.Network/virtualNetworks\|virtualNetwork" "$bicep_dir" >/dev/null 2>&1; then
            echo "✓ Azure Virtual Network configuration found in Bicep"
            security_found=true
        fi
        
        # Check for NSG configurations
        if grep -r "Microsoft.Network/networkSecurityGroups\|networkSecurityGroup" "$bicep_dir" >/dev/null 2>&1; then
            echo "✓ Network Security Group configuration found in Bicep"
            security_found=true
        fi
        
        # Check for firewall configurations
        if grep -r "securityRules\|Microsoft.Network/azureFirewalls" "$bicep_dir" >/dev/null 2>&1; then
            echo "✓ Firewall rules configuration found in Bicep"
            security_found=true
        fi
    fi
    
    return $([ "$security_found" = true ] && echo 0 || echo 1)
}

# Check for network security in Ansible
check_ansible_network_security() {
    local ansible_dir="$PROJECT_ROOT/ansible"
    local security_found=false
    
    if [[ -d "$ansible_dir" ]]; then
        # Check for firewall configurations
        if grep -r "firewall\|iptables\|ufw\|security_group" "$ansible_dir" >/dev/null 2>&1; then
            echo "✓ Firewall configuration found in Ansible"
            security_found=true
        fi
        
        # Check for network hardening tasks
        if grep -r "fail2ban\|ssh.*hardening\|network.*security" "$ansible_dir" >/dev/null 2>&1; then
            echo "✓ Network hardening configuration found in Ansible"
            security_found=true
        fi
    fi
    
    return $([ "$security_found" = true ] && echo 0 || echo 1)
}

# Main network security compliance check
main() {
    echo "Running network security compliance check (SEC-003)..."
    local checks_passed=0
    local total_checks=0
    
    # Check Terraform configurations
    if check_terraform_network_security; then
        ((checks_passed++))
    else
        echo "⚠ No network security configuration found in Terraform files"
    fi
    ((total_checks++))
    
    # Check Bicep configurations
    if check_bicep_network_security; then
        ((checks_passed++))
    else
        echo "⚠ No network security configuration found in Bicep files"
    fi
    ((total_checks++))
    
    # Check Ansible configurations
    if check_ansible_network_security; then
        ((checks_passed++))
    else
        echo "⚠ No network security configuration found in Ansible files"
    fi
    ((total_checks++))
    
    # Evaluate results
    if [[ $checks_passed -gt 0 ]]; then
        echo "✅ Network security compliance check PASSED ($checks_passed/$total_checks checks passed)"
        return 0
    else
        echo "❌ Network security compliance check FAILED (no network security configurations found)"
        echo "📋 Recommendation: Implement proper network segmentation and firewall rules"
        return 1
    fi
}

# Execute main function
main "$@"
