#!/bin/bash
# =================================================================
# SBC BST Provenance Test
# Tests: Structural and content validation of files changed in the
#        sbc.bst provenance refactor PR:
#          - bibliography/sbc.bst  (header refactor, blank-line removal,
#                                   EOF newline fix)
#          - docs/sbc-bst-provenance.md  (new provenance document)
#          - README.md  (provenance cross-reference line)
#          - tests/test_line_count_limit.sh  (new test script)
#          - tests/test_sbc_bst_smoke.sh     (new test script)
# =================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SCRIPT_DIR}/test_helpers.sh"

SUMMARY_PRINTED=false

print_summary_once() {
    if [ "${SUMMARY_PRINTED}" = false ]; then
        print_test_summary
        SUMMARY_PRINTED=true
    fi
    return 0
}

trap print_summary_once EXIT

echo "==================================================================="
echo "SBC BST PROVENANCE TEST"
echo "==================================================================="
echo ""

if ! cd "${PROJECT_DIR}"; then
    echo "Failed to cd to ${PROJECT_DIR}" >&2
    exit 1
fi
reset_counters

SBC_BST="${PROJECT_DIR}/bibliography/sbc.bst"
PROVENANCE="${PROJECT_DIR}/docs/sbc-bst-provenance.md"
README="${PROJECT_DIR}/README.md"
LINE_COUNT_SCRIPT="${PROJECT_DIR}/tests/test_line_count_limit.sh"
SMOKE_SCRIPT="${PROJECT_DIR}/tests/test_sbc_bst_smoke.sh"

# =================================================================
echo "=== 1. FILE EXISTENCE ==="
echo ""
# =================================================================

check_file "bibliography/sbc.bst"       "sbc.bst BibTeX style file exists"
check_file "docs/sbc-bst-provenance.md" "sbc-bst provenance doc exists"
check_file "tests/test_line_count_limit.sh" "test_line_count_limit.sh exists"
check_file "tests/test_sbc_bst_smoke.sh"   "test_sbc_bst_smoke.sh exists"

# =================================================================
echo ""
echo "=== 2. bibliography/sbc.bst — HEADER CONTENT ==="
echo ""
# =================================================================

# PR replaced the old 38-line copyright/history block with a 2-line header.
check_present "$SBC_BST" \
    'Runtime BibTeX style' \
    "sbc.bst: new runtime-style header line is present"

check_present "$SBC_BST" \
    'docs/sbc-bst-provenance\.md' \
    "sbc.bst: header cross-references docs/sbc-bst-provenance.md"

check_present "$SBC_BST" \
    'copy of .apalike. for SBC' \
    "sbc.bst: retains original one-line SBC adaptation note"

# =================================================================
echo ""
echo "=== 3. bibliography/sbc.bst — REMOVED VERBOSE BLOCK ==="
echo ""
# =================================================================

# The old verbose copyright/history block that lived in sbc.bst was moved
# entirely to docs/sbc-bst-provenance.md.  Confirm it is gone from the .bst.
check_absent "$SBC_BST" \
    "BibTeX \`apalike' bibliography style \(24-Jan-88 version\)" \
    "sbc.bst: old verbose copyright line removed from .bst"

check_absent "$SBC_BST" \
    'THIS `apalike' \
    "sbc.bst: old BIBTEX version warning comment removed from .bst"

check_absent "$SBC_BST" \
    '15-sep-86' \
    "sbc.bst: old history comments removed from .bst"

# =================================================================
echo ""
echo "=== 4. bibliography/sbc.bst — FUNCTIONAL INTEGRITY ==="
echo ""
# =================================================================

# The whitespace-only refactor must not break the BibTeX directives.
check_present "$SBC_BST" 'ENTRY'             "sbc.bst: ENTRY block present"
check_present "$SBC_BST" 'INTEGERS'          "sbc.bst: INTEGERS declaration present"
check_present "$SBC_BST" 'STRINGS'           "sbc.bst: STRINGS declaration present"
check_present "$SBC_BST" 'ITERATE'           "sbc.bst: ITERATE command present"
check_present "$SBC_BST" 'EXECUTE \{end\.bib\}' "sbc.bst: EXECUTE {end.bib} present"
check_present "$SBC_BST" 'FUNCTION \{article\}' "sbc.bst: article entry type defined"
check_present "$SBC_BST" 'MACRO \{jan\}'     "sbc.bst: month macros present"

# Verify file ends with a newline.  In a $() subshell, trailing newlines are
# stripped; so if the last byte IS a newline the result is an empty string.
count_test
last_char="$(tail -c 1 "$SBC_BST")"
if [ -z "$last_char" ]; then
    pass_test "sbc.bst: file ends with a newline (EOF newline fix verified)"
else
    fail_test "sbc.bst: file is missing trailing newline"
fi

# =================================================================
echo ""
echo "=== 5. docs/sbc-bst-provenance.md — DOCUMENT STRUCTURE ==="
echo ""
# =================================================================

check_present "$PROVENANCE" \
    '^# .*sbc\.bst.*Provenance' \
    "provenance doc: top-level title is present"

check_present "$PROVENANCE" \
    '^## Original .*apalike.*Notes' \
    "provenance doc: 'Original apalike Notes' section present"

check_present "$PROVENANCE" \
    '^## Editorial Note' \
    "provenance doc: 'Editorial Note' section present"

check_present "$PROVENANCE" \
    '^## History' \
    "provenance doc: 'History' section present"

# =================================================================
echo ""
echo "=== 6. docs/sbc-bst-provenance.md — CONTENT FROM REMOVED BLOCK ==="
echo ""
# =================================================================

# All copyright/history content removed from sbc.bst must appear here.
check_present "$PROVENANCE" \
    '1988' \
    "provenance doc: copyright year 1988 present"

check_present "$PROVENANCE" \
    'Susan King' \
    "provenance doc: original author Susan King mentioned"

check_present "$PROVENANCE" \
    'Oren Patashnik' \
    "provenance doc: original author Oren Patashnik mentioned"

check_present "$PROVENANCE" \
    '15-sep-86' \
    "provenance doc: original history date 15-sep-86 present"

check_present "$PROVENANCE" \
    '10-nov-86' \
    "provenance doc: history date 10-nov-86 present"

check_present "$PROVENANCE" \
    '24-jan-88' \
    "provenance doc: history date 24-jan-88 present"

check_present "$PROVENANCE" \
    'does not work with BibTeX 0\.98i' \
    "provenance doc: BibTeX 0.98i compatibility note present"

check_present "$PROVENANCE" \
    'bibliography/sbc\.bst' \
    "provenance doc: back-reference to bibliography/sbc.bst present"

# File must be non-empty (sanity check)
count_test
if [ -s "$PROVENANCE" ]; then
    pass_test "provenance doc: file is non-empty"
else
    fail_test "provenance doc: file is empty"
fi

# =================================================================
echo ""
echo "=== 7. README.md — PROVENANCE CROSS-REFERENCE ==="
echo ""
# =================================================================

check_present "$README" \
    'docs/sbc-bst-provenance\.md' \
    "README.md: references docs/sbc-bst-provenance.md"

check_present "$README" \
    'sbc\.bst.*provenance|provenance.*sbc\.bst' \
    "README.md: provenance line links sbc.bst to the provenance doc"

# =================================================================
echo ""
echo "=== 8. tests/test_line_count_limit.sh — SCRIPT CONTENT ==="
echo ""
# =================================================================

# Script must be executable.
count_test
if [ -x "$LINE_COUNT_SCRIPT" ]; then
    pass_test "test_line_count_limit.sh: is executable"
else
    fail_test "test_line_count_limit.sh: not executable (chmod +x required)"
fi

check_present "$LINE_COUNT_SCRIPT" \
    'LINE_LIMIT=1000' \
    "test_line_count_limit.sh: LINE_LIMIT set to 1000"

check_present "$LINE_COUNT_SCRIPT" \
    'test_helpers\.sh' \
    "test_line_count_limit.sh: sources test_helpers.sh"

check_present "$LINE_COUNT_SCRIPT" \
    'git ls-files' \
    "test_line_count_limit.sh: uses git ls-files to enumerate tracked files"

check_present "$LINE_COUNT_SCRIPT" \
    'assets/\*' \
    "test_line_count_limit.sh: excludes assets/ directory from line-count check"

check_present "$LINE_COUNT_SCRIPT" \
    'grep.*-I' \
    "test_line_count_limit.sh: uses grep -I to skip binary files"

check_present "$LINE_COUNT_SCRIPT" \
    'VIOLATIONS' \
    "test_line_count_limit.sh: tracks violations in VIOLATIONS array"

# =================================================================
echo ""
echo "=== 9. tests/test_sbc_bst_smoke.sh — SCRIPT CONTENT ==="
echo ""
# =================================================================

# Script must be executable.
count_test
if [ -x "$SMOKE_SCRIPT" ]; then
    pass_test "test_sbc_bst_smoke.sh: is executable"
else
    fail_test "test_sbc_bst_smoke.sh: not executable (chmod +x required)"
fi

check_present "$SMOKE_SCRIPT" \
    'test_helpers\.sh' \
    "test_sbc_bst_smoke.sh: sources test_helpers.sh"

check_present "$SMOKE_SCRIPT" \
    'bibliography/sbc\.bst' \
    "test_sbc_bst_smoke.sh: references bibliography/sbc.bst"

check_present "$SMOKE_SCRIPT" \
    'bibliography/sbc-template\.bib' \
    "test_sbc_bst_smoke.sh: references bibliography/sbc-template.bib"

check_present "$SMOKE_SCRIPT" \
    'bibtex' \
    "test_sbc_bst_smoke.sh: invokes bibtex"

check_present "$SMOKE_SCRIPT" \
    'pdflatex' \
    "test_sbc_bst_smoke.sh: invokes pdflatex"

check_present "$SMOKE_SCRIPT" \
    'cleanup' \
    "test_sbc_bst_smoke.sh: defines cleanup function for temp dir"

check_present "$SMOKE_SCRIPT" \
    'trap.*EXIT' \
    "test_sbc_bst_smoke.sh: registers trap to call cleanup on EXIT"

check_present "$SMOKE_SCRIPT" \
    'sbc-smoke\.bbl' \
    "test_sbc_bst_smoke.sh: checks for .bbl output file"

# =================================================================
echo ""
echo "=== 10. CROSS-DOCUMENT CONSISTENCY ==="
echo ""
# =================================================================

# sbc.bst should reference the same path that exists on disk.
count_test
bst_ref=$(grep -o 'docs/sbc-bst-provenance\.md' "$SBC_BST" 2>/dev/null | head -1)
if [ "$bst_ref" = "docs/sbc-bst-provenance.md" ] && [ -f "${PROJECT_DIR}/docs/sbc-bst-provenance.md" ]; then
    pass_test "cross-doc: sbc.bst header path matches actual file location"
else
    fail_test "cross-doc: sbc.bst header path does not match actual file location"
fi

# provenance doc should reference the actual .bst path.
count_test
prov_ref=$(grep -o 'bibliography/sbc\.bst' "$PROVENANCE" 2>/dev/null | head -1)
if [ "$prov_ref" = "bibliography/sbc.bst" ] && [ -f "${PROJECT_DIR}/bibliography/sbc.bst" ]; then
    pass_test "cross-doc: provenance doc path matches actual sbc.bst location"
else
    fail_test "cross-doc: provenance doc path does not match actual sbc.bst location"
fi

# =================================================================
print_summary_once

if [[ "${ERRORS:-0}" -eq 0 ]]; then
    echo ""
    print_success "SBC BST PROVENANCE TEST PASSED"
    exit 0
else
    echo ""
    print_failure "SBC BST PROVENANCE TEST FAILED"
    exit 1
fi
