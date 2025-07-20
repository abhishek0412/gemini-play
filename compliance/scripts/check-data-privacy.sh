#!/bin/bash

# Data Privacy Compliance Check (DG-003)
# This script validates data privacy requirements

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Check for anonymization functions in codebase
echo "Checking for data anonymization functions..."
anonymization_found=false
if grep -r -i 'anonymiz\|mask\|pseudonymiz' "$PROJECT_ROOT" --exclude-dir={.git,obj,bin,node_modules,venv} >/dev/null 2>&1; then
    echo "✓ Data anonymization or masking logic found in codebase"
    anonymization_found=true
else
    echo "⚠ No data anonymization or masking logic found"
fi

# Check for privacy notice or policy documentation
privacy_notice_found=false
if grep -r -i 'privacy policy\|data subject\|gdpr\|ccpa' "$PROJECT_ROOT" --exclude-dir={.git,obj,bin,node_modules,venv} >/dev/null 2>&1; then
    echo "✓ Privacy policy or data subject rights mentioned in documentation"
    privacy_notice_found=true
else
    echo "⚠ No privacy policy or data subject rights found in documentation"
fi

# Check for privacy impact assessment evidence
dpia_found=false
if find "$PROJECT_ROOT" -iname '*dpia*' -o -iname '*privacy-impact*' | grep . >/dev/null 2>&1; then
    echo "✓ Privacy Impact Assessment (DPIA) evidence found"
    dpia_found=true
else
    echo "⚠ No Privacy Impact Assessment (DPIA) evidence found"
fi

# Evaluate results
if [[ "$anonymization_found" = true && "$privacy_notice_found" = true && "$dpia_found" = true ]]; then
    echo "✅ Data privacy compliance check PASSED (DG-003)"
    exit 0
else
    echo "❌ Data privacy compliance check FAILED (DG-003)"
    exit 1
fi
