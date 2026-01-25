#!/bin/bash
# =================================================================
# LaTeX Warning Detection Test
# Tests: Verifies that the build system correctly detects LaTeX warnings
# Note: Creates temporary test documents with various warning types
# =================================================================

set -e  # Exit on first error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test_helpers.sh"

echo "==================================================================="
echo "LATEX WARNING DETECTION TEST"
echo "==================================================================="
echo ""

# Move to template root directory (parent of tests/)
cd "$SCRIPT_DIR/.."

# Create temporary test directory
TEST_DIR=".test-warnings"
mkdir -p "$TEST_DIR"

# Cleanup function
cleanup() {
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}

# Register cleanup on exit
trap cleanup EXIT

echo "=== 1. PRE-TEST CHECKS ==="
echo ""

# Check for LaTeX installation
count_test
if command -v pdflatex >/dev/null 2>&1; then
    pass_test "pdflatex is installed"
else
    fail_test "pdflatex not found (LaTeX distribution required)"
    print_test_summary
    print_failure "WARNING DETECTION TEST SKIPPED - PDFLATEX NOT INSTALLED"
    exit 1
fi

# Check Makefile exists
check_file "Makefile" "Makefile exists"

echo ""
echo "=== 2. UNDEFINED REFERENCE WARNING DETECTION ==="
echo ""

# Create a document with undefined references
cat > "$TEST_DIR/test_undefined_ref.tex" << 'EOF'
\documentclass{article}
\begin{document}
This is a test document with an undefined reference: \ref{nonexistent}.
Another undefined reference: \ref{missing}.
\end{document}
EOF

count_test
echo -e "${BLUE}Compiling document with undefined references...${NC}"
mkdir -p "$TEST_DIR/output"
if pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory="$TEST_DIR/output" "$TEST_DIR/test_undefined_ref.tex" > /dev/null 2>&1; then
    # Run second pass to generate warnings
    pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory="$TEST_DIR/output" "$TEST_DIR/test_undefined_ref.tex" > "$TEST_DIR/output/build.log" 2>&1 || true

    # Check if undefined references are detected in log
    if grep -Eq "Reference.*undefined|Undefined references" "$TEST_DIR/output/build.log"; then
        pass_test "Undefined references detected in log"
    else
        fail_test "Undefined references NOT detected in log"
    fi
else
    warn_test "Compilation failed (expected behavior for some tests)"
fi

echo ""
echo "=== 3. UNDEFINED CITATION WARNING DETECTION ==="
echo ""

# Create a document with undefined citations
cat > "$TEST_DIR/test_undefined_cite.tex" << 'EOF'
\documentclass{article}
\begin{document}
This is a test document with an undefined citation: \cite{nonexistent}.
Another undefined citation: \cite{missing}.
\end{document}
EOF

count_test
echo -e "${BLUE}Compiling document with undefined citations...${NC}"
if pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory="$TEST_DIR/output" "$TEST_DIR/test_undefined_cite.tex" > /dev/null 2>&1; then
    # Run second pass to generate warnings
    pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory="$TEST_DIR/output" "$TEST_DIR/test_undefined_cite.tex" > "$TEST_DIR/output/build.log" 2>&1 || true

    # Check if undefined citations are detected in log
    if grep -Eq "Citation.*undefined|There were undefined citations" "$TEST_DIR/output/build.log"; then
        pass_test "Undefined citations detected in log"
    else
        fail_test "Undefined citations NOT detected in log"
    fi
else
    warn_test "Compilation failed (expected behavior for some tests)"
fi

echo ""
echo "=== 4. MAKEFILE WARNING DETECTION ==="
echo ""

# Test that Makefile correctly detects undefined references
cat > "$TEST_DIR/test_makefile.tex" << 'EOF'
\documentclass{article}
\begin{document}
Test with undefined reference: \ref{missing}.
\end{document}
EOF

# Create a minimal Makefile for testing
cat > "$TEST_DIR/Makefile" << 'EOF'
MAIN_FILE = test_makefile
OUTPUT_DIR = output
ENGINE = pdflatex

compile:
	@mkdir -p $(OUTPUT_DIR)
	@LOG=$(OUTPUT_DIR)/build.log; \
	: > $$LOG; \
	$(ENGINE) -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=$(OUTPUT_DIR) $(MAIN_FILE).tex >> $$LOG 2>&1 || exit 1; \
	$(ENGINE) -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=$(OUTPUT_DIR) $(MAIN_FILE).tex >> $$LOG 2>&1 || exit 1; \
	if grep -Eq "Reference.*undefined|Undefined references|undefined references|Citation.*undefined|There were undefined citations" $$LOG; then \
		echo "Warning detected in Makefile check"; \
		exit 2; \
	fi; \
	echo "Compilation completed"
EOF

count_test
echo -e "${BLUE}Testing Makefile warning detection...${NC}"
cd "$TEST_DIR"
if make compile > /dev/null 2>&1; then
    EXIT_CODE=0
else
    EXIT_CODE=$?
fi
cd ..

if [ $EXIT_CODE -eq 2 ]; then
    pass_test "Makefile correctly exits with code 2 for warnings"
elif [ $EXIT_CODE -eq 0 ]; then
    fail_test "Makefile did not detect warnings (exit code 0)"
else
    fail_test "Makefile compilation failed (exit code $EXIT_CODE)"
fi

echo ""
echo "=== 5. OVERFULL BOX WARNING DETECTION ==="
echo ""

# Create a document with overfull hbox
cat > "$TEST_DIR/test_overfull.tex" << 'EOF'
\documentclass{article}
\begin{document}
\hbox to 1pt{This is a very long line that will definitely cause an overfull hbox warning because it cannot fit in the specified width and LaTeX will complain about it}
\end{document}
EOF

count_test
echo -e "${BLUE}Compiling document with overfull box...${NC}"
if pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory="$TEST_DIR/output" "$TEST_DIR/test_overfull.tex" > "$TEST_DIR/output/build.log" 2>&1; then
    # Check if overfull box warning is detected in log
    if grep -q "Overfull" "$TEST_DIR/output/build.log"; then
        pass_test "Overfull box warning detected in log"
    else
        fail_test "Overfull box warning NOT detected in log"
    fi
else
    warn_test "Compilation had issues"
fi

echo ""
echo "=== 6. CLEAN DOCUMENT (NO WARNINGS) ==="
echo ""

# Create a clean document without warnings
cat > "$TEST_DIR/test_clean.tex" << 'EOF'
\documentclass{article}
\begin{document}
\section{Introduction}
\label{sec:intro}
This is a clean document without warnings.

See Section~\ref{sec:intro} for details.
\end{document}
EOF

count_test
echo -e "${BLUE}Compiling clean document...${NC}"
if pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory="$TEST_DIR/output" "$TEST_DIR/test_clean.tex" > /dev/null 2>&1; then
    pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory="$TEST_DIR/output" "$TEST_DIR/test_clean.tex" > "$TEST_DIR/output/build.log" 2>&1 || true

    # Check that no undefined references are detected
    if ! grep -Eq "Undefined references|Citation.*undefined|There were undefined citations" "$TEST_DIR/output/build.log"; then
        pass_test "Clean document: no undefined references warnings"
    else
        fail_test "Clean document incorrectly flagged warnings"
    fi
else
    fail_test "Clean document compilation failed"
fi

echo ""
echo "=== 7. VERIFYING MAIN MAKEFILE WARNING PATTERNS ==="
echo ""

# Verify the main Makefile has the warning detection patterns
count_test
if grep -q "Undefined references" "Makefile"; then
    pass_test "Main Makefile checks for 'Undefined references'"
else
    fail_test "Main Makefile missing 'Undefined references' check"
fi

count_test
if grep -q "Citation.*undefined" "Makefile"; then
    pass_test "Main Makefile checks for 'Citation.*undefined'"
else
    fail_test "Main Makefile missing 'Citation.*undefined' check"
fi

count_test
if grep -q "There were undefined citations" "Makefile"; then
    pass_test "Main Makefile checks for 'There were undefined citations'"
else
    fail_test "Main Makefile missing 'There were undefined citations' check"
fi

# Print summary
print_test_summary

# Exit with appropriate code
if [ $ERRORS -eq 0 ]; then
    echo ""
    print_success "LATEX WARNING DETECTION TEST PASSED"
    echo ""
    echo "Warning detection system verified:"
    echo "  - Undefined references are detected"
    echo "  - Undefined citations are detected"
    echo "  - Makefile exits with appropriate codes"
    echo "  - Clean documents pass without false warnings"
    echo "  - Overfull box warnings are logged"
    echo ""
    exit 0
else
    echo ""
    print_failure "LATEX WARNING DETECTION TEST FAILED"
    echo ""
    echo "$ERRORS error(s) encountered during warning detection test."
    echo "Please review the warning detection patterns in Makefile."
    echo ""
    exit 1
fi
