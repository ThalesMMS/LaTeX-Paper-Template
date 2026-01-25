#!/bin/bash
# =================================================================
# LaTeX Paper Template - Project Initialization Script
# Interactive CLI tool for creating a customized project from template
# Supports: project name, author info, bibliography backend, variant selection
# =================================================================

set -e  # Exit on first error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script version
VERSION="1.0.0"

# Trap to handle cleanup on error
cleanup_on_error() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo ""
        echo -e "${RED}Script terminated with errors (exit code: $exit_code)${NC}" >&2

        # Clean up any temporary files
        find config/ -name "*.tmp" -type f -delete 2>/dev/null || true
        find config/ -name "*.bak" -type f -delete 2>/dev/null || true
    fi
}

trap cleanup_on_error EXIT

# Default values
NON_INTERACTIVE=false
PROJECT_NAME=""
AUTHOR_NAME=""
INSTITUTION=""
LOCATION=""
EMAIL=""
VARIANT=""
BIBLIO_BACKEND=""
REMOVE_CHAPTERS=""

# =================================================================
# HELP FUNCTION
# =================================================================

show_help() {
    cat << EOF
${BLUE}LaTeX Paper Template - Project Initialization${NC}
${BLUE}Version: ${VERSION}${NC}

${GREEN}USAGE:${NC}
    bash init-project.sh [OPTIONS]

${GREEN}DESCRIPTION:${NC}
    Interactive command-line tool that creates a new project from template
    with customizable options: project name, author, bibliography backend,
    and chapter structure.

${GREEN}MODES:${NC}
    ${YELLOW}Interactive Mode (default):${NC}
        bash init-project.sh

        Prompts you for all required information step-by-step.

    ${YELLOW}Non-Interactive Mode:${NC}
        bash init-project.sh --non-interactive [OPTIONS]

        Accepts all configuration via command-line arguments.
        All required options must be provided.

${GREEN}OPTIONS:${NC}
    --help                      Show this help message and exit
    --version                   Show version information and exit

    ${YELLOW}Non-Interactive Mode Options:${NC}
    --non-interactive           Run in non-interactive mode (requires all options below)
    --name NAME                 Project name/title
    --author AUTHOR             Author name
    --institution INSTITUTION   Institution/university name
    --location LOCATION         City -- State -- Country
    --email EMAIL              Contact email address
    --variant VARIANT          Document variant: paper, monograph, or thesis
    --biblio BACKEND           Bibliography backend: thebibliography, bibtex, or biblatex
    --remove-chapters CHAPTERS  Comma-separated list of chapters to remove (optional)

${GREEN}EXAMPLES:${NC}
    ${YELLOW}# Interactive mode${NC}
    bash init-project.sh

    ${YELLOW}# Non-interactive mode - minimal${NC}
    bash init-project.sh --non-interactive \\
        --name "My Research Paper" \\
        --author "John Doe" \\
        --institution "Example University" \\
        --location "Boston -- MA -- USA" \\
        --email "john.doe@example.com" \\
        --variant paper \\
        --biblio thebibliography

    ${YELLOW}# Non-interactive mode - with chapter removal${NC}
    bash init-project.sh --non-interactive \\
        --name "My Thesis" \\
        --author "Jane Smith" \\
        --institution "Research Institute" \\
        --location "New York -- NY -- USA" \\
        --email "jane@example.com" \\
        --variant thesis \\
        --biblio biblatex \\
        --remove-chapters "chapter2,chapter4"

${GREEN}VALID VALUES:${NC}
    ${YELLOW}Variant:${NC}
        paper       - Short article format (streamlined structure)
        monograph   - Extended report with table of contents
        thesis      - Full thesis with front matter (dedication, acknowledgments)

    ${YELLOW}Bibliography Backend:${NC}
        thebibliography - Manual bibliography environment (default)
        bibtex          - BibTeX with .bib file
        biblatex        - BibLaTeX with biber backend

${GREEN}NOTES:${NC}
    - This script customizes the LaTeX template by updating config files
      and setting appropriate options for your selected variant
    - In interactive mode, you'll be prompted for each option with examples
    - The script will validate your inputs and provide helpful error messages
    - Generated config files will be placed in the config/ directory

For more information, see README.md

EOF
}

show_version() {
    echo "LaTeX Paper Template - Project Initialization Script"
    echo "Version: ${VERSION}"
}

# =================================================================
# ARGUMENT PARSING
# =================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            --non-interactive)
                NON_INTERACTIVE=true
                shift
                ;;
            --name)
                if [ -z "$2" ] || [[ "$2" == --* ]]; then
                    echo -e "${RED}Error: --name requires a value${NC}" >&2
                    echo "Use --help for usage information" >&2
                    exit 1
                fi
                PROJECT_NAME="$2"
                shift 2
                ;;
            --author)
                if [ -z "$2" ] || [[ "$2" == --* ]]; then
                    echo -e "${RED}Error: --author requires a value${NC}" >&2
                    echo "Use --help for usage information" >&2
                    exit 1
                fi
                AUTHOR_NAME="$2"
                shift 2
                ;;
            --institution)
                if [ -z "$2" ] || [[ "$2" == --* ]]; then
                    echo -e "${RED}Error: --institution requires a value${NC}" >&2
                    echo "Use --help for usage information" >&2
                    exit 1
                fi
                INSTITUTION="$2"
                shift 2
                ;;
            --location)
                if [ -z "$2" ] || [[ "$2" == --* ]]; then
                    echo -e "${RED}Error: --location requires a value${NC}" >&2
                    echo "Use --help for usage information" >&2
                    exit 1
                fi
                LOCATION="$2"
                shift 2
                ;;
            --email)
                if [ -z "$2" ] || [[ "$2" == --* ]]; then
                    echo -e "${RED}Error: --email requires a value${NC}" >&2
                    echo "Use --help for usage information" >&2
                    exit 1
                fi
                EMAIL="$2"
                shift 2
                ;;
            --variant)
                if [ -z "$2" ] || [[ "$2" == --* ]]; then
                    echo -e "${RED}Error: --variant requires a value${NC}" >&2
                    echo "Use --help for usage information" >&2
                    exit 1
                fi
                VARIANT="$2"
                shift 2
                ;;
            --biblio)
                if [ -z "$2" ] || [[ "$2" == --* ]]; then
                    echo -e "${RED}Error: --biblio requires a value${NC}" >&2
                    echo "Use --help for usage information" >&2
                    exit 1
                fi
                BIBLIO_BACKEND="$2"
                shift 2
                ;;
            --remove-chapters)
                if [ -z "$2" ] || [[ "$2" == --* ]]; then
                    echo -e "${RED}Error: --remove-chapters requires a value${NC}" >&2
                    echo "Use --help for usage information" >&2
                    exit 1
                fi
                REMOVE_CHAPTERS="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}Error: Unknown option: $1${NC}" >&2
                echo "Use --help for usage information" >&2
                exit 1
                ;;
        esac
    done
}

# =================================================================
# VALIDATION FUNCTIONS
# =================================================================

# Pre-flight check for required files and directories
check_prerequisites() {
    local errors=0

    # Check for config directory
    if [ ! -d "config" ]; then
        echo -e "${RED}Error: config/ directory not found${NC}" >&2
        echo -e "${YELLOW}Are you running this script from the project root?${NC}" >&2
        errors=$((errors + 1))
    fi

    # Check for chapters directory
    if [ ! -d "chapters" ]; then
        echo -e "${RED}Error: chapters/ directory not found${NC}" >&2
        echo -e "${YELLOW}Are you running this script from the project root?${NC}" >&2
        errors=$((errors + 1))
    fi

    # Check for variant config template files
    local variants=("paper" "monograph" "thesis")
    for variant in "${variants[@]}"; do
        local config_file="config/${variant}-config.tex"
        if [ ! -f "$config_file" ]; then
            echo -e "${RED}Error: Required config template not found: ${config_file}${NC}" >&2
            errors=$((errors + 1))
        fi
    done

    if [ $errors -gt 0 ]; then
        echo ""
        echo -e "${RED}Pre-flight checks failed. Cannot proceed.${NC}" >&2
        exit 1
    fi
}

validate_email() {
    local email="$1"
    # Basic email validation: contains @ and has characters before and after
    if [[ "$email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
        return 0
    else
        echo -e "${RED}Error: Invalid email format: '$email'${NC}" >&2
        echo -e "${YELLOW}Expected format: user@domain.com${NC}" >&2
        return 1
    fi
}

validate_chapter_identifiers() {
    local chapters="$1"
    local errors=0

    # If empty, it's valid (no chapters to remove)
    if [ -z "$chapters" ]; then
        return 0
    fi

    # Split comma-separated list
    IFS=',' read -ra CHAPTER_LIST <<< "$chapters"

    for chapter in "${CHAPTER_LIST[@]}"; do
        # Trim whitespace
        chapter=$(echo "$chapter" | xargs)

        # Validate chapter identifier
        case "$chapter" in
            chapter1|chapter2|chapter3|chapter4|chapter5|chapter6|chapter7|chapter8|chapter9|chapter10)
                # Valid
                ;;
            *)
                echo -e "${RED}Error: Invalid chapter identifier: '$chapter'${NC}" >&2
                echo -e "${YELLOW}Valid identifiers: chapter1 through chapter10${NC}" >&2
                errors=$((errors + 1))
                ;;
        esac
    done

    if [ $errors -gt 0 ]; then
        return 1
    fi

    return 0
}

validate_non_interactive_mode() {
    local errors=0

    if [ -z "$PROJECT_NAME" ]; then
        echo -e "${RED}Error: --name is required in non-interactive mode${NC}" >&2
        errors=$((errors + 1))
    fi

    if [ -z "$AUTHOR_NAME" ]; then
        echo -e "${RED}Error: --author is required in non-interactive mode${NC}" >&2
        errors=$((errors + 1))
    fi

    if [ -z "$INSTITUTION" ]; then
        echo -e "${RED}Error: --institution is required in non-interactive mode${NC}" >&2
        errors=$((errors + 1))
    fi

    if [ -z "$LOCATION" ]; then
        echo -e "${RED}Error: --location is required in non-interactive mode${NC}" >&2
        errors=$((errors + 1))
    fi

    if [ -z "$EMAIL" ]; then
        echo -e "${RED}Error: --email is required in non-interactive mode${NC}" >&2
        errors=$((errors + 1))
    fi

    if [ -z "$VARIANT" ]; then
        echo -e "${RED}Error: --variant is required in non-interactive mode${NC}" >&2
        errors=$((errors + 1))
    fi

    if [ -z "$BIBLIO_BACKEND" ]; then
        echo -e "${RED}Error: --biblio is required in non-interactive mode${NC}" >&2
        errors=$((errors + 1))
    fi

    if [ $errors -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Use --help for usage information${NC}" >&2
        exit 1
    fi
}

validate_variant() {
    case "$VARIANT" in
        paper|monograph|thesis)
            return 0
            ;;
        *)
            echo -e "${RED}Error: Invalid variant '$VARIANT'${NC}" >&2
            echo -e "${YELLOW}Valid options: paper, monograph, thesis${NC}" >&2
            return 1
            ;;
    esac
}

validate_biblio_backend() {
    case "$BIBLIO_BACKEND" in
        thebibliography|bibtex|biblatex)
            return 0
            ;;
        *)
            echo -e "${RED}Error: Invalid bibliography backend '$BIBLIO_BACKEND'${NC}" >&2
            echo -e "${YELLOW}Valid options: thebibliography, bibtex, biblatex${NC}" >&2
            return 1
            ;;
    esac
}

# =================================================================
# INTERACTIVE PROMPT FUNCTIONS
# =================================================================

prompt_project_name() {
    echo -e "${BLUE}=== Project Configuration ===${NC}"
    echo ""
    echo -e "${YELLOW}Enter your project name/title${NC}"
    echo -e "${YELLOW}Example: My Research Paper on Quantum Computing${NC}"
    echo ""
    read -p "Project Name: " PROJECT_NAME

    # Validate non-empty
    while [ -z "$PROJECT_NAME" ]; do
        echo -e "${RED}Error: Project name cannot be empty${NC}"
        read -p "Project Name: " PROJECT_NAME
    done

    echo -e "${GREEN}✓${NC} Project name set to: $PROJECT_NAME"
    echo ""
}

prompt_author_info() {
    echo -e "${BLUE}=== Author Information ===${NC}"
    echo ""

    # Author name
    echo -e "${YELLOW}Enter your full name${NC}"
    echo -e "${YELLOW}Example: John Doe${NC}"
    echo ""
    read -p "Author Name: " AUTHOR_NAME

    while [ -z "$AUTHOR_NAME" ]; do
        echo -e "${RED}Error: Author name cannot be empty${NC}"
        read -p "Author Name: " AUTHOR_NAME
    done

    echo -e "${GREEN}✓${NC} Author name set to: $AUTHOR_NAME"
    echo ""

    # Institution
    echo -e "${YELLOW}Enter your institution/university${NC}"
    echo -e "${YELLOW}Example: Massachusetts Institute of Technology${NC}"
    echo ""
    read -p "Institution: " INSTITUTION

    while [ -z "$INSTITUTION" ]; do
        echo -e "${RED}Error: Institution cannot be empty${NC}"
        read -p "Institution: " INSTITUTION
    done

    echo -e "${GREEN}✓${NC} Institution set to: $INSTITUTION"
    echo ""

    # Location
    echo -e "${YELLOW}Enter location (City -- State -- Country format)${NC}"
    echo -e "${YELLOW}Example: Boston -- MA -- USA${NC}"
    echo ""
    read -p "Location: " LOCATION

    while [ -z "$LOCATION" ]; do
        echo -e "${RED}Error: Location cannot be empty${NC}"
        read -p "Location: " LOCATION
    done

    echo -e "${GREEN}✓${NC} Location set to: $LOCATION"
    echo ""

    # Email
    echo -e "${YELLOW}Enter your email address${NC}"
    echo -e "${YELLOW}Example: john.doe@mit.edu${NC}"
    echo ""
    read -p "Email: " EMAIL

    while [ -z "$EMAIL" ] || ! validate_email "$EMAIL"; do
        if [ -z "$EMAIL" ]; then
            echo -e "${RED}Error: Email cannot be empty${NC}"
        fi
        read -p "Email: " EMAIL
    done

    echo -e "${GREEN}✓${NC} Email set to: $EMAIL"
    echo ""
}

prompt_variant() {
    echo -e "${BLUE}=== Document Variant Selection ===${NC}"
    echo ""
    echo -e "${YELLOW}Select your document variant:${NC}"
    echo ""
    echo "  1) paper       - Short article format (streamlined structure)"
    echo "  2) monograph   - Extended report with table of contents"
    echo "  3) thesis      - Full thesis with front matter (dedication, acknowledgments)"
    echo ""

    local valid=false
    while [ "$valid" = false ]; do
        read -p "Select variant (1-3): " variant_choice

        case "$variant_choice" in
            1)
                VARIANT="paper"
                valid=true
                ;;
            2)
                VARIANT="monograph"
                valid=true
                ;;
            3)
                VARIANT="thesis"
                valid=true
                ;;
            paper|monograph|thesis)
                VARIANT="$variant_choice"
                valid=true
                ;;
            *)
                echo -e "${RED}Error: Invalid selection. Please enter 1, 2, or 3${NC}"
                ;;
        esac
    done

    echo -e "${GREEN}✓${NC} Variant set to: $VARIANT"
    echo ""
}

prompt_biblio_backend() {
    echo -e "${BLUE}=== Bibliography Backend Selection ===${NC}"
    echo ""
    echo -e "${YELLOW}Select your bibliography backend:${NC}"
    echo ""
    echo "  1) thebibliography - Manual bibliography environment (simple, no external files)"
    echo "  2) bibtex          - BibTeX with .bib file (traditional)"
    echo "  3) biblatex        - BibLaTeX with biber backend (modern, recommended)"
    echo ""

    local valid=false
    while [ "$valid" = false ]; do
        read -p "Select bibliography backend (1-3): " biblio_choice

        case "$biblio_choice" in
            1)
                BIBLIO_BACKEND="thebibliography"
                valid=true
                ;;
            2)
                BIBLIO_BACKEND="bibtex"
                valid=true
                ;;
            3)
                BIBLIO_BACKEND="biblatex"
                valid=true
                ;;
            thebibliography|bibtex|biblatex)
                BIBLIO_BACKEND="$biblio_choice"
                valid=true
                ;;
            *)
                echo -e "${RED}Error: Invalid selection. Please enter 1, 2, or 3${NC}"
                ;;
        esac
    done

    echo -e "${GREEN}✓${NC} Bibliography backend set to: $BIBLIO_BACKEND"
    echo ""
}

prompt_remove_chapters() {
    echo -e "${BLUE}=== Optional: Remove Chapters ===${NC}"
    echo ""
    echo -e "${YELLOW}Would you like to remove any default chapters?${NC}"
    echo -e "${YELLOW}Available chapters:${NC}"
    echo "  chapter1  - 01-introducao.tex"
    echo "  chapter2  - 02-trabalhos-relacionados.tex"
    echo "  chapter3  - 03-metodologia.tex"
    echo "  chapter4  - 04-avaliacao-resultados.tex"
    echo "  chapter5  - 05-detalhes-implementacao.tex"
    echo "  chapter6  - 06-desafios-tecnicos.tex"
    echo "  chapter7  - 07-trabalhos-futuros.tex"
    echo "  chapter8  - 08-conclusoes-e-contribuicoes.tex"
    echo "  chapter9  - 09-apendices.tex"
    echo "  chapter10 - 10-cronograma.tex"
    echo ""
    echo -e "${YELLOW}Enter comma-separated list (e.g., chapter2,chapter4,chapter9) or press Enter to keep all${NC}"
    echo ""
    read -p "Chapters to remove (optional): " REMOVE_CHAPTERS

    if [ -n "$REMOVE_CHAPTERS" ]; then
        echo -e "${GREEN}✓${NC} Will remove chapters: $REMOVE_CHAPTERS"
    else
        echo -e "${GREEN}✓${NC} Keeping all chapters"
    fi
    echo ""
}

run_interactive_prompts() {
    echo -e "${GREEN}Starting interactive configuration...${NC}"
    echo ""

    prompt_project_name
    prompt_author_info
    prompt_variant
    prompt_biblio_backend
    prompt_remove_chapters

    echo -e "${BLUE}========================================"
    echo "Configuration Summary"
    echo -e "========================================${NC}"
    echo ""
    echo "Project Name:         $PROJECT_NAME"
    echo "Author:               $AUTHOR_NAME"
    echo "Institution:          $INSTITUTION"
    echo "Location:             $LOCATION"
    echo "Email:                $EMAIL"
    echo "Variant:              $VARIANT"
    echo "Bibliography Backend: $BIBLIO_BACKEND"
    if [ -n "$REMOVE_CHAPTERS" ]; then
        echo "Remove Chapters:      $REMOVE_CHAPTERS"
    fi
    echo ""
}

# =================================================================
# CONFIG FILE GENERATION
# =================================================================

generate_config_file() {
    local variant="$1"
    local config_file="config/${variant}-config.tex"

    echo -e "${BLUE}Generating configuration file: ${config_file}${NC}"

    # Check if config file exists
    if [ ! -f "$config_file" ]; then
        echo -e "${RED}Error: Config template not found: ${config_file}${NC}" >&2
        exit 1
    fi

    # Verify config file is readable
    if [ ! -r "$config_file" ]; then
        echo -e "${RED}Error: Config template is not readable: ${config_file}${NC}" >&2
        exit 1
    fi

    # Create a temporary file for processing
    local temp_file="${config_file}.tmp"

    # Escape special characters for sed (forward slashes, backslashes, etc.)
    local escaped_project_name=$(echo "$PROJECT_NAME" | sed 's/[\/&]/\\&/g')
    local escaped_author_name=$(echo "$AUTHOR_NAME" | sed 's/[\/&]/\\&/g')
    local escaped_institution=$(echo "$INSTITUTION" | sed 's/[\/&]/\\&/g')
    local escaped_location=$(echo "$LOCATION" | sed 's/[\/&]/\\&/g')
    local escaped_email=$(echo "$EMAIL" | sed 's/[\/&]/\\&/g')

    # Replace the newcommand definitions based on variant-specific placeholders
    # Each variant has different placeholder values, so we need variant-specific replacements
    case "$variant" in
        paper)
            sed -e "s|\\\\newcommand{\\\\DocumentTitle}{Test Project}|\\\\newcommand{\\\\DocumentTitle}{${escaped_project_name}}|g" \
                -e "s|\\\\newcommand{\\\\AuthorName}{Test Author}|\\\\newcommand{\\\\AuthorName}{${escaped_author_name}}|g" \
                -e "s|\\\\newcommand{\\\\AuthorInstitution}{Test Uni}|\\\\newcommand{\\\\AuthorInstitution}{${escaped_institution}}|g" \
                -e "s|\\\\newcommand{\\\\AuthorLocation}{Test City}|\\\\newcommand{\\\\AuthorLocation}{${escaped_location}}|g" \
                -e "s|\\\\newcommand{\\\\AuthorEmail}{test@example\\.com}|\\\\newcommand{\\\\AuthorEmail}{${escaped_email}}|g" \
                "$config_file" > "$temp_file"
            ;;
        monograph)
            sed -e "s|\\\\newcommand{\\\\DocumentTitle}{My Monograph}|\\\\newcommand{\\\\DocumentTitle}{${escaped_project_name}}|g" \
                -e "s|\\\\newcommand{\\\\AuthorName}{Jane Doe}|\\\\newcommand{\\\\AuthorName}{${escaped_author_name}}|g" \
                -e "s|\\\\newcommand{\\\\AuthorInstitution}{Research Institute}|\\\\newcommand{\\\\AuthorInstitution}{${escaped_institution}}|g" \
                -e "s|\\\\newcommand{\\\\AuthorLocation}{New York -- NY -- USA}|\\\\newcommand{\\\\AuthorLocation}{${escaped_location}}|g" \
                -e "s|\\\\newcommand{\\\\AuthorEmail}{jane@example\\.com}|\\\\newcommand{\\\\AuthorEmail}{${escaped_email}}|g" \
                "$config_file" > "$temp_file"
            ;;
        thesis)
            sed -e "s|\\\\newcommand{\\\\DocumentTitle}{PhD Thesis}|\\\\newcommand{\\\\DocumentTitle}{${escaped_project_name}}|g" \
                -e "s|\\\\newcommand{\\\\AuthorName}{John Smith}|\\\\newcommand{\\\\AuthorName}{${escaped_author_name}}|g" \
                -e "s|\\\\newcommand{\\\\AuthorInstitution}{University Department}|\\\\newcommand{\\\\AuthorInstitution}{${escaped_institution}}|g" \
                -e "s|\\\\newcommand{\\\\AuthorLocation}{Boston -- MA -- USA}|\\\\newcommand{\\\\AuthorLocation}{${escaped_location}}|g" \
                -e "s|\\\\newcommand{\\\\AuthorEmail}{john@example\\.com}|\\\\newcommand{\\\\AuthorEmail}{${escaped_email}}|g" \
                "$config_file" > "$temp_file"
            ;;
        *)
            echo -e "${RED}Error: Unknown variant '$variant'${NC}" >&2
            exit 1
            ;;
    esac

    # Verify the sed command succeeded and temp file was created
    if [ ! -f "$temp_file" ]; then
        echo -e "${RED}Error: Failed to create temporary config file${NC}" >&2
        exit 1
    fi

    # Verify temp file is not empty
    if [ ! -s "$temp_file" ]; then
        echo -e "${RED}Error: Generated config file is empty${NC}" >&2
        rm -f "$temp_file"
        exit 1
    fi

    # Replace original file with updated content
    if ! mv "$temp_file" "$config_file"; then
        echo -e "${RED}Error: Failed to update config file${NC}" >&2
        rm -f "$temp_file"
        exit 1
    fi

    echo -e "${GREEN}✓${NC} Configuration file generated successfully"
    echo ""
}

configure_bibliography_backend() {
    local variant="$1"
    local biblio_backend="$2"
    local config_file="config/${variant}-config.tex"

    echo -e "${BLUE}Configuring bibliography backend: ${biblio_backend}${NC}"

    # Check if config file exists
    if [ ! -f "$config_file" ]; then
        echo -e "${RED}Error: Config file not found: ${config_file}${NC}" >&2
        exit 1
    fi

    # Verify config file is writable
    if [ ! -w "$config_file" ]; then
        echo -e "${RED}Error: Config file is not writable: ${config_file}${NC}" >&2
        exit 1
    fi

    # Only process if biblatex is selected
    if [ "$biblio_backend" = "biblatex" ]; then
        # Uncomment BibLaTeX package lines
        # The pattern matches lines that start with "% \usepackage" and contain "biblatex"
        # or lines that start with "% \addbibresource"
        if ! sed -i.bak \
            -e 's|^% \\usepackage\[backend=biber|\\usepackage[backend=biber|' \
            -e 's|^% \\addbibresource{|\\addbibresource{|' \
            "$config_file"; then
            echo -e "${RED}Error: Failed to configure BibLaTeX in config file${NC}" >&2
            # Restore from backup if it exists
            if [ -f "${config_file}.bak" ]; then
                mv "${config_file}.bak" "$config_file"
            fi
            exit 1
        fi

        # Remove backup file
        rm -f "${config_file}.bak"

        echo -e "${GREEN}✓${NC} BibLaTeX configuration enabled"
    else
        echo -e "${GREEN}✓${NC} Using default bibliography backend (${biblio_backend})"
    fi

    echo ""
}

get_chapter_filename() {
    local chapter="$1"

    case "$chapter" in
        chapter1)
            echo "01-introducao.tex"
            ;;
        chapter2)
            echo "02-trabalhos-relacionados.tex"
            ;;
        chapter3)
            echo "03-metodologia.tex"
            ;;
        chapter4)
            echo "04-avaliacao-resultados.tex"
            ;;
        chapter5)
            echo "05-detalhes-implementacao.tex"
            ;;
        chapter6)
            echo "06-desafios-tecnicos.tex"
            ;;
        chapter7)
            echo "07-trabalhos-futuros.tex"
            ;;
        chapter8)
            echo "08-conclusoes-e-contribuicoes.tex"
            ;;
        chapter9)
            echo "09-apendices.tex"
            ;;
        chapter10)
            echo "10-cronograma.tex"
            ;;
        *)
            echo ""
            ;;
    esac
}

remove_chapters() {
    local chapters_to_remove="$1"

    # If no chapters specified, skip
    if [ -z "$chapters_to_remove" ]; then
        return 0
    fi

    echo -e "${BLUE}Removing specified chapters...${NC}"

    # Check if chapters directory exists
    if [ ! -d "chapters" ]; then
        echo -e "${RED}Error: chapters/ directory not found${NC}" >&2
        return 1
    fi

    # Split comma-separated list and process each chapter
    IFS=',' read -ra CHAPTERS <<< "$chapters_to_remove"

    local removed_count=0
    local failed_count=0

    for chapter in "${CHAPTERS[@]}"; do
        # Trim whitespace
        chapter=$(echo "$chapter" | xargs)

        # Skip empty entries (e.g., from trailing commas)
        if [ -z "$chapter" ]; then
            continue
        fi

        # Get the filename for this chapter
        local filename=$(get_chapter_filename "$chapter")

        if [ -z "$filename" ]; then
            echo -e "${YELLOW}Warning: Unknown chapter identifier '$chapter' - skipping${NC}" >&2
            failed_count=$((failed_count + 1))
            continue
        fi

        local filepath="chapters/$filename"

        if [ -f "$filepath" ]; then
            if ! rm "$filepath"; then
                echo -e "${RED}Error: Failed to remove: $filepath${NC}" >&2
                failed_count=$((failed_count + 1))
            else
                echo -e "${GREEN}✓${NC} Removed: $filepath"
                removed_count=$((removed_count + 1))
            fi
        else
            echo -e "${YELLOW}Warning: File not found: $filepath - skipping${NC}" >&2
            failed_count=$((failed_count + 1))
        fi
    done

    echo ""

    if [ $removed_count -gt 0 ]; then
        echo -e "${GREEN}Successfully removed $removed_count chapter(s)${NC}"
    fi

    if [ $failed_count -gt 0 ]; then
        echo -e "${YELLOW}Skipped $failed_count item(s) due to warnings${NC}" >&2
    fi

    echo ""
}

# =================================================================
# MAIN FUNCTION
# =================================================================

main() {
    echo ""
    echo -e "${BLUE}========================================"
    echo "LaTeX Paper Template - Initialization"
    echo -e "========================================${NC}"
    echo ""

    # Parse command-line arguments
    parse_arguments "$@"

    # Run pre-flight checks
    check_prerequisites

    # Validate non-interactive mode requirements
    if [ "$NON_INTERACTIVE" = true ]; then
        validate_non_interactive_mode

        # Validate variant
        if ! validate_variant; then
            exit 1
        fi

        # Validate bibliography backend
        if ! validate_biblio_backend; then
            exit 1
        fi

        # Validate email format
        if ! validate_email "$EMAIL"; then
            exit 1
        fi

        # Validate chapter identifiers (if provided)
        if ! validate_chapter_identifiers "$REMOVE_CHAPTERS"; then
            exit 1
        fi
    fi

    # Run appropriate mode
    if [ "$NON_INTERACTIVE" = true ]; then
        echo -e "${GREEN}Running in non-interactive mode${NC}"
        echo ""
        echo -e "${BLUE}========================================"
        echo "Configuration Summary"
        echo -e "========================================${NC}"
        echo ""
        echo "Project Name:         $PROJECT_NAME"
        echo "Author:               $AUTHOR_NAME"
        echo "Institution:          $INSTITUTION"
        echo "Location:             $LOCATION"
        echo "Email:                $EMAIL"
        echo "Variant:              $VARIANT"
        echo "Bibliography Backend: $BIBLIO_BACKEND"
        if [ -n "$REMOVE_CHAPTERS" ]; then
            echo "Remove Chapters:      $REMOVE_CHAPTERS"
        fi
        echo ""
    else
        # Interactive mode - prompt for all values
        run_interactive_prompts
    fi

    echo -e "${GREEN}Configuration complete!${NC}"
    echo ""

    # Generate config file with user values
    generate_config_file "$VARIANT"

    # Configure bibliography backend
    configure_bibliography_backend "$VARIANT" "$BIBLIO_BACKEND"

    # Remove specified chapters (if any)
    remove_chapters "$REMOVE_CHAPTERS"

    echo -e "${GREEN}Project initialization complete!${NC}"
    echo ""
}

# Run main function
main "$@"
