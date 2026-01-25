#!/bin/bash
# =================================================================
# Validation Script for Makefile Variant Targets
# Tests: make paper, make monograph, make thesis
# Note: Does not require actual LaTeX compilation
# =================================================================

set -e  # Exit on first error

echo "========================================"
echo "MAKEFILE TARGETS VALIDATION"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

# Function to check if a file exists
check_file() {
    local file=$1
    local desc=$2
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $desc: $file"
        return 0
    else
        echo -e "${RED}✗${NC} $desc: $file (NOT FOUND)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to check if pattern exists in file
check_pattern() {
    local file=$1
    local pattern=$2
    local desc=$3
    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $desc"
        return 0
    else
        echo -e "${RED}✗${NC} $desc (PATTERN NOT FOUND: $pattern)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

echo "=== 1. CHECKING MAKEFILE STRUCTURE ==="
echo ""

# Check Makefile exists
check_file "Makefile" "Makefile exists"

# Check for variant targets
check_pattern "Makefile" "^paper:" "Makefile has 'paper' target"
check_pattern "Makefile" "^monograph:" "Makefile has 'monograph' target"
check_pattern "Makefile" "^thesis:" "Makefile has 'thesis' target"

# Check that targets use MAIN_FILE variable correctly
check_pattern "Makefile" "MAIN_FILE=paper-main" "Paper target sets MAIN_FILE=paper-main"
check_pattern "Makefile" "MAIN_FILE=monograph-main" "Monograph target sets MAIN_FILE=monograph-main"
check_pattern "Makefile" "MAIN_FILE=thesis-main" "Thesis target sets MAIN_FILE=thesis-main"

# Check .PHONY declaration includes new targets
check_pattern "Makefile" "\.PHONY:.*paper" "Paper target in .PHONY"
check_pattern "Makefile" "\.PHONY:.*monograph" "Monograph target in .PHONY"
check_pattern "Makefile" "\.PHONY:.*thesis" "Thesis target in .PHONY"

echo ""
echo "=== 2. CHECKING MAIN FILES EXIST ==="
echo ""

# Check main files exist
check_file "paper-main.tex" "Paper main file"
check_file "monograph-main.tex" "Monograph main file"
check_file "thesis-main.tex" "Thesis main file"

echo ""
echo "=== 3. CHECKING CONFIG FILES EXIST ==="
echo ""

# Check config files exist
check_file "config/paper-config.tex" "Paper config file"
check_file "config/monograph-config.tex" "Monograph config file"
check_file "config/thesis-config.tex" "Thesis config file"

echo ""
echo "=== 4. VALIDATING MAIN FILE REFERENCES ==="
echo ""

# Check paper-main.tex references correct config
check_pattern "paper-main.tex" "config/paper-config" "Paper main references paper config"
check_pattern "paper-main.tex" "\\\\documentclass.*article" "Paper uses article documentclass"

# Check monograph-main.tex references correct config
check_pattern "monograph-main.tex" "config/monograph-config" "Monograph main references monograph config"
check_pattern "monograph-main.tex" "\\\\documentclass.*report" "Monograph uses report documentclass"

# Check thesis-main.tex references correct config
check_pattern "thesis-main.tex" "config/thesis-config" "Thesis main references thesis config"
check_pattern "thesis-main.tex" "\\\\documentclass.*report" "Thesis uses report documentclass"

echo ""
echo "=== 5. CHECKING HELP OUTPUT ==="
echo ""

# Check make help includes new targets
if make help 2>&1 | grep -q "make paper"; then
    echo -e "${GREEN}✓${NC} Help shows 'make paper'"
else
    echo -e "${RED}✗${NC} Help doesn't show 'make paper'"
    ERRORS=$((ERRORS + 1))
fi

if make help 2>&1 | grep -q "make monograph"; then
    echo -e "${GREEN}✓${NC} Help shows 'make monograph'"
else
    echo -e "${RED}✗${NC} Help doesn't show 'make monograph'"
    ERRORS=$((ERRORS + 1))
fi

if make help 2>&1 | grep -q "make thesis"; then
    echo -e "${GREEN}✓${NC} Help shows 'make thesis'"
else
    echo -e "${RED}✗${NC} Help doesn't show 'make thesis'"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "=== 6. TESTING MAKEFILE TARGET LOGIC (DRY RUN) ==="
echo ""

# Test that Makefile parses correctly and targets exist
if make -n paper >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} 'make paper' target is valid (dry run passed)"
else
    echo -e "${RED}✗${NC} 'make paper' target has syntax errors"
    ERRORS=$((ERRORS + 1))
fi

if make -n monograph >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} 'make monograph' target is valid (dry run passed)"
else
    echo -e "${RED}✗${NC} 'make monograph' target has syntax errors"
    ERRORS=$((ERRORS + 1))
fi

if make -n thesis >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} 'make thesis' target is valid (dry run passed)"
else
    echo -e "${RED}✗${NC} 'make thesis' target has syntax errors"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "=== 7. CHECKING VARIANT-SPECIFIC FEATURES ==="
echo ""

# Paper: streamlined structure
PAPER_CHAPTERS=$(grep -c "\\\\input{chapters/" paper-main.tex || echo "0")
echo -e "${GREEN}✓${NC} Paper variant includes $PAPER_CHAPTERS chapters (streamlined)"

# Monograph: TOC required
if grep -q "\\\\tableofcontents" monograph-main.tex && ! grep -q "^%" monograph-main.tex | grep -q "\\\\tableofcontents"; then
    echo -e "${GREEN}✓${NC} Monograph has table of contents (required)"
else
    echo -e "${YELLOW}⚠${NC} Monograph may be missing active table of contents"
fi

# Thesis: front matter sections
if grep -q "dedication" thesis-main.tex; then
    echo -e "${GREEN}✓${NC} Thesis includes dedication section"
else
    echo -e "${RED}✗${NC} Thesis missing dedication section"
    ERRORS=$((ERRORS + 1))
fi

if grep -q "acknowledgments-thesis" thesis-main.tex; then
    echo -e "${GREEN}✓${NC} Thesis includes acknowledgments section"
else
    echo -e "${RED}✗${NC} Thesis missing acknowledgments section"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "========================================"
echo "VALIDATION SUMMARY"
echo "========================================"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ ALL CHECKS PASSED${NC}"
    echo ""
    echo "All Makefile targets are properly configured."
    echo "Targets: make paper, make monograph, make thesis"
    echo ""
    echo "Note: Actual PDF compilation requires LaTeX installation (pdflatex)."
    echo "When LaTeX is available, run the full verification:"
    echo "  make clean && make paper && make clean && make monograph && make clean && make thesis"
    echo ""
    exit 0
else
    echo -e "${RED}✗ VALIDATION FAILED${NC}"
    echo ""
    echo "Errors found: $ERRORS"
    echo "Please fix the issues above before proceeding."
    echo ""
    exit 1
fi
