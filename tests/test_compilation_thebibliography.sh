#!/bin/bash
# =================================================================
# thebibliography Compilation Test
# Tests: Verifies that the template compiles successfully using thebibliography
# Note: Uses default Makefile compile target (thebibliography method)
# =================================================================

set -e  # Exit on first error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test_helpers.sh"

echo "==================================================================="
echo "THEBIBLIOGRAPHY COMPILATION TEST"
echo "==================================================================="
echo ""

# Move to template root directory (parent of tests/)
cd "$SCRIPT_DIR/.."

echo "=== 1. PRE-COMPILATION CHECKS ==="
echo ""

# Check that required files exist
check_file "Makefile" "Makefile exists"
check_file "article-main-v2.tex" "Main tex file exists"

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
echo "=== 3. COMPILING WITH THEBIBLIOGRAPHY ==="
echo ""

# Compile the document using thebibliography (default make compile)
count_test
echo -e "${BLUE}Running: make compile${NC}"
if make compile 2>&1; then
    pass_test "Compilation completed successfully"
else
    fail_test "Compilation failed"
    print_test_summary
    print_failure "THEBIBLIOGRAPHY COMPILATION FAILED"
    echo ""
    echo "Check output/build.log for details"
    exit 1
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
echo "=== 6. CLEANUP ==="
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
    print_success "THEBIBLIOGRAPHY COMPILATION TEST PASSED"
    echo ""
    echo "Template successfully compiles using thebibliography:"
    echo "  - Compilation completed without errors"
    echo "  - PDF generated successfully"
    echo "  - No fatal errors in build log"
    echo ""
    exit 0
else
    echo ""
    print_failure "THEBIBLIOGRAPHY COMPILATION TEST FAILED"
    echo ""
    echo "$ERRORS error(s) encountered during compilation test."
    echo "Please check the build log and fix compilation issues."
    echo ""
    exit 1
fi
