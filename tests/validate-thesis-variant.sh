#!/bin/bash
# =================================================================
# Validation Script for Thesis Variant
# Tests the thesis-main.tex template structure without compiling
# =================================================================

set -e

echo "=== THESIS VARIANT VALIDATION ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

# Test 1: Check main file exists
echo -n "1. Checking thesis-main.tex exists... "
if [ -f thesis-main.tex ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 2: Check config file exists
echo -n "2. Checking config/thesis-config.tex exists... "
if [ -f config/thesis-config.tex ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 3: Validate LaTeX syntax (basic)
echo -n "3. Validating LaTeX syntax... "
if grep -q '\\documentclass\[12pt\]{report}' thesis-main.tex && \
   grep -q '\\begin{document}' thesis-main.tex && \
   grep -q '\\end{document}' thesis-main.tex; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 4: Check document structure
echo -n "4. Validating document structure... "
if grep -q '\\documentclass\[12pt\]{report}' thesis-main.tex; then
    echo -e "${GREEN}✓${NC} (report documentclass)"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 5: Check front matter (dedication)
echo -n "5. Checking dedication section... "
if grep -q 'input{sections/dedication}' thesis-main.tex; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 6: Check front matter (acknowledgments-thesis)
echo -n "6. Checking acknowledgments-thesis section... "
if grep -q 'input{sections/acknowledgments-thesis}' thesis-main.tex; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 7: Check table of contents
echo -n "7. Checking table of contents... "
if grep -q '\\tableofcontents' thesis-main.tex; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 8: Check list of figures
echo -n "8. Checking list of figures... "
if grep -q '\\listoffigures' thesis-main.tex; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 9: Check list of tables
echo -n "9. Checking list of tables... "
if grep -q '\\listoftables' thesis-main.tex; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 10: Check metadata commands in config
echo -n "10. Checking metadata commands in config... "
if grep -q '\\DocumentTitle' config/thesis-config.tex && \
   grep -q '\\AuthorName' config/thesis-config.tex && \
   grep -q '\\AdvisorName' config/thesis-config.tex && \
   grep -q '\\ThesisType' config/thesis-config.tex; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 11: Check comprehensive packages in config
echo -n "11. Checking comprehensive packages... "
if grep -q 'usepackage.*graphicx' config/thesis-config.tex && \
   grep -q 'usepackage.*hyperref' config/thesis-config.tex && \
   grep -q 'usepackage.*listings' config/thesis-config.tex && \
   grep -q 'usepackage.*amsmath' config/thesis-config.tex && \
   grep -q 'usepackage.*booktabs' config/thesis-config.tex && \
   grep -q 'usepackage.*glossaries' config/thesis-config.tex && \
   grep -q 'usepackage.*tocloft' config/thesis-config.tex; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 12: Check all referenced files exist
echo "12. Checking all referenced files exist:"
REFERENCED_FILES=(
    "config/thesis-config.tex"
    "sections/dedication.tex"
    "sections/abstract.tex"
    "sections/resumo.tex"
    "sections/acknowledgments-thesis.tex"
    "chapters/01-introducao.tex"
    "chapters/02-trabalhos-relacionados.tex"
    "chapters/03-metodologia.tex"
    "chapters/04-avaliacao-resultados.tex"
    "chapters/05-detalhes-implementacao.tex"
    "chapters/06-desafios-tecnicos.tex"
    "chapters/07-trabalhos-futuros.tex"
    "chapters/08-conclusoes-e-contribuicoes.tex"
    "bibliography/references.tex"
)

MISSING_FILES=0
for file in "${REFERENCED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "    ${GREEN}✓${NC} $file"
    else
        echo -e "    ${RED}✗${NC} $file (MISSING)"
        MISSING_FILES=$((MISSING_FILES + 1))
        ERRORS=$((ERRORS + 1))
    fi
done

# Test 13: Check chapter structure
echo -n "13. Checking full chapter structure... "
CHAPTER_COUNT=$(grep -c 'input{chapters/' thesis-main.tex || echo "0")
if [ "$CHAPTER_COUNT" -eq 8 ]; then
    echo -e "${GREEN}✓${NC} (8 chapters included)"
else
    echo -e "${YELLOW}⚠${NC} (found $CHAPTER_COUNT chapters, expected 8)"
fi

# Test 14: Check thesis-specific sections exist
echo "14. Checking thesis-specific section files:"
if [ -f sections/dedication.tex ]; then
    echo -e "    ${GREEN}✓${NC} sections/dedication.tex"
else
    echo -e "    ${RED}✗${NC} sections/dedication.tex (MISSING)"
    ERRORS=$((ERRORS + 1))
fi

if [ -f sections/acknowledgments-thesis.tex ]; then
    echo -e "    ${GREEN}✓${NC} sections/acknowledgments-thesis.tex"
else
    echo -e "    ${RED}✗${NC} sections/acknowledgments-thesis.tex (MISSING)"
    ERRORS=$((ERRORS + 1))
fi

# Test 15: Check glossaries support
echo -n "15. Checking glossaries support in config... "
if grep -q '\\usepackage\[.*\]{glossaries}' config/thesis-config.tex && \
   grep -q '\\makeglossaries' config/thesis-config.tex; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 16: Check index support
echo -n "16. Checking index support in config... "
if grep -q '\\usepackage{imakeidx}' config/thesis-config.tex && \
   grep -q '\\makeindex' config/thesis-config.tex; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Summary
echo ""
echo "=== VALIDATION SUMMARY ==="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    echo -e "${YELLOW}Note: Actual PDF compilation requires LaTeX installation (pdflatex).${NC}"
    echo -e "${YELLOW}Template is ready for compilation when LaTeX is available.${NC}"
    exit 0
else
    echo -e "${RED}$ERRORS check(s) failed.${NC}"
    exit 1
fi
