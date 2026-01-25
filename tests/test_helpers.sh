#!/bin/bash
# =================================================================
# Test Helper Functions
# Common utilities for template validation test scripts
# =================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
ERRORS=0
WARNINGS=0
TESTS_RUN=0
TESTS_PASSED=0

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

# Function to print test summary
print_test_summary() {
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
}

# Function to print success message
print_success() {
    local message=$1
    echo -e "${GREEN}==================================================================${NC}"
    echo -e "${GREEN}✓ ${message}${NC}"
    echo -e "${GREEN}==================================================================${NC}"
}

# Function to print failure message
print_failure() {
    local message=$1
    echo -e "${RED}==================================================================${NC}"
    echo -e "${RED}✗ ${message}${NC}"
    echo -e "${RED}==================================================================${NC}"
}

# Function to reset test counters (useful for running multiple test suites)
reset_counters() {
    ERRORS=0
    WARNINGS=0
    TESTS_RUN=0
    TESTS_PASSED=0
}
