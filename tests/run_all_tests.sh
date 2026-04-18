#!/bin/bash
# =================================================================
# Master Test Runner for LaTeX Template Validation
# Discovers and executes all test scripts, aggregates results
# =================================================================

set -e  # Exit on first error

# Determine script directory to find test_helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source test helpers
if [ -f "${SCRIPT_DIR}/test_helpers.sh" ]; then
    source "${SCRIPT_DIR}/test_helpers.sh"
else
    echo "ERROR: test_helpers.sh not found"
    exit 1
fi

# =================================================================
# COMMAND-LINE INTERFACE
# =================================================================

show_help() {
    cat << EOF
=================================================================
LaTeX Template Test Suite Runner
=================================================================

Usage: $(basename "$0") [OPTIONS]

Description:
  Runs all validation tests for the LaTeX paper template.
  Automatically discovers and executes all test_*.sh scripts
  in the tests/ directory.

Options:
  --help, -h        Show this help message
  --verbose, -v     Enable verbose output
  --test NAME       Run only the specified test (e.g., --test required_files)
  --list            List all available tests without running them

Examples:
  # Run all tests
  $(basename "$0")

  # Run a specific test
  $(basename "$0") --test required_files

  # List available tests
  $(basename "$0") --list

Exit Codes:
  0  - All tests passed
  1  - Some tests failed

EOF
}

show_version() {
    echo "LaTeX Template Test Suite Runner v1.0.0"
}

# Parse command-line arguments
VERBOSE=false
SPECIFIC_TEST=""
LIST_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --version)
            show_version
            exit 0
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --test)
            SPECIFIC_TEST="$2"
            shift 2
            ;;
        --list)
            LIST_ONLY=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# =================================================================
# TEST DISCOVERY
# =================================================================

# Find all test scripts
TEST_SCRIPTS=()
while IFS= read -r -d '' script; do
    TEST_SCRIPTS+=("$script")
done < <(find "${SCRIPT_DIR}" -maxdepth 1 -name "test_*.sh" -type f -print0 | sort -z)

if [ ${#TEST_SCRIPTS[@]} -eq 0 ]; then
    echo -e "${YELLOW}No test scripts found in ${SCRIPT_DIR}${NC}"
    exit 0
fi

# =================================================================
# LIST TESTS
# =================================================================

if [ "$LIST_ONLY" = true ]; then
    echo "==================================================================="
    echo "AVAILABLE TESTS"
    echo "==================================================================="
    echo ""
    for script in "${TEST_SCRIPTS[@]}"; do
        test_name=$(basename "$script" .sh | sed 's/^test_//')
        echo -e "  ${BLUE}${test_name}${NC}"
        # Try to extract description from script header
        desc=$(grep -m 1 "^# Tests:" "$script" 2>/dev/null | sed 's/^# Tests: //' || echo "")
        if [ -n "$desc" ]; then
            echo -e "    ${desc}"
        fi
        echo ""
    done
    exit 0
fi

# =================================================================
# RUN TESTS
# =================================================================

echo "========================================"
echo "LATEX TEMPLATE TEST SUITE"
echo "========================================"
echo ""
echo -e "${BLUE}Project Directory: ${PROJECT_DIR}${NC}"
echo -e "${BLUE}Tests Directory: ${SCRIPT_DIR}${NC}"
echo ""

# Track overall results
TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_ERRORS=0
TOTAL_WARNINGS=0
FAILED_TESTS=()

# Run each test script
for script in "${TEST_SCRIPTS[@]}"; do
    test_name=$(basename "$script" .sh | sed 's/^test_//')

    # Skip if specific test requested and this isn't it
    if [ -n "$SPECIFIC_TEST" ] && [ "$test_name" != "$SPECIFIC_TEST" ]; then
        continue
    fi

    echo "==================================================================="
    echo -e "${BLUE}Running: ${test_name}${NC}"
    echo "==================================================================="
    echo ""

    # Reset counters for this test
    reset_counters

    # Run the test script in the project directory
    cd "${PROJECT_DIR}"

    if [ "$VERBOSE" = true ]; then
        if bash "$script"; then
            TEST_EXIT_CODE=0
        else
            TEST_EXIT_CODE=$?
        fi
    else
        # Capture output and only show if test fails
        if TEST_OUTPUT=$(bash "$script" 2>&1); then
            TEST_EXIT_CODE=0
        else
            TEST_EXIT_CODE=$?
        fi
        if [ $TEST_EXIT_CODE -ne 0 ]; then
            echo "$TEST_OUTPUT"
        else
            # Show summary even on success
            echo "$TEST_OUTPUT" | grep -A 10 "VALIDATION SUMMARY" || echo "$TEST_OUTPUT"
        fi
    fi

    # Aggregate results
    if [ $TEST_EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}✓ ${test_name} passed${NC}"
    else
        echo -e "${RED}✗ ${test_name} failed${NC}"
        FAILED_TESTS+=("$test_name")
        TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    fi

    echo ""
done

# Check if specific test was requested but not found
if [ -n "$SPECIFIC_TEST" ] && [ ${#FAILED_TESTS[@]} -eq 0 ] && [ $TOTAL_ERRORS -eq 0 ]; then
    # Check if we actually ran a test
    found=false
    for script in "${TEST_SCRIPTS[@]}"; do
        test_name=$(basename "$script" .sh | sed 's/^test_//')
        if [ "$test_name" = "$SPECIFIC_TEST" ]; then
            found=true
            break
        fi
    done

    if [ "$found" = false ]; then
        echo -e "${RED}Test not found: ${SPECIFIC_TEST}${NC}"
        echo ""
        echo "Available tests:"
        for script in "${TEST_SCRIPTS[@]}"; do
            test_name=$(basename "$script" .sh | sed 's/^test_//')
            echo "  - ${test_name}"
        done
        exit 1
    fi
fi

# =================================================================
# FINAL SUMMARY
# =================================================================

cd "${PROJECT_DIR}"

echo "==================================================================="
echo "FINAL TEST SUITE SUMMARY"
echo "==================================================================="
echo ""
echo -e "Test scripts run: ${BLUE}${#TEST_SCRIPTS[@]}${NC}"

if [ -n "$SPECIFIC_TEST" ]; then
    echo -e "(Filtered to: ${SPECIFIC_TEST})"
fi

echo ""

if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    print_success "ALL TESTS PASSED"
    echo ""
    echo -e "${GREEN}All validation tests completed successfully!${NC}"
    echo ""
    echo "The LaTeX template has been validated:"
    echo "  ✓ All required files present"
    echo "  ✓ Compilation tests passed"
    echo "  ✓ Warning detection works"
    echo ""
    exit 0
else
    print_failure "SOME TESTS FAILED"
    echo ""
    echo -e "${RED}Failed tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}✗${NC} $test"
    done
    echo ""
    echo -e "${RED}Review the output above for details${NC}"
    echo ""
    exit 1
fi
