#!/bin/bash
# =================================================================
# Test: Documentation structure and content validation
# Tests: Structural integrity and required content of the files
#        added or modified in the release-process PR:
#          - CHANGELOG.md
#          - README.md (Project Status section)
#          - docs/release-checklist.md
# =================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [ ! -r "${SCRIPT_DIR}/test_helpers.sh" ]; then
    echo "ERROR: test helpers not found or unreadable: ${SCRIPT_DIR}/test_helpers.sh" >&2
    exit 1
fi

if ! source "${SCRIPT_DIR}/test_helpers.sh"; then
    echo "ERROR: failed to source test helpers: ${SCRIPT_DIR}/test_helpers.sh" >&2
    exit 1
fi

echo "==================================================================="
echo "DOCUMENTATION STRUCTURE TEST"
echo "==================================================================="
echo ""

if ! cd "${PROJECT_DIR}"; then
    echo "ERROR: failed to change to project directory: ${PROJECT_DIR}" >&2
    exit 1
fi

reset_counters

CHANGELOG="${PROJECT_DIR}/CHANGELOG.md"
README="${PROJECT_DIR}/README.md"
RELEASE_CHECKLIST="${PROJECT_DIR}/docs/release-checklist.md"

check_pattern() {
    local file=$1
    local pattern=$2
    local desc=$3
    count_test
    if grep -Eq "$pattern" "$file" 2>/dev/null; then
        pass_test "$desc"
        return 0
    else
        fail_test "$desc (PATTERN NOT FOUND: $pattern)"
        return 0
    fi
}

check_text_pattern() {
    local text=$1
    local pattern=$2
    local desc=$3
    count_test
    if printf '%s\n' "$text" | grep -Eq "$pattern" 2>/dev/null; then
        pass_test "$desc"
        return 0
    else
        fail_test "$desc (PATTERN NOT FOUND: $pattern)"
        return 0
    fi
}

check_text_pattern_i() {
    local text=$1
    local pattern=$2
    local desc=$3
    count_test
    if printf '%s\n' "$text" | grep -Eiq "$pattern" 2>/dev/null; then
        pass_test "$desc"
        return 0
    else
        fail_test "$desc (PATTERN NOT FOUND: $pattern)"
        return 0
    fi
}

check_min_line_count() {
    local file=$1
    local min_lines=$2
    local pass_desc=$3
    local fail_desc=$4
    local line_count
    count_test

    if [ ! -f "$file" ]; then
        fail_test "$fail_desc (file not found)"
        return 0
    fi

    line_count=$(wc -l < "$file")
    if [ "$line_count" -ge "$min_lines" ]; then
        pass_test "$pass_desc (${line_count} lines)"
    else
        fail_test "$fail_desc (${line_count} lines)"
    fi

    return 0
}

# -----------------------------------------------------------------------
# 1. FILE EXISTENCE
# -----------------------------------------------------------------------
echo "=== 1. REQUIRED FILES EXIST ==="
echo ""

check_file "${CHANGELOG}"        "CHANGELOG.md present" || true
check_file "${README}"           "README.md present" || true
check_file "${RELEASE_CHECKLIST}" "docs/release-checklist.md present" || true

# -----------------------------------------------------------------------
# 2. CHANGELOG.md STRUCTURE
# -----------------------------------------------------------------------
echo ""
echo "=== 2. CHANGELOG.md STRUCTURE ==="
echo ""

# Title
check_pattern "${CHANGELOG}" "^# Changelog" \
    "CHANGELOG.md: top-level '# Changelog' heading"

# Keep a Changelog reference (required by stated format)
check_pattern "${CHANGELOG}" "Keep a Changelog" \
    "CHANGELOG.md: references Keep a Changelog standard"

# Semantic Versioning reference
check_pattern "${CHANGELOG}" "Semantic Versioning" \
    "CHANGELOG.md: references Semantic Versioning"

# Unreleased section must exist
check_pattern "${CHANGELOG}" "^## \[Unreleased\]" \
    "CHANGELOG.md: '## [Unreleased]' section present"

# v1.0.0 release section
check_pattern "${CHANGELOG}" "^## \[v1\.0\.0\]" \
    "CHANGELOG.md: '## [v1.0.0]' release section present"

# v1.0.0 must carry a release date in ISO format (YYYY-MM-DD)
check_pattern "${CHANGELOG}" "\[v1\.0\.0\].*[0-9]{4}-[0-9]{2}-[0-9]{2}" \
    "CHANGELOG.md: v1.0.0 entry has a date in YYYY-MM-DD format"

# Required subsections under Unreleased
UNRELEASED=""
if [ -f "${CHANGELOG}" ]; then
    UNRELEASED=$(awk '
        /^## \[Unreleased\]/ {
            in_section = 1
            print
            next
        }
        in_section && /^## \[/ {
            exit
        }
        in_section {
            print
        }
    ' "${CHANGELOG}")
fi

check_text_pattern "${UNRELEASED}" "^### Added" \
    "CHANGELOG.md: '### Added' subsection present"

check_text_pattern "${UNRELEASED}" "^### Changed" \
    "CHANGELOG.md: '### Changed' subsection present"

check_text_pattern "${UNRELEASED}" "^### Fixed" \
    "CHANGELOG.md: '### Fixed' subsection present"

check_text_pattern "${UNRELEASED}" "^### Removed" \
    "CHANGELOG.md: '### Removed' subsection present"

# v1.0.0 must document the key deliverables introduced in that release
check_pattern "${CHANGELOG}" "quick-start\.sh" \
    "CHANGELOG.md: v1.0.0 documents quick-start.sh"

check_pattern "${CHANGELOG}" "init-project\.sh" \
    "CHANGELOG.md: v1.0.0 documents init-project.sh"

check_pattern "${CHANGELOG}" "GitHub Actions" \
    "CHANGELOG.md: v1.0.0 documents GitHub Actions CI"

# -----------------------------------------------------------------------
# 3. README.md — Project Status section
# -----------------------------------------------------------------------
echo ""
echo "=== 3. README.md PROJECT STATUS SECTION ==="
echo ""

# New section heading
PROJECT_STATUS=""
if [ -f "${README}" ]; then
    PROJECT_STATUS=$(awk '
        /^## Project Status/ {
            in_section = 1
            print
            next
        }
        in_section && /^## / {
            exit
        }
        in_section {
            print
        }
    ' "${README}")
fi

check_text_pattern "${PROJECT_STATUS}" "^## Project Status" \
    "README.md: '## Project Status' section present"

# Stability statement
check_text_pattern_i "${PROJECT_STATUS}" \
    '(^|[^[:alnum:]_])(stable|experimental|prerelease|deprecated)([^[:alnum:]_]|$)' \
    "README.md: project posture present in Project Status section"

# Link to CHANGELOG.md
check_text_pattern "${PROJECT_STATUS}" "CHANGELOG\.md" \
    "README.md: links to CHANGELOG.md"

# Link to docs/release-checklist.md
check_text_pattern "${PROJECT_STATUS}" "docs/release-checklist\.md" \
    "README.md: links to docs/release-checklist.md"

# Releases and Versioning sub-section
check_text_pattern "${PROJECT_STATUS}" "[Rr]eleases.*[Vv]ersioning|[Vv]ersioning.*[Rr]eleases" \
    "README.md: 'Releases and Versioning' subsection present"

# Reproducible-setup guidance (pin to a release tag)
check_text_pattern "${PROJECT_STATUS}" "git clone.*--branch|--branch.*git clone" \
    "README.md: reproducible setup example uses 'git clone --branch'"

# Example references a concrete tag
check_text_pattern "${PROJECT_STATUS}" "v[0-9]+\\.[0-9]+\\.[0-9]+" \
    "README.md: example uses a versioned tag (vMAJOR.MINOR.PATCH)"

# -----------------------------------------------------------------------
# 4. docs/release-checklist.md STRUCTURE
# -----------------------------------------------------------------------
echo ""
echo "=== 4. docs/release-checklist.md STRUCTURE ==="
echo ""

# Title
check_pattern "${RELEASE_CHECKLIST}" "^# Release Checklist" \
    "release-checklist.md: top-level '# Release Checklist' heading"

# Pre-release validation section
check_pattern "${RELEASE_CHECKLIST}" "^## Pre-release validation" \
    "release-checklist.md: '## Pre-release validation' section present"

# The checklist must reference the test runner command
check_pattern "${RELEASE_CHECKLIST}" "tests/run_all_tests\.sh" \
    "release-checklist.md: references 'tests/run_all_tests.sh'"

# Three document variants must be named
check_pattern "${RELEASE_CHECKLIST}" "paper-main\.tex" \
    "release-checklist.md: names paper-main.tex variant"

check_pattern "${RELEASE_CHECKLIST}" "monograph-main\.tex" \
    "release-checklist.md: names monograph-main.tex variant"

check_pattern "${RELEASE_CHECKLIST}" "thesis-main\.tex" \
    "release-checklist.md: names thesis-main.tex variant"

# Both external bibliography backends must be mentioned
check_pattern "${RELEASE_CHECKLIST}" "BibTeX" \
    "release-checklist.md: mentions BibTeX backend"

check_pattern "${RELEASE_CHECKLIST}" "BibLaTeX|Biber|biber" \
    "release-checklist.md: mentions BibLaTeX/Biber backend"

# Reproducibility bundle section
check_pattern "${RELEASE_CHECKLIST}" "^## Reproducibility bundle" \
    "release-checklist.md: '## Reproducibility bundle' section present"

# Reproducibility bundle must require commit SHA
check_pattern "${RELEASE_CHECKLIST}" "\\b[Cc]ommit SHA\\b" \
    "release-checklist.md: reproducibility bundle requires commit SHA"

# Toolchain versions required
check_pattern "${RELEASE_CHECKLIST}" "pdflatex" \
    "release-checklist.md: toolchain baseline includes pdflatex"

check_pattern "${RELEASE_CHECKLIST}" "bibtex|BibTeX" \
    "release-checklist.md: toolchain baseline includes bibtex"

check_pattern "${RELEASE_CHECKLIST}" "biber|Biber" \
    "release-checklist.md: toolchain baseline includes biber"

check_pattern "${RELEASE_CHECKLIST}" "[Tt]e[Xx] [Ll]ive|texlive" \
    "release-checklist.md: toolchain baseline includes TeX Live version"

# GitHub release process section
check_pattern "${RELEASE_CHECKLIST}" "^## GitHub release process" \
    "release-checklist.md: '## GitHub release process' section present"

# Release process must mention updating CHANGELOG.md
check_pattern "${RELEASE_CHECKLIST}" "CHANGELOG\.md" \
    "release-checklist.md: release process references CHANGELOG.md"

# Release process must include git tag step
check_pattern "${RELEASE_CHECKLIST}" "git tag" \
    "release-checklist.md: release process includes 'git tag' step"

# Release process must include git push step
check_pattern "${RELEASE_CHECKLIST}" "git push" \
    "release-checklist.md: release process includes 'git push' step"

# Version increments section
check_pattern "${RELEASE_CHECKLIST}" "^## Version increments" \
    "release-checklist.md: '## Version increments' section present"

# Version format must follow vMAJOR.MINOR.PATCH
check_pattern "${RELEASE_CHECKLIST}" "vMAJOR\.MINOR\.PATCH|MAJOR\.MINOR\.PATCH" \
    "release-checklist.md: documents vMAJOR.MINOR.PATCH versioning scheme"

# PATCH, MINOR, MAJOR increment rules must be described
check_pattern "${RELEASE_CHECKLIST}" "[Ii]ncrement.*PATCH|PATCH.*[Ii]ncrement" \
    "release-checklist.md: describes when to increment PATCH"

check_pattern "${RELEASE_CHECKLIST}" "[Ii]ncrement.*MINOR|MINOR.*[Ii]ncrement" \
    "release-checklist.md: describes when to increment MINOR"

check_pattern "${RELEASE_CHECKLIST}" "[Ii]ncrement.*MAJOR|MAJOR.*[Ii]ncrement" \
    "release-checklist.md: describes when to increment MAJOR"

# -----------------------------------------------------------------------
# 5. CROSS-DOCUMENT LINK CONSISTENCY
# -----------------------------------------------------------------------
echo ""
echo "=== 5. CROSS-DOCUMENT LINK CONSISTENCY ==="
echo ""

# README links to CHANGELOG.md and docs/release-checklist.md; verify those
# targets actually exist on disk (they are relative to the project root)
count_test
if [ -f "${PROJECT_DIR}/CHANGELOG.md" ]; then
    pass_test "Cross-link: README.md -> CHANGELOG.md target exists on disk"
else
    fail_test "Cross-link: CHANGELOG.md referenced in README.md but file not found"
fi

count_test
if [ -f "${PROJECT_DIR}/docs/release-checklist.md" ]; then
    pass_test "Cross-link: README.md -> docs/release-checklist.md target exists on disk"
else
    fail_test "Cross-link: docs/release-checklist.md referenced in README.md but file not found"
fi

# release-checklist.md references run_all_tests.sh; verify that target exists
count_test
if [ -f "${PROJECT_DIR}/tests/run_all_tests.sh" ]; then
    pass_test "Cross-link: release-checklist.md -> tests/run_all_tests.sh target exists on disk"
else
    fail_test "Cross-link: tests/run_all_tests.sh referenced in release-checklist.md but file not found"
fi

# -----------------------------------------------------------------------
# 6. BOUNDARY / NEGATIVE CASES
# -----------------------------------------------------------------------
echo ""
echo "=== 6. BOUNDARY AND NEGATIVE CASES ==="
echo ""

# CHANGELOG.md must not be empty
check_min_line_count "${CHANGELOG}" 5 \
    "CHANGELOG.md is non-trivial" \
    "CHANGELOG.md appears empty or trivially short"

# docs/release-checklist.md must not be empty
check_min_line_count "${RELEASE_CHECKLIST}" 10 \
    "docs/release-checklist.md is non-trivial" \
    "docs/release-checklist.md appears empty or trivially short"

# README.md must contain the new section AFTER any existing sections —
# specifically the 'Project Status' section must appear before 'Template Variants'
count_test
STATUS_LINE=$(grep -n "^## Project Status" "${README}" 2>/dev/null | head -1 | cut -d: -f1)
VARIANTS_LINE=$(grep -n "^## Template Variants" "${README}" 2>/dev/null | head -1 | cut -d: -f1)
if [ -n "$STATUS_LINE" ] && [ -n "$VARIANTS_LINE" ] && [ "$STATUS_LINE" -lt "$VARIANTS_LINE" ]; then
    pass_test "README.md: 'Project Status' section appears before 'Template Variants' section (correct order)"
else
    fail_test "README.md: 'Project Status' section ordering unexpected (status line=${STATUS_LINE}, variants line=${VARIANTS_LINE})"
fi

# CHANGELOG.md: Unreleased section must appear before v1.0.0 section (newest first)
count_test
UNRELEASED_LINE=$(grep -n "^## \[Unreleased\]" "${CHANGELOG}" 2>/dev/null | head -1 | cut -d: -f1)
V100_LINE=$(grep -n "^## \[v1\.0\.0\]" "${CHANGELOG}" 2>/dev/null | head -1 | cut -d: -f1)
if [ -n "$UNRELEASED_LINE" ] && [ -n "$V100_LINE" ] && [ "$UNRELEASED_LINE" -lt "$V100_LINE" ]; then
    pass_test "CHANGELOG.md: [Unreleased] section appears before [v1.0.0] (newest-first order)"
else
    fail_test "CHANGELOG.md: section ordering unexpected (Unreleased line=${UNRELEASED_LINE}, v1.0.0 line=${V100_LINE})"
fi

finish_test_run() {
    print_test_summary

    if [ "$ERRORS" -eq 0 ]; then
        print_success "DOCUMENTATION STRUCTURE TEST PASSED"
        exit 0
    else
        print_failure "DOCUMENTATION STRUCTURE TEST FAILED"
        exit 1
    fi
}

# -----------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------
finish_test_run
