#!/bin/bash
# =================================================================
# init-project.sh Integration Test
# Tests: non-interactive initialization and idempotent reruns
# =================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "$SCRIPT_DIR/test_helpers.sh"

TEMP_DIR=""

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

run_init_project() {
    local project_dir=$1
    local variant=$2
    local title=$3
    local author=$4
    local institution=$5
    local location=$6
    local email=$7

    (
        cd "$project_dir" && \
        bash init-project.sh --non-interactive \
            --name "$title" \
            --author "$author" \
            --institution "$institution" \
            --location "$location" \
            --email "$email" \
            --variant "$variant" \
            --biblio thebibliography >/dev/null
    )
}

check_initialized_values() {
    local config_file=$1
    local variant=$2
    local title=$3
    local author=$4
    local institution=$5
    local location=$6
    local email=$7

    check_present "$config_file" "\\\\newcommand\\{\\\\DocumentTitle\\}\\{${title}\\}" "${variant}: DocumentTitle updated"
    check_present "$config_file" "\\\\newcommand\\{\\\\AuthorName\\}\\{${author}\\}" "${variant}: AuthorName updated"
    check_present "$config_file" "\\\\newcommand\\{\\\\AuthorInstitution\\}\\{${institution}\\}" "${variant}: AuthorInstitution updated"
    check_present "$config_file" "\\\\newcommand\\{\\\\AuthorLocation\\}\\{${location}\\}" "${variant}: AuthorLocation updated"
    check_present "$config_file" "\\\\newcommand\\{\\\\AuthorEmail\\}\\{${email}\\}" "${variant}: AuthorEmail updated"
    check_present "$config_file" "pdftitle=\\{\\\\DocumentTitle\\}" "${variant}: pdftitle uses DocumentTitle macro"
    check_present "$config_file" "pdfauthor=\\{\\\\AuthorName\\}" "${variant}: pdfauthor uses AuthorName macro"
}

echo "==================================================================="
echo "INIT-PROJECT INTEGRATION TEST"
echo "==================================================================="
echo ""

TEMP_DIR=$(mktemp -d)
cp -R "$PROJECT_DIR" "$TEMP_DIR/project"
TEST_PROJECT_DIR="$TEMP_DIR/project"

for variant in paper monograph thesis; do
    config_file="$TEST_PROJECT_DIR/config/${variant}-config.tex"

    first_title="Initial ${variant} Title"
    first_author="Initial ${variant} Author"
    first_institution="Initial ${variant} University"
    first_location="Initial ${variant} City -- ST -- Country"
    first_email="initial-${variant}@example.com"

    second_title="Updated ${variant} Title"
    second_author="Updated ${variant} Author"
    second_institution="Updated ${variant} Institute"
    second_location="Updated ${variant} City -- ST -- Country"
    second_email="updated-${variant}@example.com"

    echo "=== Testing ${variant} variant ==="
    echo ""

    count_test
    if run_init_project "$TEST_PROJECT_DIR" "$variant" "$first_title" "$first_author" "$first_institution" "$first_location" "$first_email"; then
        pass_test "${variant}: first non-interactive initialization succeeds"
    else
        fail_test "${variant}: first non-interactive initialization failed"
        continue
    fi

    check_initialized_values "$config_file" "$variant" "$first_title" "$first_author" "$first_institution" "$first_location" "$first_email"

    count_test
    if run_init_project "$TEST_PROJECT_DIR" "$variant" "$second_title" "$second_author" "$second_institution" "$second_location" "$second_email"; then
        pass_test "${variant}: second non-interactive initialization succeeds"
    else
        fail_test "${variant}: second non-interactive initialization failed"
        continue
    fi

    check_initialized_values "$config_file" "$variant" "$second_title" "$second_author" "$second_institution" "$second_location" "$second_email"
    check_absent "$config_file" "\\\\newcommand\\{\\\\DocumentTitle\\}\\{${first_title}\\}" "${variant}: rerun removes original DocumentTitle"
    check_absent "$config_file" "\\\\newcommand\\{\\\\AuthorName\\}\\{${first_author}\\}" "${variant}: rerun removes original AuthorName"
    check_absent "$config_file" "pdftitle=\\{${second_title}\\}" "${variant}: pdftitle does not duplicate literal title"
    check_absent "$config_file" "pdfauthor=\\{${second_author}\\}" "${variant}: pdfauthor does not duplicate literal author"

    echo ""
done

print_test_summary

if [ $ERRORS -eq 0 ]; then
    echo ""
    print_success "INIT-PROJECT INTEGRATION TEST PASSED"
    exit 0
else
    echo ""
    print_failure "INIT-PROJECT INTEGRATION TEST FAILED"
    exit 1
fi
