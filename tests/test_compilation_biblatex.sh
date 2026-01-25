#!/bin/bash
# =================================================================
# Biblatex Compilation Test
# Tests: Verifies that the template compiles successfully using biblatex + biber
# Note: Tests full biblatex workflow (pdflatex -> biber -> pdflatex x2)
# =================================================================

set -e  # Exit on first error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test_helpers.sh"

echo "==================================================================="
echo "BIBLATEX COMPILATION TEST"
echo "==================================================================="
echo ""

# Move to template root directory (parent of tests/)
cd "$SCRIPT_DIR/.."

echo "=== 1. PRE-COMPILATION CHECKS ==="
echo ""

# Check that required files exist
check_file "Makefile" "Makefile exists"
check_file "article-main-v2.tex" "Main tex file exists"
check_file "bibliography/sbc-template.bib" "Bibliography file exists"

# Check for LaTeX installation
count_test
if command -v pdflatex >/dev/null 2>&1; then
    pass_test "pdflatex is installed"
else
    fail_test "pdflatex not found (LaTeX distribution required)"
    print_test_summary
    print_failure "COMPILATION TEST SKIPPED - PDFLATEX NOT INSTALLED"
    exit 1
fi

# Check for biber installation
count_test
if command -v biber >/dev/null 2>&1; then
    pass_test "biber is installed"
else
    fail_test "biber not found (required for biblatex)"
    print_test_summary
    print_failure "COMPILATION TEST SKIPPED - BIBER NOT INSTALLED"
    exit 1
fi

echo ""
echo "=== 2. CLEAN PREVIOUS BUILD ARTIFACTS ==="
echo ""

# Clean any previous build artifacts
count_test
if make clean >/dev/null 2>&1; then
    pass_test "Cleaned previous build artifacts"
else
    warn_test "Clean command had issues (continuing anyway)"
fi

echo ""
echo "=== 3. COMPILING WITH BIBLATEX ==="
echo ""

# Compile the document using biblatex workflow
count_test
echo -e "${BLUE}Running: make biblatex${NC}"
if make biblatex 2>&1; then
    pass_test "Biblatex compilation completed successfully"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        fail_test "Biblatex compilation failed"
        print_test_summary
        print_failure "BIBLATEX COMPILATION FAILED"
        echo ""
        echo "Check output/build.log for details"
        exit 1
    elif [ $EXIT_CODE -eq 2 ]; then
        warn_test "Compilation succeeded with warnings (undefined references/citations)"
        # Continue to verify output was created
    else
        fail_test "Biblatex compilation failed with unexpected error"
        print_test_summary
        print_failure "BIBLATEX COMPILATION FAILED"
        exit 1
    fi
fi

echo ""
echo "=== 4. VERIFYING OUTPUT ==="
echo ""

# Check that output directory was created
check_dir "output" "Output directory created"

# Check that PDF was created
check_file "output/article-main-v2.pdf" "PDF file created"

# Check that PDF has non-zero size
count_test
if [ -f "output/article-main-v2.pdf" ] && [ -s "output/article-main-v2.pdf" ]; then
    PDF_SIZE=$(stat -f%z "output/article-main-v2.pdf" 2>/dev/null || stat -c%s "output/article-main-v2.pdf" 2>/dev/null)
    pass_test "PDF has valid size (${PDF_SIZE} bytes)"
else
    fail_test "PDF is empty or missing"
fi

echo ""
echo "=== 5. CHECKING BUILD LOG ==="
echo ""

# Check that build log exists
check_file "output/build.log" "Build log created"

# Check for common error indicators in log
count_test
if [ -f "output/build.log" ]; then
    if ! grep -Eq "^!" "output/build.log"; then
        pass_test "No fatal errors in build log"
    else
        fail_test "Fatal errors found in build log"
        echo ""
        echo "Last 20 lines of build log:"
        tail -n 20 "output/build.log"
    fi
fi

# Check for biblatex-specific indicators
count_test
if [ -f "output/build.log" ]; then
    if grep -q "biblatex" "output/build.log"; then
        pass_test "Biblatex package detected in build"
    else
        warn_test "No biblatex package found (may not be configured)"
    fi
fi

# Check for undefined references warnings
count_test
if [ -f "output/build.log" ]; then
    if ! grep -Eq "Undefined references|Citation.*undefined|There were undefined citations" "output/build.log"; then
        pass_test "No undefined references or citations"
    else
        warn_test "Some references or citations may be undefined"
    fi
fi

echo ""
echo "=== 6. VERIFYING BIBLATEX ARTIFACTS ==="
echo ""

# Note: Biblatex artifacts are cleaned up by the Makefile after successful compilation
# We can only check if they existed during the build by examining the log
count_test
if [ -f "output/build.log" ]; then
    # Check if biber processing occurred
    if grep -q "This is Biber" "output/build.log" || grep -q "biber" "output/build.log"; then
        pass_test "Biber processing occurred"
    else
        warn_test "No biber processing detected in log"
    fi
fi

echo ""
echo "=== 7. CLEANUP ==="
echo ""

# Clean up build artifacts
count_test
if make clean >/dev/null 2>&1; then
    pass_test "Cleaned build artifacts"
else
    warn_test "Cleanup had issues"
fi

# Print summary
print_test_summary

# Exit with appropriate code
if [ $ERRORS -eq 0 ]; then
    echo ""
    print_success "BIBLATEX COMPILATION TEST PASSED"
    echo ""
    echo "Template successfully compiles using biblatex:"
    echo "  - Full biblatex workflow completed (pdflatex -> biber -> pdflatex x2)"
    echo "  - PDF generated successfully"
    echo "  - No fatal errors in build log"
    echo "  - Bibliography processing verified"
    echo ""
    exit 0
else
    echo ""
    print_failure "BIBLATEX COMPILATION TEST FAILED"
    echo ""
    echo "$ERRORS error(s) encountered during biblatex compilation test."
    echo "Please check the build log and fix compilation issues."
    echo ""
    exit 1
fi
