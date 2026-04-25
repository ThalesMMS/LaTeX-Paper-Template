#!/bin/bash
# =================================================================
# Validation Script for init-project.sh
# Tests: CLI arguments, validation, help/version, non-interactive mode
# Note: Does not require actual user interaction
# =================================================================

set -e  # Exit on first error

echo "========================================"
echo "INIT-PROJECT.SH VALIDATION"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
TEMP_DIR=""

cleanup_temp_dir() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup_temp_dir EXIT

# Function to check if a file exists
check_file() {
    local file=$1
    local desc=$2
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $desc: $file"
        return 0
    else
        echo -e "${RED}✗${NC} $desc: $file (NOT FOUND)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to check if pattern exists in file
check_pattern() {
    local file=$1
    local pattern=$2
    local desc=$3
    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $desc"
        return 0
    else
        echo -e "${RED}✗${NC} $desc (PATTERN NOT FOUND: $pattern)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to check if fixed text exists in file
check_fixed_pattern() {
    local file=$1
    local pattern=$2
    local desc=$3
    if grep -Fq "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $desc"
        return 0
    else
        echo -e "${RED}✗${NC} $desc (TEXT NOT FOUND: $pattern)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to check if fixed text is absent from file
check_fixed_pattern_absent() {
    local file=$1
    local pattern=$2
    local desc=$3
    if grep -Fq "$pattern" "$file" 2>/dev/null; then
        echo -e "${RED}✗${NC} $desc (UNEXPECTED TEXT FOUND: $pattern)"
        ERRORS=$((ERRORS + 1))
        return 1
    else
        echo -e "${GREEN}✓${NC} $desc"
        return 0
    fi
}

# Function to test command output
test_command() {
    local desc=$1
    shift
    local output
    if output=$("$@" 2>&1); then
        echo -e "${GREEN}✓${NC} $desc"
        return 0
    else
        echo -e "${RED}✗${NC} $desc (COMMAND FAILED)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to test command should fail
test_command_fails() {
    local desc=$1
    shift
    local output
    if output=$("$@" 2>&1); then
        echo -e "${RED}✗${NC} $desc (EXPECTED TO FAIL BUT SUCCEEDED)"
        ERRORS=$((ERRORS + 1))
        return 1
    else
        echo -e "${GREEN}✓${NC} $desc"
        return 0
    fi
}

create_init_project_test_copy() {
    local target_dir=$1

    mkdir -p "$target_dir"
    cp init-project.sh "$target_dir/"
    cp -R config "$target_dir/"
    cp -R chapters "$target_dir/"
}

check_config_metadata_references() {
    local config_file=$1
    local label=$2

    check_fixed_pattern "$config_file" "pdftitle={\\DocumentTitle}" "${label}: PDF title metadata uses DocumentTitle macro"
    check_fixed_pattern "$config_file" "pdfauthor={\\AuthorName}" "${label}: PDF author metadata uses AuthorName macro"

    if grep -F "pdftitle={" "$config_file" | grep -Fvq "pdftitle={\\DocumentTitle}"; then
        echo -e "${RED}✗${NC} ${label}: PDF title metadata should not duplicate a literal value"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✓${NC} ${label}: PDF title metadata has no duplicated literal value"
    fi

    if grep -F "pdfauthor={" "$config_file" | grep -Fvq "pdfauthor={\\AuthorName}"; then
        echo -e "${RED}✗${NC} ${label}: PDF author metadata should not duplicate a literal value"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✓${NC} ${label}: PDF author metadata has no duplicated literal value"
    fi

    local macro_line
    local hypersetup_line
    macro_line=$(grep -nF "\\newcommand{\\DocumentTitle}" "$config_file" | head -n 1 | cut -d: -f1)
    hypersetup_line=$(grep -nF "\\hypersetup{" "$config_file" | head -n 1 | cut -d: -f1)

    if [ -n "$macro_line" ] && [ -n "$hypersetup_line" ] && [ "$macro_line" -lt "$hypersetup_line" ]; then
        echo -e "${GREEN}✓${NC} ${label}: placeholder macros are defined before hypersetup"
    else
        echo -e "${RED}✗${NC} ${label}: placeholder macros must be defined before hypersetup"
        ERRORS=$((ERRORS + 1))
    fi
}

check_initialized_config() {
    local config_file=$1
    local variant=$2
    local project_name=$3
    local author_name=$4
    local institution=$5
    local location=$6
    local email=$7

    check_fixed_pattern "$config_file" "\\newcommand{\\DocumentTitle}{${project_name}}" "${variant}: DocumentTitle macro updated"
    check_fixed_pattern "$config_file" "\\newcommand{\\AuthorName}{${author_name}}" "${variant}: AuthorName macro updated"
    check_fixed_pattern "$config_file" "\\newcommand{\\AuthorInstitution}{${institution}}" "${variant}: AuthorInstitution macro updated"
    check_fixed_pattern "$config_file" "\\newcommand{\\AuthorLocation}{${location}}" "${variant}: AuthorLocation macro updated"
    check_fixed_pattern "$config_file" "\\newcommand{\\AuthorEmail}{${email}}" "${variant}: AuthorEmail macro updated"
    check_config_metadata_references "$config_file" "$variant"
}

echo "=== 1. CHECKING SCRIPT FILE EXISTS ==="
echo ""

# Check init-project.sh exists
check_file "init-project.sh" "init-project.sh script exists"

# Check script is executable or can be run with bash
if [ -x "init-project.sh" ]; then
    echo -e "${GREEN}✓${NC} Script has executable permissions"
elif [ -f "init-project.sh" ]; then
    echo -e "${GREEN}✓${NC} Script can be run with bash command"
else
    echo -e "${RED}✗${NC} Script cannot be executed"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "=== 2. CHECKING SCRIPT STRUCTURE ==="
echo ""

# Check for required functions
check_pattern "init-project.sh" "show_help()" "Script has show_help function"
check_pattern "init-project.sh" "show_version()" "Script has show_version function"
check_pattern "init-project.sh" "parse_arguments()" "Script has parse_arguments function"
check_pattern "init-project.sh" "validate_variant()" "Script has validate_variant function"
check_pattern "init-project.sh" "validate_biblio_backend()" "Script has validate_biblio_backend function"
check_pattern "init-project.sh" "validate_non_interactive_mode()" "Script has validate_non_interactive_mode function"
check_pattern "init-project.sh" "generate_config_file()" "Script has generate_config_file function"
check_pattern "init-project.sh" "configure_bibliography_backend()" "Script has configure_bibliography_backend function"
check_pattern "init-project.sh" "remove_chapters()" "Script has remove_chapters function"
check_pattern "init-project.sh" "main()" "Script has main function"

echo ""
echo "=== 3. TESTING HELP OUTPUT ==="
echo ""

# Test --help flag
if bash init-project.sh --help 2>&1 | grep -q "LaTeX Paper Template - Project Initialization"; then
    echo -e "${GREEN}✓${NC} --help shows title"
else
    echo -e "${RED}✗${NC} --help doesn't show title"
    ERRORS=$((ERRORS + 1))
fi

if bash init-project.sh --help 2>&1 | grep -q "USAGE:"; then
    echo -e "${GREEN}✓${NC} --help shows usage section"
else
    echo -e "${RED}✗${NC} --help doesn't show usage section"
    ERRORS=$((ERRORS + 1))
fi

if bash init-project.sh --help 2>&1 | grep -q "DESCRIPTION:"; then
    echo -e "${GREEN}✓${NC} --help shows description section"
else
    echo -e "${RED}✗${NC} --help doesn't show description section"
    ERRORS=$((ERRORS + 1))
fi

if bash init-project.sh --help 2>&1 | grep -q "OPTIONS:"; then
    echo -e "${GREEN}✓${NC} --help shows options section"
else
    echo -e "${RED}✗${NC} --help doesn't show options section"
    ERRORS=$((ERRORS + 1))
fi

if bash init-project.sh --help 2>&1 | grep -q "EXAMPLES:"; then
    echo -e "${GREEN}✓${NC} --help shows examples section"
else
    echo -e "${RED}✗${NC} --help doesn't show examples section"
    ERRORS=$((ERRORS + 1))
fi

if bash init-project.sh --help 2>&1 | grep -q "\-\-non-interactive"; then
    echo -e "${GREEN}✓${NC} --help documents --non-interactive option"
else
    echo -e "${RED}✗${NC} --help doesn't document --non-interactive option"
    ERRORS=$((ERRORS + 1))
fi

if bash init-project.sh --help 2>&1 | grep -q "\-\-variant"; then
    echo -e "${GREEN}✓${NC} --help documents --variant option"
else
    echo -e "${RED}✗${NC} --help doesn't document --variant option"
    ERRORS=$((ERRORS + 1))
fi

if bash init-project.sh --help 2>&1 | grep -q "\-\-biblio"; then
    echo -e "${GREEN}✓${NC} --help documents --biblio option"
else
    echo -e "${RED}✗${NC} --help doesn't document --biblio option"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "=== 4. TESTING VERSION OUTPUT ==="
echo ""

# Test --version flag
if bash init-project.sh --version 2>&1 | grep -q "Version:"; then
    echo -e "${GREEN}✓${NC} --version shows version information"
else
    echo -e "${RED}✗${NC} --version doesn't show version information"
    ERRORS=$((ERRORS + 1))
fi

if bash init-project.sh --version 2>&1 | grep -q "LaTeX Paper Template"; then
    echo -e "${GREEN}✓${NC} --version shows script name"
else
    echo -e "${RED}✗${NC} --version doesn't show script name"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "=== 5. TESTING INVALID ARGUMENTS ==="
echo ""

# Test invalid option
if bash init-project.sh --invalid-option 2>&1 | grep -q "Error.*Unknown option"; then
    echo -e "${GREEN}✓${NC} Invalid option shows error"
else
    echo -e "${RED}✗${NC} Invalid option doesn't show proper error"
    ERRORS=$((ERRORS + 1))
fi

# Test that invalid option exits with non-zero
if ! bash init-project.sh --invalid-option >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Invalid option exits with error code"
else
    echo -e "${RED}✗${NC} Invalid option doesn't exit with error code"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "=== 6. TESTING NON-INTERACTIVE MODE VALIDATION ==="
echo ""

# Test non-interactive mode without required arguments
if ! bash init-project.sh --non-interactive >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Non-interactive mode fails without arguments"
else
    echo -e "${RED}✗${NC} Non-interactive mode should fail without arguments"
    ERRORS=$((ERRORS + 1))
fi

# Test missing --name
if bash init-project.sh --non-interactive \
    --author "Test" \
    --institution "Test" \
    --location "Test" \
    --email "test@test.com" \
    --variant paper \
    --biblio thebibliography 2>&1 | grep -q "Error.*--name.*required"; then
    echo -e "${GREEN}✓${NC} Missing --name shows error"
else
    echo -e "${RED}✗${NC} Missing --name doesn't show proper error"
    ERRORS=$((ERRORS + 1))
fi

# Test missing --author
if bash init-project.sh --non-interactive \
    --name "Test" \
    --institution "Test" \
    --location "Test" \
    --email "test@test.com" \
    --variant paper \
    --biblio thebibliography 2>&1 | grep -q "Error.*--author.*required"; then
    echo -e "${GREEN}✓${NC} Missing --author shows error"
else
    echo -e "${RED}✗${NC} Missing --author doesn't show proper error"
    ERRORS=$((ERRORS + 1))
fi

# Test missing --variant
if bash init-project.sh --non-interactive \
    --name "Test" \
    --author "Test" \
    --institution "Test" \
    --location "Test" \
    --email "test@test.com" \
    --biblio thebibliography 2>&1 | grep -q "Error.*--variant.*required"; then
    echo -e "${GREEN}✓${NC} Missing --variant shows error"
else
    echo -e "${RED}✗${NC} Missing --variant doesn't show proper error"
    ERRORS=$((ERRORS + 1))
fi

# Test missing --biblio
if bash init-project.sh --non-interactive \
    --name "Test" \
    --author "Test" \
    --institution "Test" \
    --location "Test" \
    --email "test@test.com" \
    --variant paper 2>&1 | grep -q "Error.*--biblio.*required"; then
    echo -e "${GREEN}✓${NC} Missing --biblio shows error"
else
    echo -e "${RED}✗${NC} Missing --biblio doesn't show proper error"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "=== 7. TESTING VARIANT VALIDATION ==="
echo ""

# Test invalid variant
if bash init-project.sh --non-interactive \
    --name "Test" \
    --author "Test" \
    --institution "Test" \
    --location "Test" \
    --email "test@test.com" \
    --variant invalid \
    --biblio thebibliography 2>&1 | grep -q "Error.*Invalid variant"; then
    echo -e "${GREEN}✓${NC} Invalid variant shows error"
else
    echo -e "${RED}✗${NC} Invalid variant doesn't show proper error"
    ERRORS=$((ERRORS + 1))
fi

# Check valid variants are documented in help
if bash init-project.sh --help 2>&1 | grep -q "paper.*monograph.*thesis"; then
    echo -e "${GREEN}✓${NC} Valid variants documented in help"
else
    echo -e "${RED}✗${NC} Valid variants not properly documented"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "=== 8. TESTING BIBLIOGRAPHY BACKEND VALIDATION ==="
echo ""

# Test invalid bibliography backend
if bash init-project.sh --non-interactive \
    --name "Test" \
    --author "Test" \
    --institution "Test" \
    --location "Test" \
    --email "test@test.com" \
    --variant paper \
    --biblio invalid 2>&1 | grep -q "Error.*Invalid bibliography backend"; then
    echo -e "${GREEN}✓${NC} Invalid biblio backend shows error"
else
    echo -e "${RED}✗${NC} Invalid biblio backend doesn't show proper error"
    ERRORS=$((ERRORS + 1))
fi

# Check valid biblio backends are documented
if bash init-project.sh --help 2>&1 | grep -q "thebibliography"; then
    echo -e "${GREEN}✓${NC} thebibliography backend documented"
else
    echo -e "${RED}✗${NC} thebibliography backend not documented"
    ERRORS=$((ERRORS + 1))
fi

if bash init-project.sh --help 2>&1 | grep -q "bibtex"; then
    echo -e "${GREEN}✓${NC} bibtex backend documented"
else
    echo -e "${RED}✗${NC} bibtex backend not documented"
    ERRORS=$((ERRORS + 1))
fi

if bash init-project.sh --help 2>&1 | grep -q "biblatex"; then
    echo -e "${GREEN}✓${NC} biblatex backend documented"
else
    echo -e "${RED}✗${NC} biblatex backend not documented"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "=== 9. CHECKING CHAPTER MAPPING ==="
echo ""

# Check that chapter mapping function exists and has all chapters
for chapter in chapter1 chapter2 chapter3 chapter4 chapter5 chapter6 chapter7 chapter8 chapter9 chapter10; do
    if grep -q "${chapter})" init-project.sh; then
        echo -e "${GREEN}✓${NC} Chapter mapping includes ${chapter}"
    else
        echo -e "${RED}✗${NC} Chapter mapping missing ${chapter}"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "=== 10. CHECKING ERROR HANDLING ==="
echo ""

# Check script uses 'set -e'
check_pattern "init-project.sh" "set -e" "Script uses 'set -e' for error handling"

# Check script validates config file exists before modifying
check_pattern "init-project.sh" "if \[ ! -f.*config_file" "Script checks config file exists"

# Check script has error messages
check_pattern "init-project.sh" "Error:" "Script has error messages"

echo ""
echo "=== 11. CHECKING REQUIRED DEPENDENCIES ==="
echo ""

# Check if config directory exists (required for script to work)
if [ -d "config" ]; then
    echo -e "${GREEN}✓${NC} config/ directory exists"
else
    echo -e "${YELLOW}⚠${NC} config/ directory not found (required for script execution)"
fi

# Check if chapters directory exists (required for chapter removal)
if [ -d "chapters" ]; then
    echo -e "${GREEN}✓${NC} chapters/ directory exists"
else
    echo -e "${YELLOW}⚠${NC} chapters/ directory not found (required for chapter removal)"
fi

echo ""
echo "=== 12. CHECKING CONFIGURATION FEATURES ==="
echo ""

# Check script handles special characters in sed
check_pattern "init-project.sh" "sed 's/\[" "Script escapes special characters for sed"

# Check script creates temporary files safely
check_pattern "init-project.sh" "temp_file" "Script uses temporary files for safe updates"

# Check script cleans up after itself
check_pattern "init-project.sh" "mv.*temp_file" "Script moves temp file to replace original"

echo ""
echo "=== 13. TESTING CONFIG METADATA INITIALIZATION ==="
echo ""

for config_file in config/article-config.tex config/paper-config.tex config/monograph-config.tex config/thesis-config.tex; do
    check_config_metadata_references "$config_file" "$config_file"
done

echo ""

TEMP_DIR=$(mktemp -d)

for variant in paper monograph thesis; do
    test_project_dir="${TEMP_DIR}/${variant}"
    create_init_project_test_copy "$test_project_dir"

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

    if (
        cd "$test_project_dir" && \
        bash init-project.sh --non-interactive \
            --name "$first_title" \
            --author "$first_author" \
            --institution "$first_institution" \
            --location "$first_location" \
            --email "$first_email" \
            --variant "$variant" \
            --biblio thebibliography >/dev/null
    ); then
        echo -e "${GREEN}✓${NC} ${variant}: first non-interactive initialization succeeds"
    else
        echo -e "${RED}✗${NC} ${variant}: first non-interactive initialization failed"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    config_file="${test_project_dir}/config/${variant}-config.tex"
    check_initialized_config "$config_file" "$variant" "$first_title" "$first_author" "$first_institution" "$first_location" "$first_email"

    if (
        cd "$test_project_dir" && \
        bash init-project.sh --non-interactive \
            --name "$second_title" \
            --author "$second_author" \
            --institution "$second_institution" \
            --location "$second_location" \
            --email "$second_email" \
            --variant "$variant" \
            --biblio thebibliography >/dev/null
    ); then
        echo -e "${GREEN}✓${NC} ${variant}: second non-interactive initialization succeeds"
    else
        echo -e "${RED}✗${NC} ${variant}: second non-interactive initialization failed"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    check_initialized_config "$config_file" "$variant" "$second_title" "$second_author" "$second_institution" "$second_location" "$second_email"
    check_fixed_pattern_absent "$config_file" "\\newcommand{\\DocumentTitle}{${first_title}}" "${variant}: rerun removes previous DocumentTitle value"
    check_fixed_pattern_absent "$config_file" "\\newcommand{\\AuthorName}{${first_author}}" "${variant}: rerun removes previous AuthorName value"
    check_fixed_pattern_absent "$config_file" "pdftitle={${second_title}}" "${variant}: PDF title metadata does not duplicate literal title"
    check_fixed_pattern_absent "$config_file" "pdfauthor={${second_author}}" "${variant}: PDF author metadata does not duplicate literal author"
done

echo ""
echo "========================================"
echo "VALIDATION SUMMARY"
echo "========================================"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ ALL CHECKS PASSED${NC}"
    echo ""
    echo "init-project.sh is properly configured and validated."
    echo ""
    echo "Key Features Validated:"
    echo "  - Help and version outputs"
    echo "  - Non-interactive mode with all required arguments"
    echo "  - Variant validation (paper, monograph, thesis)"
    echo "  - Bibliography backend validation (thebibliography, bibtex, biblatex)"
    echo "  - Error handling and input validation"
    echo "  - Chapter removal functionality"
    echo "  - Configuration file generation"
    echo "  - Config metadata initialization and rerun behavior"
    echo ""
    echo "Usage:"
    echo "  Interactive:     bash init-project.sh"
    echo "  Non-interactive: bash init-project.sh --non-interactive [OPTIONS]"
    echo "  Help:            bash init-project.sh --help"
    echo ""
    exit 0
else
    echo -e "${RED}✗ VALIDATION FAILED${NC}"
    echo ""
    echo -e "${RED}Found $ERRORS error(s) during validation${NC}"
    echo ""
    echo "Please review the errors above and fix init-project.sh"
    echo ""
    exit 1
fi
