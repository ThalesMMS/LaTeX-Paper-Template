#!/bin/bash
# =================================================================
# Line Count Limit Test
# Tests: Verifies tracked text/code files stay under the line limit
# =================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SCRIPT_DIR}/test_helpers.sh"

echo "==================================================================="
echo "LINE COUNT LIMIT TEST"
echo "==================================================================="
echo ""

cd "${PROJECT_DIR}"

LINE_LIMIT=1000
CHECKED_FILES=0
VIOLATIONS=()

logical_line_count() {
    local file=$1
    local count
    local last_char

    count=$(wc -l < "$file" | tr -d ' ')

    if [ -s "$file" ]; then
        # Command substitution strips a trailing newline, so an empty result
        # means the final byte is '\n'; any non-empty byte needs one more line.
        last_char=$(tail -c 1 "$file")
        if [ -n "$last_char" ]; then
            count=$((count + 1))
        fi
    fi

    printf '%s\n' "$count"
}

echo "=== 1. CHECKING TRACKED TEXT FILES ==="
echo ""

if ! command -v git >/dev/null 2>&1; then
    count_test
    fail_test "git is required to enumerate tracked files"
else
    while IFS= read -r -d '' file; do
        [ -f "$file" ] || continue

        # Binary assets are not code/text and should not count toward the limit.
        case "$file" in
            assets/*)
                continue
                ;;
        esac

        if [ ! -s "$file" ] || LC_ALL=C grep -Iq '' "$file"; then
            CHECKED_FILES=$((CHECKED_FILES + 1))
            line_count=$(logical_line_count "$file")
            if [ "$line_count" -gt "$LINE_LIMIT" ]; then
                VIOLATIONS+=("${line_count} ${file}")
            fi
        fi
    done < <(git ls-files -z)

    count_test
    if [ ${#VIOLATIONS[@]} -eq 0 ]; then
        pass_test "No tracked text/code file exceeds ${LINE_LIMIT} lines (${CHECKED_FILES} files checked)"
    else
        fail_test "Tracked text/code files exceed ${LINE_LIMIT} lines"
        printf '%s\n' "${VIOLATIONS[@]}"
    fi
fi

print_test_summary

if [[ "${ERRORS:-0}" -eq 0 ]]; then
    echo ""
    print_success "LINE COUNT LIMIT TEST PASSED"
    exit 0
else
    echo ""
    print_failure "LINE COUNT LIMIT TEST FAILED"
    exit 1
fi
