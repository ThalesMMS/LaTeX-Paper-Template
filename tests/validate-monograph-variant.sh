#!/bin/bash
# =================================================================
# Validation Script for Monograph Variant
# Validates monograph-main.tex structure and readiness for compilation
# =================================================================

set -e

echo "=== MONOGRAPH VARIANT VALIDATION ==="
echo ""

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Function to check validation
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1"
        ERRORS=$((ERRORS + 1))
    fi
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

# 1. Check file existence
echo "1. Checking file existence..."
[ -f monograph-main.tex ] && check "monograph-main.tex exists" || check "monograph-main.tex exists"
[ -f config/monograph-config.tex ] && check "config/monograph-config.tex exists" || check "config/monograph-config.tex exists"

# 2. Validate LaTeX syntax (basic checks)
echo ""
echo "2. Validating LaTeX syntax..."

# Check for balanced braces (simple check)
grep -q '\\documentclass.*{report}' monograph-main.tex && check "Uses report documentclass" || check "Uses report documentclass"

grep -q '\\begin{document}' monograph-main.tex && check "Has \\begin{document}" || check "Has \\begin{document}"
grep -q '\\end{document}' monograph-main.tex && check "Has \\end{document}" || check "Has \\end{document}"

# 3. Validate document structure
echo ""
echo "3. Validating monograph structure..."
grep -q '\\tableofcontents' monograph-main.tex && check "Has table of contents (required for monographs)" || check "Has table of contents"
grep -q '\\input{config/monograph-config}' monograph-main.tex && check "Includes monograph-config.tex" || check "Includes monograph-config.tex"
grep -q '\\maketitle' monograph-main.tex && check "Has \\maketitle command" || check "Has \\maketitle command"

# 4. Check metadata commands in config
echo ""
echo "4. Checking metadata commands..."
grep -q '\\DocumentTitle' config/monograph-config.tex && check "DocumentTitle command defined" || check "DocumentTitle command defined"
grep -q '\\AuthorName' config/monograph-config.tex && check "AuthorName command defined" || check "AuthorName command defined"
grep -q '\\AuthorInstitution' config/monograph-config.tex && check "AuthorInstitution command defined" || check "AuthorInstitution command defined"
grep -q '\\AuthorEmail' config/monograph-config.tex && check "AuthorEmail command defined" || check "AuthorEmail command defined"
grep -q '\\AdvisorName' config/monograph-config.tex && check "AdvisorName command defined (monograph-specific)" || check "AdvisorName command defined"
grep -q '\\AdvisorTitle' config/monograph-config.tex && check "AdvisorTitle command defined (monograph-specific)" || check "AdvisorTitle command defined"

# 5. Check essential packages
echo ""
echo "5. Checking essential packages..."
grep -q 'usepackage{graphicx' config/monograph-config.tex && check "graphicx package" || check "graphicx package"
grep -q 'usepackage{hyperref' config/monograph-config.tex && check "hyperref package" || check "hyperref package"
grep -q 'usepackage{listings' config/monograph-config.tex && check "listings package" || check "listings package"
grep -q 'usepackage{amsmath' config/monograph-config.tex && check "amsmath package" || check "amsmath package"
grep -q 'usepackage{booktabs' config/monograph-config.tex && check "booktabs package" || check "booktabs package"
grep -q 'usepackage{tocloft' config/monograph-config.tex && check "tocloft package (monograph-specific)" || check "tocloft package"

# 6. Check monograph-specific features
echo ""
echo "6. Checking monograph-specific features..."
grep -q 'bookmarks=true' config/monograph-config.tex && check "PDF bookmarks enabled" || check "PDF bookmarks enabled"
grep -q 'bookmarksopen=true' config/monograph-config.tex && check "PDF bookmarks open by default" || check "PDF bookmarks open by default"

# 7. Verify all referenced files exist
echo ""
echo "7. Verifying all referenced files..."
[ -f config/sbc-template.sty ] && check "config/sbc-template.sty exists" || check "config/sbc-template.sty exists"
[ -f sections/abstract.tex ] && check "sections/abstract.tex exists" || check "sections/abstract.tex exists"
[ -f sections/resumo.tex ] && check "sections/resumo.tex exists" || check "sections/resumo.tex exists"

# 8. Check all chapter includes
echo ""
echo "8. Checking chapter includes..."
CHAPTERS=(
    "chapters/01-introducao.tex"
    "chapters/02-trabalhos-relacionados.tex"
    "chapters/03-metodologia.tex"
    "chapters/04-avaliacao-resultados.tex"
    "chapters/05-detalhes-implementacao.tex"
    "chapters/06-desafios-tecnicos.tex"
    "chapters/07-trabalhos-futuros.tex"
    "chapters/08-conclusoes-e-contribuicoes.tex"
)

for chapter in "${CHAPTERS[@]}"; do
    [ -f "$chapter" ] && check "$chapter exists" || check "$chapter exists"
done

# 9. Check bibliography file
echo ""
echo "9. Checking bibliography..."
[ -f bibliography/references.tex ] && check "bibliography/references.tex exists" || check "bibliography/references.tex exists"
grep -q '\\input{bibliography/references}' monograph-main.tex && check "Bibliography included in main file" || check "Bibliography included in main file"

# 10. Structure summary
echo ""
echo "10. Document structure summary..."
CHAPTER_COUNT=$(grep -c '\\input{chapters/' monograph-main.tex || echo "0")
echo "   Chapters included: $CHAPTER_COUNT"
if [ "$CHAPTER_COUNT" -eq 8 ]; then
    check "Full monograph chapter structure (8 chapters)"
else
    warn "Expected 8 chapters, found $CHAPTER_COUNT"
fi

# Final summary
echo ""
echo "=== VALIDATION SUMMARY ==="
echo -e "Errors: $ERRORS"
echo -e "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Monograph variant is ready for compilation!${NC}"
    echo ""
    echo "Note: Actual PDF compilation requires LaTeX installation (pdflatex)."
    echo "When LaTeX is available, compile with:"
    echo "  MAIN_FILE=monograph-main make compile"
    echo ""
    echo "Or use the dedicated target (once Makefile is updated):"
    echo "  make monograph"
    exit 0
else
    echo -e "${RED}✗ Monograph variant has validation errors.${NC}"
    echo "Please fix the errors above before attempting compilation."
    exit 1
fi
