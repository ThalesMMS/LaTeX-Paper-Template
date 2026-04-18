#!/bin/bash
# =================================================================
# SBC BibTeX Style Smoke Test
# Tests: Verifies bibliography/sbc.bst is directly usable by BibTeX
# =================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SCRIPT_DIR}/test_helpers.sh"

echo "==================================================================="
echo "SBC BIBTEX STYLE SMOKE TEST"
echo "==================================================================="
echo ""

if ! cd "${PROJECT_DIR}"; then
    echo "Failed to cd to ${PROJECT_DIR}" >&2
    exit 1
fi

TEST_DIR=""

if ! TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sbc-bst-smoke.XXXXXX")"; then
    count_test
    fail_test "Created temporary test directory"
    print_test_summary
    exit 1
fi

# cleanup removes the TEST_DIR directory and all its contents.
cleanup() {
    if [ -n "${TEST_DIR:-}" ]; then
        rm -rf "${TEST_DIR}"
    fi
}

trap cleanup EXIT

echo "=== 1. PRE-COMPILATION CHECKS ==="
echo ""

check_file "bibliography/sbc.bst" "SBC BibTeX style exists"
check_file "bibliography/sbc-template.bib" "SBC BibTeX database exists"

check_cmd pdflatex "pdflatex is installed"
check_cmd bibtex "bibtex is installed"

if [[ "${ERRORS:-0}" -ne 0 ]]; then
    print_test_summary
    print_failure "SBC BIBTEX STYLE SMOKE TEST SKIPPED"
    exit 1
fi

cat > "${TEST_DIR}/sbc-smoke.tex" << 'EOF'
\documentclass{article}
\begin{document}
Citations: \cite{knuth:84,boulic:91,smith:99}.
\bibliographystyle{sbc}
\bibliography{sbc-template}
\end{document}
EOF

echo ""
echo "=== 2. RUNNING BIBTEX WORKFLOW ==="
echo ""

if ! cd "${TEST_DIR}"; then
    echo "Failed to cd to ${TEST_DIR}" >&2
    exit 1
fi

count_test
if pdflatex -interaction=nonstopmode -halt-on-error -file-line-error sbc-smoke.tex > pdflatex-1.log 2>&1; then
    pass_test "Initial pdflatex pass completed"
else
    fail_test "Initial pdflatex pass failed"
    tail -n 40 pdflatex-1.log
fi

count_test
if BIBINPUTS="${PROJECT_DIR}/bibliography:${BIBINPUTS:-}" \
   BSTINPUTS="${PROJECT_DIR}/bibliography:${BSTINPUTS:-}" \
   bibtex sbc-smoke > bibtex.log 2>&1; then
    pass_test "BibTeX processed bibliography/sbc.bst"
else
    fail_test "BibTeX failed to process bibliography/sbc.bst"
    tail -n 60 bibtex.log
fi

check_file "${TEST_DIR}/sbc-smoke.bbl" "BibTeX generated .bbl output"

count_test
if grep -Fq '\bibitem[Knuth 1984]{knuth:84}' "${TEST_DIR}/sbc-smoke.bbl"; then
    pass_test "SBC citation label format preserved"
else
    fail_test "Expected SBC citation label not found in .bbl"
    sed -n '1,80p' "${TEST_DIR}/sbc-smoke.bbl" 2>/dev/null || true
fi

count_test
if pdflatex -interaction=nonstopmode -halt-on-error -file-line-error sbc-smoke.tex > pdflatex-2.log 2>&1 &&
   pdflatex -interaction=nonstopmode -halt-on-error -file-line-error sbc-smoke.tex > pdflatex-3.log 2>&1; then
    pass_test "Final pdflatex passes completed"
else
    fail_test "Final pdflatex passes failed"
    tail -n 40 pdflatex-3.log 2>/dev/null || tail -n 40 pdflatex-2.log
fi

check_file "${TEST_DIR}/sbc-smoke.pdf" "Smoke-test PDF created"

count_test
if [ -s "${TEST_DIR}/sbc-smoke.pdf" ]; then
    pass_test "Smoke-test PDF has non-zero size"
else
    fail_test "Smoke-test PDF is empty"
fi

print_test_summary

if [[ "${ERRORS:-0}" -eq 0 ]]; then
    echo ""
    print_success "SBC BIBTEX STYLE SMOKE TEST PASSED"
    exit 0
else
    echo ""
    print_failure "SBC BIBTEX STYLE SMOKE TEST FAILED"
    exit 1
fi
