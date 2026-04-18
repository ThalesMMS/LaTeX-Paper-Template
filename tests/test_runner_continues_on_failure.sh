#!/bin/bash
# =================================================================
# Test: Runner continues on individual test failure
# Tests: That run_all_tests.sh uses error-tolerant child test
#        invocations so the master runner continues executing remaining
#        tests even when an individual test script exits with a non-zero
#        code, while keeping errexit active around surrounding logic.
# =================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SCRIPT_DIR}/test_helpers.sh"

echo "==================================================================="
echo "RUNNER CONTINUES ON FAILURE TEST"
echo "==================================================================="
echo ""

cd "${PROJECT_DIR}"
reset_counters

RUNNER="${SCRIPT_DIR}/run_all_tests.sh"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
TEMP_PROJECT="${TEMP_DIR}/runner_project"
TEMP_TESTS_DIR="${TEMP_PROJECT}/tests"
TEMP_RUNNER="${TEMP_TESTS_DIR}/run_all_tests.sh"

mkdir -p "${TEMP_TESTS_DIR}"
cp "${RUNNER}" "${TEMP_RUNNER}"
cp "${SCRIPT_DIR}/test_helpers.sh" "${TEMP_TESTS_DIR}/test_helpers.sh"
chmod +x "${TEMP_RUNNER}"

printf '#!/bin/bash\necho "SENTINEL_A_RAN"\nexit 1\n' \
    > "${TEMP_TESTS_DIR}/test_a_always_fails.sh"
printf '#!/bin/bash\necho "SENTINEL_B_RAN"\nexit 0\n' \
    > "${TEMP_TESTS_DIR}/test_b_always_passes.sh"
chmod +x "${TEMP_TESTS_DIR}/test_a_always_fails.sh" \
         "${TEMP_TESTS_DIR}/test_b_always_passes.sh"

FAKE_SCRIPTS=(
    "${TEMP_TESTS_DIR}/test_a_always_fails.sh"
    "${TEMP_TESTS_DIR}/test_b_always_passes.sh"
)

# -----------------------------------------------------------------------
# 1. FUNCTIONAL RUNNER CHECK: child test failures are tolerated
# -----------------------------------------------------------------------
echo "=== 1. FUNCTIONAL RUNNER CHECK: child invocation guards ==="
echo ""

if NON_VERBOSE_OUTPUT=$(bash "${TEMP_RUNNER}" 2>&1); then
    NON_VERBOSE_EXIT=0
else
    NON_VERBOSE_EXIT=$?
fi

count_test
if [ "$NON_VERBOSE_EXIT" -eq 1 ]; then
    pass_test "Non-verbose runner exits non-zero when a child test fails"
else
    fail_test "Non-verbose runner exit was ${NON_VERBOSE_EXIT}; expected 1"
fi

count_test
if echo "${NON_VERBOSE_OUTPUT}" | grep -q "SENTINEL_A_RAN"; then
    pass_test "Non-verbose runner captures output from failing child test"
else
    fail_test "Non-verbose runner did not capture failing child test output"
fi

count_test
if echo "${NON_VERBOSE_OUTPUT}" | grep -q "SENTINEL_B_RAN"; then
    pass_test "Non-verbose runner continues to the passing child test"
else
    fail_test "Non-verbose runner did not continue to the passing child test"
fi

count_test
if echo "${NON_VERBOSE_OUTPUT}" | grep -q "a_always_fails failed"; then
    pass_test "Non-verbose runner records the failing child test result"
else
    fail_test "Non-verbose runner did not record the failing child test result"
fi

count_test
if echo "${NON_VERBOSE_OUTPUT}" | grep -q "b_always_passes passed"; then
    pass_test "Non-verbose runner records the passing child test result"
else
    fail_test "Non-verbose runner did not record the passing child test result"
fi

if VERBOSE_RUNNER_OUTPUT=$(bash "${TEMP_RUNNER}" --verbose 2>&1); then
    VERBOSE_RUNNER_EXIT=0
else
    VERBOSE_RUNNER_EXIT=$?
fi

count_test
if [ "$VERBOSE_RUNNER_EXIT" -eq 1 ]; then
    pass_test "Verbose runner exits non-zero when a child test fails"
else
    fail_test "Verbose runner exit was ${VERBOSE_RUNNER_EXIT}; expected 1"
fi

count_test
if echo "${VERBOSE_RUNNER_OUTPUT}" | grep -q "SENTINEL_A_RAN"; then
    pass_test "Verbose runner streams output from failing child test"
else
    fail_test "Verbose runner did not stream failing child test output"
fi

count_test
if echo "${VERBOSE_RUNNER_OUTPUT}" | grep -q "SENTINEL_B_RAN"; then
    pass_test "Verbose runner continues to the passing child test"
else
    fail_test "Verbose runner did not continue to the passing child test"
fi

count_test
if echo "${VERBOSE_RUNNER_OUTPUT}" | grep -q "b_always_passes passed"; then
    pass_test "Verbose runner records the passing child test result"
else
    fail_test "Verbose runner did not record the passing child test result"
fi

# -----------------------------------------------------------------------
# 2. UNIT TEST: if guards allow execution to continue under errexit
# -----------------------------------------------------------------------
echo ""
echo "=== 2. UNIT TEST: if guards protect against aborting on failure ==="
echo ""

# Demonstrate that WITHOUT the guard, a failing command inside set -e stops execution
count_test
SENTINEL="${TEMP_DIR}/reached_after_failure.txt"
(
    set -e
    (exit 1) || true          # This works because || true neutralises the exit code
    touch "${SENTINEL}"
) 2>/dev/null
if [ -f "${SENTINEL}" ]; then
    pass_test "baseline check: '|| true' allows continuation (sanity check)"
else
    fail_test "baseline check failed (unexpected environment issue)"
fi

# Now show the actual pattern from the runner: if failing command; then ...
count_test
SENTINEL2="${TEMP_DIR}/reached_after_if_guard.txt"
CAPTURED_EXIT=999
(
    set -e
    if (exit 42); then
        CAPTURED_EXIT=0
    else
        CAPTURED_EXIT=$?
    fi
    touch "${SENTINEL2}"
    echo "$CAPTURED_EXIT" > "${TEMP_DIR}/exit_code.txt"
)
if [ -f "${SENTINEL2}" ]; then
    RECORDED=$(cat "${TEMP_DIR}/exit_code.txt")
    pass_test "if-guard pattern: execution continues and exit code captured as ${RECORDED}"
else
    fail_test "if-guard pattern: execution did NOT continue after failing command"
fi

count_test
RECORDED_CODE=$(cat "${TEMP_DIR}/exit_code.txt" 2>/dev/null || echo "MISSING")
if [ "$RECORDED_CODE" = "42" ]; then
    pass_test "if-guard pattern: non-zero exit code (42) correctly captured via \$?"
else
    fail_test "if-guard pattern: expected captured exit code 42, got '${RECORDED_CODE}'"
fi

# -----------------------------------------------------------------------
# 3. FUNCTIONAL TEST: runner continues past a failing test script
# -----------------------------------------------------------------------
echo ""
echo "=== 3. FUNCTIONAL TEST: runner executes all tests despite failures ==="
echo ""

# Reuse the fixture scripts created for the runner-level checks above.

COLLECTED_OUTPUT=""
COLLECTED_ERRORS=0
COLLECTED_EXIT_CODES=()

for script in "${FAKE_SCRIPTS[@]}"; do
    # Replicate non-verbose branch from run_all_tests.sh (PR version)
    if THIS_OUTPUT=$(bash "${script}" 2>&1); then
        THIS_EXIT=0
    else
        THIS_EXIT=$?
    fi

    COLLECTED_OUTPUT="${COLLECTED_OUTPUT}${THIS_OUTPUT}"$'\n'
    COLLECTED_EXIT_CODES+=("$THIS_EXIT")
    if [ $THIS_EXIT -ne 0 ]; then
        COLLECTED_ERRORS=$((COLLECTED_ERRORS + 1))
    fi
done

# Also run the verbose branch (streams output instead of capturing it)
VERBOSE_ERRORS=0
for script in "${FAKE_SCRIPTS[@]}"; do
    # Replicate verbose branch from run_all_tests.sh (PR version)
    if bash "${script}" > /dev/null 2>&1; then
        V_EXIT=0
    else
        V_EXIT=$?
    fi
    if [ $V_EXIT -ne 0 ]; then
        VERBOSE_ERRORS=$((VERBOSE_ERRORS + 1))
    fi
done

# Verify both test scripts were executed (sentinels appear in captured output)
count_test
if echo "${COLLECTED_OUTPUT}" | grep -q "SENTINEL_A_RAN"; then
    pass_test "Failing test script (test_a) ran and produced output"
else
    fail_test "Failing test script (test_a) did NOT run — runner aborted early (regression)"
fi

count_test
if echo "${COLLECTED_OUTPUT}" | grep -q "SENTINEL_B_RAN"; then
    pass_test "Passing test script (test_b) ran after the failing test_a"
else
    fail_test "Passing test script (test_b) did NOT run — runner aborted after test_a failure (regression)"
fi

# Exactly one test should have failed
count_test
if [ "$COLLECTED_ERRORS" -eq 1 ]; then
    pass_test "Non-verbose branch: correctly recorded 1 failure out of 2 tests"
else
    fail_test "Non-verbose branch: recorded ${COLLECTED_ERRORS} failures; expected 1"
fi

# Verbose branch should also record exactly one failure
count_test
if [ "$VERBOSE_ERRORS" -eq 1 ]; then
    pass_test "Verbose branch: correctly recorded 1 failure out of 2 tests"
else
    fail_test "Verbose branch: recorded ${VERBOSE_ERRORS} failures; expected 1"
fi

# Two exit codes should have been captured (one per script)
count_test
if [ "${#COLLECTED_EXIT_CODES[@]}" -eq 2 ]; then
    pass_test "Both test exit codes were captured (${COLLECTED_EXIT_CODES[0]} and ${COLLECTED_EXIT_CODES[1]})"
else
    fail_test "Expected 2 captured exit codes, got ${#COLLECTED_EXIT_CODES[@]}"
fi

# -----------------------------------------------------------------------
# 4. REGRESSION TEST: unguarded child failures abort the loop
# -----------------------------------------------------------------------
echo ""
echo "=== 4. REGRESSION TEST: old behavior (unguarded command) would abort ==="
echo ""

# Run the old-behavior loop using the same explicit array. With set -e active
# and no child invocation guard, the loop should abort after test_a fails.
if bash -c '
    set -e
    for script in "$@"; do
        # Old behavior: no guard, so a non-zero exit triggers set -e abort.
        bash "$script" > /dev/null 2>&1
    done
' runner-old "${FAKE_SCRIPTS[@]}"; then
    OLD_SUBSHELL_EXIT=0
else
    OLD_SUBSHELL_EXIT=$?
fi

count_test
if [ $OLD_SUBSHELL_EXIT -ne 0 ]; then
    pass_test "Without child invocation guard: subshell aborts on first test failure (demonstrates old behavior)"
else
    fail_test "Without child invocation guard: subshell unexpectedly succeeded — regression check may be invalid"
fi

# With the guard (PR behavior), confirm the loop completes without aborting.
if bash -c '
    set -e
    for script in "$@"; do
        if bash "$script" > /dev/null 2>&1; then
            THIS_EXIT=0
        else
            THIS_EXIT=$?
        fi
    done
' runner-new "${FAKE_SCRIPTS[@]}"; then
    NEW_SUBSHELL_EXIT=0
else
    NEW_SUBSHELL_EXIT=$?
fi

count_test
if [ $NEW_SUBSHELL_EXIT -eq 0 ]; then
    pass_test "With child invocation guard: subshell runs all scripts without aborting (PR behavior confirmed)"
else
    fail_test "With child invocation guard: subshell still exited non-zero (${NEW_SUBSHELL_EXIT}) — guard not effective"
fi

# -----------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------
print_test_summary

if [ "$ERRORS" -eq 0 ]; then
    print_success "RUNNER CONTINUES ON FAILURE TEST PASSED"
    exit 0
else
    print_failure "RUNNER CONTINUES ON FAILURE TEST FAILED"
    exit 1
fi
