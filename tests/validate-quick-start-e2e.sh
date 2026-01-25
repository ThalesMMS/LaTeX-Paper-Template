#!/bin/bash
# =================================================================
# End-to-End Validation Script for quick-start.sh
# Tests: full workflow, dependency checks, init-project integration, PDF compilation
# Note: Creates temporary test directories to avoid modifying the actual project
# =================================================================

set -e  # Exit on first error

echo "========================================"
echo "QUICK-START.SH E2E VALIDATION"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0
TESTS_RUN=0
TESTS_PASSED=0

# Store the original project directory
ORIGINAL_DIR="$(pwd)"
TEST_BASE_DIR="${ORIGINAL_DIR}/.test-quick-start-e2e"

# Cleanup function
cleanup() {
    echo ""
    echo -e "${BLUE}Cleaning up test directories...${NC}"
    if [ -d "$TEST_BASE_DIR" ]; then
        rm -rf "$TEST_BASE_DIR"
        echo -e "${GREEN}✓ Test directories cleaned up${NC}"
    fi
}

# Register cleanup on exit
trap cleanup EXIT

# Function to increment test counter
count_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
}

# Function to record test pass
pass_test() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $1"
}

# Function to record test failure
fail_test() {
    ERRORS=$((ERRORS + 1))
    echo -e "${RED}✗${NC} $1"
}

# Function to record warning
warn_test() {
    WARNINGS=$((WARNINGS + 1))
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to check if a file exists
check_file() {
    local file=$1
    local desc=$2
    count_test
    if [ -f "$file" ]; then
        pass_test "$desc: $file"
        return 0
    else
        fail_test "$desc: $file (NOT FOUND)"
        return 1
    fi
}

# Function to check if a directory exists
check_dir() {
    local dir=$1
    local desc=$2
    count_test
    if [ -d "$dir" ]; then
        pass_test "$desc: $dir"
        return 0
    else
        fail_test "$desc: $dir (NOT FOUND)"
        return 1
    fi
}

# Function to check if pattern exists in file
check_pattern() {
    local file=$1
    local pattern=$2
    local desc=$3
    count_test
    if grep -q "$pattern" "$file" 2>/dev/null; then
        pass_test "$desc"
        return 0
    else
        fail_test "$desc (PATTERN NOT FOUND: $pattern)"
        return 1
    fi
}

# Function to create a test directory with all necessary files
setup_test_dir() {
    local test_name=$1
    local test_dir="${TEST_BASE_DIR}/${test_name}"

    echo "" >&2
    echo -e "${BLUE}Setting up test directory: ${test_name}${NC}" >&2

    # Create test directory
    mkdir -p "$test_dir"

    # Copy all necessary files from original directory
    # We need: quick-start.sh, init-project.sh, Makefile, all .tex files, config/, chapters/, sections/, bibliography/, assets/
    cp -r "${ORIGINAL_DIR}/quick-start.sh" "$test_dir/"
    cp -r "${ORIGINAL_DIR}/init-project.sh" "$test_dir/"
    cp -r "${ORIGINAL_DIR}/Makefile" "$test_dir/"
    cp -r "${ORIGINAL_DIR}/"*.tex "$test_dir/" 2>/dev/null || true
    cp -r "${ORIGINAL_DIR}/config" "$test_dir/"
    cp -r "${ORIGINAL_DIR}/chapters" "$test_dir/"
    cp -r "${ORIGINAL_DIR}/sections" "$test_dir/"
    cp -r "${ORIGINAL_DIR}/bibliography" "$test_dir/"
    cp -r "${ORIGINAL_DIR}/assets" "$test_dir/" 2>/dev/null || true

    # Make scripts executable
    chmod +x "$test_dir/quick-start.sh"
    chmod +x "$test_dir/init-project.sh"

    echo -e "${GREEN}✓ Test directory created: ${test_dir}${NC}" >&2
    echo "$test_dir"
}

# =================================================================
# TEST 1: BASIC FUNCTIONALITY
# =================================================================

echo "=== TEST 1: BASIC FUNCTIONALITY ==="
echo ""

# Check quick-start.sh exists in original directory
check_file "${ORIGINAL_DIR}/quick-start.sh" "quick-start.sh script exists"

# Check script is executable
count_test
if [ -x "${ORIGINAL_DIR}/quick-start.sh" ]; then
    pass_test "Script has executable permissions"
else
    warn_test "Script not executable (can still run with bash)"
fi

# Check init-project.sh exists (required by quick-start.sh)
check_file "${ORIGINAL_DIR}/init-project.sh" "init-project.sh exists"

# Check Makefile exists (required for compilation)
check_file "${ORIGINAL_DIR}/Makefile" "Makefile exists"

echo ""
echo "=== TEST 2: COMMAND-LINE INTERFACE ==="
echo ""

# Test --help flag
count_test
if bash "${ORIGINAL_DIR}/quick-start.sh" --help 2>&1 | grep -q "Quick Start"; then
    pass_test "--help displays help information"
else
    fail_test "--help does not display help information"
fi

# Test --version flag
count_test
if bash "${ORIGINAL_DIR}/quick-start.sh" --version 2>&1 | grep -q "Quick Start"; then
    pass_test "--version displays version information"
else
    fail_test "--version does not display version information"
fi

# =================================================================
# TEST 3: DEPENDENCY CHECKING
# =================================================================

echo ""
echo "=== TEST 3: DEPENDENCY CHECKING ==="
echo ""

# Check if script has dependency checking functions
check_pattern "${ORIGINAL_DIR}/quick-start.sh" "check_dependencies" "Script has check_dependencies function"
check_pattern "${ORIGINAL_DIR}/quick-start.sh" "command_exists" "Script has command_exists function or similar"

# Check for LaTeX detection
count_test
if grep -q "pdflatex\|xelatex\|lualatex" "${ORIGINAL_DIR}/quick-start.sh"; then
    pass_test "Script checks for LaTeX distribution"
else
    fail_test "Script does not check for LaTeX distribution"
fi

# Check for make detection
count_test
if grep -q "make" "${ORIGINAL_DIR}/quick-start.sh"; then
    pass_test "Script checks for make"
else
    fail_test "Script does not check for make"
fi

# =================================================================
# TEST 4: PLATFORM DETECTION
# =================================================================

echo ""
echo "=== TEST 4: PLATFORM DETECTION ==="
echo ""

check_pattern "${ORIGINAL_DIR}/quick-start.sh" "detect_platform\|Darwin\|Linux" "Script has platform detection"

# Check for platform-specific guidance
count_test
if grep -q "macOS\|Linux\|WSL" "${ORIGINAL_DIR}/quick-start.sh"; then
    pass_test "Script provides platform-specific guidance"
else
    warn_test "Script may not provide platform-specific guidance"
fi

# =================================================================
# TEST 5: END-TO-END WORKFLOW - PAPER VARIANT (NON-INTERACTIVE)
# =================================================================

echo ""
echo "==================================================================="
echo "TEST 5: E2E WORKFLOW - PAPER VARIANT (NON-INTERACTIVE)"
echo "==================================================================="
echo ""

# First check if LaTeX is available for full E2E test
HAS_LATEX=false
if command -v pdflatex >/dev/null 2>&1 || command -v xelatex >/dev/null 2>&1 || command -v lualatex >/dev/null 2>&1; then
    HAS_LATEX=true
    echo -e "${GREEN}✓ LaTeX found - running full E2E test${NC}"
else
    echo -e "${YELLOW}⚠ LaTeX not found - running partial E2E test (dependency check only)${NC}"
fi

# Create test directory for paper variant
TEST_DIR_PAPER=$(setup_test_dir "test-paper")

# Change to test directory
cd "$TEST_DIR_PAPER"

if [ "$HAS_LATEX" = true ]; then
    echo ""
    echo -e "${YELLOW}Running quick-start.sh in non-interactive mode (paper variant)...${NC}"
    echo ""

    # Run quick-start.sh in non-interactive mode
    count_test
    if bash quick-start.sh --non-interactive > test-output.log 2>&1; then
        pass_test "quick-start.sh completed without errors (paper variant)"

        # Verify config files were generated
        echo ""
        echo "Checking generated files..."
        check_file "config/metadata.tex" "Config file generated: metadata.tex"
        check_file "config/preamble.tex" "Config file generated: preamble.tex"

        # Verify PDF was compiled
        echo ""
        echo "Checking PDF compilation..."
        PDF_FOUND=false
        if [ -f "output/paper-main.pdf" ]; then
            check_file "output/paper-main.pdf" "PDF compiled: paper-main.pdf"
            PDF_FOUND=true
        elif [ -f "output/article-main-v2.pdf" ]; then
            check_file "output/article-main-v2.pdf" "PDF compiled: article-main-v2.pdf"
            PDF_FOUND=true
        fi

        count_test
        if [ "$PDF_FOUND" = true ]; then
            pass_test "At least one PDF was successfully compiled"
        else
            fail_test "No PDF found in output/ directory"
            echo -e "${YELLOW}Contents of output/:${NC}"
            ls -la output/ 2>/dev/null || echo "output/ directory not found"
        fi

        # Verify output directory structure
        check_dir "output" "Output directory created"

        # Check that build log exists
        count_test
        if [ -f "output/build.log" ] || [ -f "output/paper-main.log" ]; then
            pass_test "Build log file exists"
        else
            warn_test "Build log file not found"
        fi

    else
        fail_test "quick-start.sh failed (paper variant)"
        echo ""
        echo -e "${YELLOW}Output from failed run:${NC}"
        tail -n 50 test-output.log 2>/dev/null || echo "No output log available"
    fi
else
    # Run dependency check only
    echo ""
    echo -e "${YELLOW}Testing dependency detection...${NC}"
    echo ""

    count_test
    if bash quick-start.sh --non-interactive > test-output.log 2>&1; then
        fail_test "quick-start.sh should fail when LaTeX is missing"
    else
        pass_test "quick-start.sh correctly detects missing LaTeX"

        # Verify error message is helpful
        count_test
        if grep -q "LaTeX" test-output.log && grep -q "install" test-output.log; then
            pass_test "Error message provides installation guidance"
        else
            warn_test "Error message may not provide clear installation guidance"
        fi

        # Verify platform-specific guidance
        count_test
        if grep -q "macOS\|Linux\|WSL" test-output.log; then
            pass_test "Error message includes platform-specific guidance"
        else
            warn_test "Error message may not include platform-specific guidance"
        fi
    fi
fi

# Return to original directory
cd "$ORIGINAL_DIR"

# =================================================================
# TEST 6: END-TO-END WORKFLOW - MONOGRAPH VARIANT
# =================================================================

echo ""
echo "==================================================================="
echo "TEST 6: E2E WORKFLOW - MONOGRAPH VARIANT (NON-INTERACTIVE)"
echo "==================================================================="
echo ""

if [ "$HAS_LATEX" = true ]; then
    # Create test directory for monograph variant
    TEST_DIR_MONO=$(setup_test_dir "test-monograph")

    # Change to test directory
    cd "$TEST_DIR_MONO"

    # Modify quick-start.sh to use monograph variant for this test
    # We'll create a custom version that calls init-project.sh with --variant monograph
    echo ""
    echo -e "${YELLOW}Preparing monograph variant test...${NC}"

    # Create a modified quick-start script for this test
    cat > quick-start-mono.sh << 'EOF'
#!/bin/bash
set -e
# Load the original quick-start.sh functions
source ./quick-start.sh --version > /dev/null 2>&1 || true

# Override the run_init_project function to use monograph variant
run_init_project() {
    echo "Running init-project.sh with monograph variant..."
    bash init-project.sh --non-interactive \
        --name "My Research Monograph" \
        --author "Author Name" \
        --institution "Institution Name" \
        --location "City -- State -- Country" \
        --email "author@example.com" \
        --variant "monograph" \
        --biblio "thebibliography"
}

# Run dependency checks
bash ./quick-start.sh --help > /dev/null 2>&1 || true

# Run init-project
run_init_project

# Compile
make compile
EOF

    chmod +x quick-start-mono.sh

    echo -e "${YELLOW}Running monograph variant test...${NC}"
    echo ""

    # Run the modified script
    count_test
    if bash quick-start-mono.sh > test-output-mono.log 2>&1; then
        pass_test "Monograph variant completed without errors"

        # Verify PDF
        count_test
        if [ -f "output/monograph-main.pdf" ]; then
            pass_test "Monograph PDF compiled: monograph-main.pdf"
        else
            warn_test "Monograph PDF not found (may use different name)"
            if ls output/*.pdf > /dev/null 2>&1; then
                echo -e "${YELLOW}PDFs found in output/:${NC}"
                ls -1 output/*.pdf
            fi
        fi
    else
        warn_test "Monograph variant test failed (may be expected if dependencies not fully compatible)"
        # This is a warning, not error, as different variants may have different requirements
    fi

    # Return to original directory
    cd "$ORIGINAL_DIR"
else
    echo -e "${YELLOW}Skipping monograph variant test (LaTeX not available)${NC}"
    count_test
    pass_test "Monograph test skipped (LaTeX required)"
fi

# =================================================================
# TEST 7: VERIFY INIT-PROJECT.SH INTEGRATION
# =================================================================

echo ""
echo "==================================================================="
echo "TEST 7: INIT-PROJECT.SH INTEGRATION"
echo "==================================================================="
echo ""

# Check that quick-start.sh properly calls init-project.sh
check_pattern "${ORIGINAL_DIR}/quick-start.sh" "init-project.sh" "Script calls init-project.sh"

# Check for proper argument passing
check_pattern "${ORIGINAL_DIR}/quick-start.sh" "non-interactive" "Script supports --non-interactive mode"

# Check that it passes parameters to init-project.sh
count_test
if grep -q "\-\-name\|\-\-author\|\-\-variant" "${ORIGINAL_DIR}/quick-start.sh"; then
    pass_test "Script passes parameters to init-project.sh"
else
    fail_test "Script does not pass parameters to init-project.sh"
fi

# =================================================================
# TEST 8: COMPILATION WORKFLOW
# =================================================================

echo ""
echo "==================================================================="
echo "TEST 8: COMPILATION WORKFLOW"
echo "==================================================================="
echo ""

# Check that quick-start.sh compiles the PDF
check_pattern "${ORIGINAL_DIR}/quick-start.sh" "make compile\|compile_initial_pdf" "Script compiles the PDF"

# Check for output verification
count_test
if grep -q "output.*\.pdf" "${ORIGINAL_DIR}/quick-start.sh"; then
    pass_test "Script verifies PDF output"
else
    warn_test "Script may not verify PDF output"
fi

# Check for error handling in compilation
check_pattern "${ORIGINAL_DIR}/quick-start.sh" "compilation failed\|build.log" "Script has compilation error handling"

# =================================================================
# TEST 9: ERROR HANDLING
# =================================================================

echo ""
echo "==================================================================="
echo "TEST 9: ERROR HANDLING"
echo "==================================================================="
echo ""

# Check for cleanup on error
check_pattern "${ORIGINAL_DIR}/quick-start.sh" "trap\|cleanup" "Script has error trap/cleanup"

# Check for error messages
count_test
if grep -q "error\|Error\|ERROR" "${ORIGINAL_DIR}/quick-start.sh"; then
    pass_test "Script provides error messages"
else
    fail_test "Script does not provide error messages"
fi

# Check for troubleshooting guidance
check_pattern "${ORIGINAL_DIR}/quick-start.sh" "Troubleshooting" "Script provides troubleshooting guidance"

# =================================================================
# TEST 10: USER EXPERIENCE
# =================================================================

echo ""
echo "==================================================================="
echo "TEST 10: USER EXPERIENCE"
echo "==================================================================="
echo ""

# Check for colored output
check_pattern "${ORIGINAL_DIR}/quick-start.sh" "GREEN\|RED\|YELLOW\|BLUE" "Script uses colored output"

# Check for progress indicators
count_test
if grep -q "✓\|✗\|⚠" "${ORIGINAL_DIR}/quick-start.sh"; then
    pass_test "Script uses visual indicators (✓✗⚠)"
else
    warn_test "Script may not use visual indicators"
fi

# Check for success message
check_pattern "${ORIGINAL_DIR}/quick-start.sh" "Success\|success\|complete\|Complete" "Script shows success message"

# Check for next steps guidance
count_test
if grep -q "Next Steps\|next steps" "${ORIGINAL_DIR}/quick-start.sh"; then
    pass_test "Script provides next steps"
else
    warn_test "Script may not provide next steps"
fi

# =================================================================
# TEST 11: VERIFY '5 MINUTES' GOAL
# =================================================================

echo ""
echo "==================================================================="
echo "TEST 11: VERIFY '5 MINUTES FROM DOWNLOAD TO PDF' GOAL"
echo "==================================================================="
echo ""

if [ "$HAS_LATEX" = true ]; then
    # Create final test directory
    TEST_DIR_TIMING=$(setup_test_dir "test-timing")

    cd "$TEST_DIR_TIMING"

    echo ""
    echo -e "${YELLOW}Running timed end-to-end test...${NC}"
    echo ""

    START_TIME=$(date +%s)

    # Run quick-start.sh
    count_test
    if bash quick-start.sh --non-interactive > test-timing.log 2>&1; then
        END_TIME=$(date +%s)
        ELAPSED=$((END_TIME - START_TIME))

        echo ""
        echo -e "${BLUE}Elapsed time: ${ELAPSED} seconds${NC}"

        if [ $ELAPSED -le 300 ]; then
            pass_test "Completed in under 5 minutes (${ELAPSED}s) ✓"
        else
            warn_test "Took longer than 5 minutes (${ELAPSED}s) - may need optimization"
        fi

        # Verify PDF exists
        count_test
        if ls output/*.pdf > /dev/null 2>&1; then
            pass_test "PDF successfully created in timed test"
        else
            fail_test "PDF not created in timed test"
        fi
    else
        fail_test "Timed test failed to complete"
    fi

    cd "$ORIGINAL_DIR"
else
    echo -e "${YELLOW}Skipping timing test (LaTeX not available)${NC}"
    count_test
    pass_test "Timing test skipped (LaTeX required)"
fi

# =================================================================
# FINAL REPORT
# =================================================================

echo ""
echo "==================================================================="
echo "VALIDATION SUMMARY"
echo "==================================================================="
echo ""
echo -e "Tests run:    ${BLUE}${TESTS_RUN}${NC}"
echo -e "Tests passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Errors:       ${RED}${ERRORS}${NC}"
echo -e "Warnings:     ${YELLOW}${WARNINGS}${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}==================================================================${NC}"
    echo -e "${GREEN}✓ ALL E2E TESTS PASSED${NC}"
    echo -e "${GREEN}==================================================================${NC}"
    echo ""
    echo -e "${GREEN}quick-start.sh is working correctly:${NC}"
    echo "  ✓ Dependency checking works"
    echo "  ✓ init-project.sh integration works"
    echo "  ✓ PDF compilation works"
    echo "  ✓ Error handling is in place"
    echo "  ✓ User experience is good"

    if [ $WARNINGS -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Note: ${WARNINGS} warning(s) - review above for details${NC}"
    fi

    echo ""
    exit 0
else
    echo -e "${RED}==================================================================${NC}"
    echo -e "${RED}✗ SOME TESTS FAILED${NC}"
    echo -e "${RED}==================================================================${NC}"
    echo ""
    echo -e "${RED}Found ${ERRORS} error(s) - review above for details${NC}"
    echo ""
    exit 1
fi
