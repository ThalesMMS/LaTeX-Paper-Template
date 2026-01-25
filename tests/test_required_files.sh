#!/bin/bash
# =================================================================
# Required Files Validation Test
# Tests: Verifies existence of all required template files and directories
# Note: Does not check file contents, only existence
# =================================================================

set -e  # Exit on first error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test_helpers.sh"

echo "==================================================================="
echo "REQUIRED FILES VALIDATION TEST"
echo "==================================================================="
echo ""

# Move to template root directory (parent of tests/)
cd "$SCRIPT_DIR/.."

echo "=== 1. CHECKING MAIN TEX FILES ==="
echo ""

# Check all main .tex files
check_file "paper-main.tex" "Paper main file exists"
check_file "monograph-main.tex" "Monograph main file exists"
check_file "thesis-main.tex" "Thesis main file exists"
check_file "article-main-v2.tex" "Article v2 main file exists"

echo ""
echo "=== 2. CHECKING CONFIG FILES ==="
echo ""

# Check config directory exists
check_dir "config" "Config directory exists"

# Check config files
check_file "config/paper-config.tex" "Paper config file exists"
check_file "config/monograph-config.tex" "Monograph config file exists"
check_file "config/thesis-config.tex" "Thesis config file exists"
check_file "config/article-config.tex" "Article config file exists"
check_file "config/sbc-template.sty" "SBC template style file exists"
check_file "config/caption2.sty" "Caption2 style file exists"

echo ""
echo "=== 3. CHECKING REQUIRED DIRECTORIES ==="
echo ""

# Check all required directories
check_dir "chapters" "Chapters directory exists"
check_dir "sections" "Sections directory exists"
check_dir "bibliography" "Bibliography directory exists"
check_dir "assets" "Assets directory exists"

echo ""
echo "=== 4. CHECKING KEY SCRIPTS ==="
echo ""

# Check Makefile
check_file "Makefile" "Makefile exists"

# Check initialization scripts
check_file "init-project.sh" "Init project script exists"
check_file "quick-start.sh" "Quick start script exists"

echo ""
echo "=== 5. CHECKING DOCUMENTATION FILES ==="
echo ""

# Check README and documentation
check_file "README.md" "README file exists"
check_file "LICENSE" "LICENSE file exists"

echo ""
echo "=== 6. CHECKING CONTENT DIRECTORIES ==="
echo ""

# Check that content directories have at least some files
if [ -n "$(ls -A chapters/ 2>/dev/null)" ]; then
    count_test
    pass_test "Chapters directory contains files"
else
    count_test
    fail_test "Chapters directory is empty"
fi

if [ -n "$(ls -A sections/ 2>/dev/null)" ]; then
    count_test
    pass_test "Sections directory contains files"
else
    count_test
    fail_test "Sections directory is empty"
fi

if [ -n "$(ls -A bibliography/ 2>/dev/null)" ]; then
    count_test
    pass_test "Bibliography directory contains files"
else
    count_test
    fail_test "Bibliography directory is empty"
fi

echo ""
echo "=== 7. CHECKING TEST INFRASTRUCTURE ==="
echo ""

# Check test directory and files
check_dir "tests" "Tests directory exists"
check_file "tests/test_helpers.sh" "Test helpers module exists"
check_file "tests/run_all_tests.sh" "Test runner script exists"

# Print summary
print_test_summary

# Exit with appropriate code
if [ $ERRORS -eq 0 ]; then
    echo ""
    print_success "ALL REQUIRED FILES PRESENT"
    echo ""
    echo "Template structure is complete:"
    echo "  - 4 main .tex variants"
    echo "  - 6 config files"
    echo "  - 4 content directories"
    echo "  - Key build/init scripts"
    echo "  - Test infrastructure"
    echo ""
    exit 0
else
    echo ""
    print_failure "MISSING REQUIRED FILES"
    echo ""
    echo "$ERRORS file(s) or directory(ies) missing."
    echo "Please ensure all template files are present."
    echo ""
    exit 1
fi
