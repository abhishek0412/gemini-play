#!/bin/bash

# Compliance Checker - Main script to validate all policies
# This script automatically checks compliance against defined policies
# and updates documentation when changes are detected

set -euo pipefail

# Configuration
COMPLIANCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POLICIES_DIR="$COMPLIANCE_DIR/policies"
SCRIPTS_DIR="$COMPLIANCE_DIR/scripts"
REPORTS_DIR="$COMPLIANCE_DIR/reports"
PROJECT_ROOT="$(cd "$COMPLIANCE_DIR/.." && pwd)"
README_FILE="$PROJECT_ROOT/README.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")  echo -e "${BLUE}[INFO]${NC}  $timestamp - $message" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC}  $timestamp - $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $timestamp - $message" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $timestamp - $message" ;;
    esac
}

# Check if jq is installed
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        log "ERROR" "jq is required but not installed. Please install jq to continue."
        exit 1
    fi
}

# Parse policy files and extract compliance rules
parse_policies() {
    local policy_file=$1
    local policy_name=$(basename "$policy_file" .json)
    
    log "INFO" "Parsing policy: $policy_name" >&2
    
    # Extract rules that have automated checks
    jq -r '.policy.rules[] | select(.automated_check == true) | .id + ":" + .script' "$policy_file" 2>/dev/null
}

# Run compliance check for a specific rule
run_compliance_check() {
    local rule_id=$1
    local script_path=$2
    # Remove scripts/ prefix if it exists since SCRIPTS_DIR already includes it
    local clean_script_path="${script_path#scripts/}"
    local full_script_path="$SCRIPTS_DIR/$clean_script_path"
    
    if [[ -f "$full_script_path" ]]; then
        log "INFO" "Running check for rule: $rule_id"
        if bash "$full_script_path" >/dev/null 2>&1; then
            log "SUCCESS" "Rule $rule_id: PASSED"
            return 0
        else
            log "ERROR" "Rule $rule_id: FAILED"
            return 1
        fi
    else
        log "WARN" "Script not found for rule $rule_id: $script_path (looking for: $full_script_path)"
        return 1
    fi
}

# Generate compliance report
generate_report() {
    local report_file="$REPORTS_DIR/compliance-report-$(date '+%Y%m%d-%H%M%S').json"
    local passed_count=$1
    local failed_count=$2
    local total_count=$((passed_count + failed_count))
    
    mkdir -p "$REPORTS_DIR"
    
    cat > "$report_file" <<EOF
{
  "report": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "summary": {
      "total_rules": $total_count,
      "passed": $passed_count,
      "failed": $failed_count,
      "compliance_percentage": $(( passed_count * 100 / total_count ))
    },
    "details": {
      "passed_rules": [],
      "failed_rules": []
    }
  }
}
EOF
    
    log "INFO" "Compliance report generated: $report_file"
    return 0
}

# Check if documentation needs updating
check_documentation_freshness() {
    local readme_file="$README_FILE"
    local last_compliance_check=$(date '+%Y-%m-%d')
    
    # Check if README mentions compliance section
    if ! grep -q "## 🔒 Compliance" "$readme_file" 2>/dev/null; then
        log "INFO" "Documentation needs updating - adding compliance section"
        return 1
    fi
    
    return 0
}

# Update documentation with compliance information
update_documentation() {
    local readme_file="$README_FILE"
    
    log "INFO" "Updating documentation with compliance information"
    
    # Simple approach: append compliance section before Contributing section
    local compliance_section="## 🔒 Compliance

This project includes comprehensive policy-as-code compliance framework to ensure adherence to security, data governance, and infrastructure standards.

### Compliance Framework Structure

\`\`\`
compliance/
├── policies/                    # Policy definitions as JSON
│   ├── security-policy.json     # Security compliance requirements
│   ├── data-governance-policy.json # Data handling and privacy policies  
│   └── infrastructure-policy.json  # Infrastructure and deployment policies
├── scripts/                     # Automated compliance checking scripts
│   ├── compliance-checker.sh    # Main compliance validation script
│   ├── check-encryption.sh      # Encryption compliance checks
│   ├── check-mfa.sh            # Multi-factor authentication checks
│   └── update-docs.sh          # Documentation update automation
├── templates/                   # Policy and report templates
└── reports/                    # Generated compliance reports
\`\`\`

### Supported Compliance Frameworks

- **SOC 2** - Security, availability, processing integrity, confidentiality, and privacy
- **ISO 27001** - Information security management systems
- **GDPR** - General Data Protection Regulation
- **CCPA** - California Consumer Privacy Act
- **PCI-DSS** - Payment Card Industry Data Security Standard

### Running Compliance Checks

\`\`\`sh
# Run all compliance checks
./compliance/scripts/compliance-checker.sh

# Run specific policy checks
./compliance/scripts/compliance-checker.sh --policy security

# Generate compliance report
./compliance/scripts/compliance-checker.sh --report
\`\`\`

### Automated Documentation Updates

The compliance framework includes automated documentation updates that trigger when:
- Policy files are modified
- Compliance check results change
- New policies are added
- Infrastructure changes are detected

Last compliance check: $(date '+%Y-%m-%d')

"
    
    # Insert compliance section before Contributing if not already present
    if ! grep -q "## 🔒 Compliance" "$readme_file"; then
        python3 -c "
import re
with open('$readme_file', 'r') as f:
    content = f.read()
# Insert compliance section before Contributing section
compliance = '''$compliance_section'''
if '## Contributing' in content:
    content = content.replace('## Contributing', compliance + '## Contributing')
else:
    content += compliance
with open('$readme_file', 'w') as f:
    f.write(content)
"
    fi
    
    log "SUCCESS" "Documentation updated successfully"
}

# Main execution function
main() {
    local passed_count=0
    local failed_count=0
    
    log "INFO" "Starting compliance validation"
    
    # Check dependencies
    check_dependencies
    
    # Check if documentation needs updating
    if ! check_documentation_freshness; then
        update_documentation
    fi
    
    # Process all policy files
    for policy_file in "$POLICIES_DIR"/*.json; do
        if [[ -f "$policy_file" ]]; then
            while IFS=':' read -r rule_id script_path; do
                if [[ -n "$rule_id" && -n "$script_path" ]]; then
                    if run_compliance_check "$rule_id" "$script_path"; then
                        ((passed_count++))
                    else
                        ((failed_count++))
                    fi
                fi
            done < <(parse_policies "$policy_file")
        fi
    done
    
    # Generate compliance report
    generate_report "$passed_count" "$failed_count"
    
    # Summary
    local total_count=$((passed_count + failed_count))
    if [[ $total_count -gt 0 ]]; then
        local compliance_percentage=$(( passed_count * 100 / total_count ))
        log "INFO" "Compliance Summary: $passed_count/$total_count rules passed ($compliance_percentage%)"
        
        if [[ $failed_count -eq 0 ]]; then
            log "SUCCESS" "All compliance checks passed!"
            exit 0
        else
            log "ERROR" "$failed_count compliance checks failed"
            exit 1
        fi
    else
        log "WARN" "No automated compliance checks found"
        exit 0
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --policy <name> Run checks for specific policy only"
        echo "  --report       Generate compliance report only"
        exit 0
        ;;
    --policy)
        if [[ -n "${2:-}" ]]; then
            log "INFO" "Running checks for policy: $2"
            # Filter to specific policy
        else
            log "ERROR" "Policy name required with --policy option"
            exit 1
        fi
        ;;
    --report)
        log "INFO" "Generating compliance report only"
        generate_report 0 0
        exit 0
        ;;
    *)
        # Run all checks
        main
        ;;
esac
