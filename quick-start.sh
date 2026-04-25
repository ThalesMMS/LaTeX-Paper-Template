#!/bin/bash
# =================================================================
# LaTeX Paper Template - Quick Start Script
# Automated setup tool for quick project initialization
# Checks dependencies, runs project setup, and compiles first PDF
# =================================================================

set -e  # Exit on first error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script version
VERSION="1.0.0-dev"

# Script mode - default to interactive
NON_INTERACTIVE=false

# Trap to handle cleanup on error
cleanup_on_error() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo ""
        echo -e "${RED}==================================================================${NC}" >&2
        echo -e "${RED}Script terminated with errors (exit code: $exit_code)${NC}" >&2
        echo -e "${RED}==================================================================${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}Troubleshooting:${NC}" >&2
        echo "  - Check error messages above for details" >&2
        echo "  - Ensure you're running from the project root directory" >&2
        echo "  - Try running with --help for usage information" >&2
        echo "  - Check README.md for detailed setup instructions" >&2
        echo "" >&2
    fi
}

trap cleanup_on_error EXIT

# =================================================================
# HELP AND VERSION
# =================================================================

show_help() {
    cat << EOF
${BLUE}LaTeX Paper Template - Quick Start${NC}
${BLUE}Version: ${VERSION}${NC}

${GREEN}USAGE:${NC}
    bash quick-start.sh [OPTIONS]

${GREEN}DESCRIPTION:${NC}
    Automated setup tool for quick project initialization.
    Checks system dependencies, runs project setup, and compiles first PDF.

${GREEN}MODES:${NC}
    ${YELLOW}Interactive Mode (default):${NC}
        bash quick-start.sh

        Runs dependency checks and guides you through project setup
        with interactive prompts.

    ${YELLOW}Non-Interactive Mode:${NC}
        bash quick-start.sh --non-interactive

        Runs all setup steps automatically without prompts.
        Useful for CI/CD pipelines and automated workflows.

${GREEN}OPTIONS:${NC}
    --help                Show this help message and exit
    --version             Show version information and exit
    --non-interactive     Run in non-interactive mode (no prompts)

${GREEN}EXAMPLES:${NC}
    ${YELLOW}# Interactive mode (default)${NC}
    bash quick-start.sh

    ${YELLOW}# Non-interactive mode${NC}
    bash quick-start.sh --non-interactive

${GREEN}WHAT THIS SCRIPT DOES:${NC}
    1. Detects your platform (macOS, Linux, or WSL)
    2. Checks for required dependencies:
       - LaTeX distribution (pdflatex, xelatex, or lualatex)
       - Make build system
       - BibTeX/Biber (optional, for bibliography management)
    3. Provides installation instructions if dependencies are missing
    4. In interactive mode, you can proceed to init-project.sh after checks

${GREEN}NOTES:${NC}
    - This script only checks dependencies and does not modify your system
    - Use init-project.sh after this script to customize your project
    - For detailed setup, run init-project.sh directly with --help

For more information, see README.md

EOF
}

show_version() {
    echo "LaTeX Paper Template - Quick Start Script"
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
            -*)
                echo -e "${RED}Error: Unknown option: $1${NC}" >&2
                echo "" >&2
                echo "Valid options:" >&2
                echo "  --help                Show help message" >&2
                echo "  --version             Show version information" >&2
                echo "  --non-interactive     Run in non-interactive mode" >&2
                echo "" >&2
                echo "Use --help for detailed usage information" >&2
                exit 1
                ;;
            *)
                echo -e "${RED}Error: Unexpected argument: $1${NC}" >&2
                echo "This script does not accept positional arguments" >&2
                echo "Use --help for usage information" >&2
                exit 1
                ;;
        esac
    done
}

# =================================================================
# PLATFORM DETECTION
# =================================================================

# Detect the current platform
detect_platform() {
    local platform=""

    # Check for WSL (Windows Subsystem for Linux)
    if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
        platform="WSL"
    # Check for macOS (Darwin)
    elif [ "$(uname -s)" = "Darwin" ]; then
        platform="macOS"
    # Check for Linux
    elif [ "$(uname -s)" = "Linux" ]; then
        platform="Linux"
    else
        platform="Unknown"
    fi

    echo "$platform"
}

# =================================================================
# PRE-FLIGHT CHECKS
# =================================================================

# Pre-flight check for required files and directories
check_prerequisites() {
    local errors=0

    # Check if we're in the project root by looking for key files
    if [ ! -f "init-project.sh" ]; then
        echo -e "${RED}Error: init-project.sh not found in current directory${NC}" >&2
        echo -e "${YELLOW}Are you running this script from the project root?${NC}" >&2
        errors=$((errors + 1))
    fi

    if [ ! -f "Makefile" ]; then
        echo -e "${RED}Error: Makefile not found in current directory${NC}" >&2
        echo -e "${YELLOW}Are you running this script from the project root?${NC}" >&2
        errors=$((errors + 1))
    fi

    # Check for required directories
    if [ ! -d "config" ]; then
        echo -e "${RED}Error: config/ directory not found${NC}" >&2
        echo -e "${YELLOW}Are you running this script from the project root?${NC}" >&2
        errors=$((errors + 1))
    fi

    if [ ! -d "chapters" ]; then
        echo -e "${RED}Error: chapters/ directory not found${NC}" >&2
        echo -e "${YELLOW}Are you running this script from the project root?${NC}" >&2
        errors=$((errors + 1))
    fi

    # Check if output directory exists, create if missing
    if [ ! -d "output" ]; then
        echo -e "${YELLOW}Warning: output/ directory not found, will be created during compilation${NC}"
    fi

    if [ $errors -gt 0 ]; then
        echo "" >&2
        echo -e "${RED}Pre-flight checks failed. Cannot proceed.${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}Please ensure you're in the project root directory containing:${NC}" >&2
        echo "  - init-project.sh" >&2
        echo "  - Makefile" >&2
        echo "  - config/" >&2
        echo "  - chapters/" >&2
        echo "" >&2
        exit 1
    fi
}

# =================================================================
# DEPENDENCY CHECKING FUNCTIONS
# =================================================================

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for LaTeX distribution
check_latex() {
    local latex_found=false
    local latex_engine=""

    if command_exists pdflatex; then
        latex_found=true
        latex_engine="pdflatex"
    elif command_exists xelatex; then
        latex_found=true
        latex_engine="xelatex"
    elif command_exists lualatex; then
        latex_found=true
        latex_engine="lualatex"
    fi

    if [ "$latex_found" = true ]; then
        echo -e "${GREEN}✓ LaTeX distribution found: $latex_engine${NC}"
        return 0
    else
        echo -e "${RED}✗ LaTeX distribution not found${NC}" >&2
        return 1
    fi
}

# Check for Make
check_make() {
    if command_exists make; then
        echo -e "${GREEN}✓ Make found${NC}"
        return 0
    else
        echo -e "${RED}✗ Make not found${NC}" >&2
        return 1
    fi
}

# Check for BibTeX (optional but recommended)
check_bibtex() {
    if command_exists bibtex; then
        echo -e "${GREEN}✓ BibTeX found (optional)${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ BibTeX not found (optional, only needed if using bibtex backend)${NC}"
        return 0  # Don't fail, it's optional
    fi
}

# Check for Biber (optional but recommended for biblatex)
check_biber() {
    if command_exists biber; then
        echo -e "${GREEN}✓ Biber found (optional)${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Biber not found (optional, only needed if using biblatex backend)${NC}"
        return 0  # Don't fail, it's optional
    fi
}

# Main dependency check function
check_dependencies() {
    echo ""
    echo -e "${BLUE}==================================================================${NC}"
    echo -e "${BLUE}Checking dependencies...${NC}"
    echo -e "${BLUE}==================================================================${NC}"
    echo ""

    local all_required_found=true

    # Check required dependencies
    if ! check_latex; then
        all_required_found=false
    fi

    if ! check_make; then
        all_required_found=false
    fi

    # Check optional dependencies
    check_bibtex
    check_biber

    echo ""

    if [ "$all_required_found" = false ]; then
        echo -e "${RED}==================================================================${NC}"
        echo -e "${RED}Missing required dependencies!${NC}"
        echo -e "${RED}==================================================================${NC}"
        echo ""
        show_installation_instructions
        return 1
    else
        echo -e "${GREEN}==================================================================${NC}"
        echo -e "${GREEN}All required dependencies found!${NC}"
        echo -e "${GREEN}==================================================================${NC}"
        echo ""
        return 0
    fi
}

# Show installation instructions for missing dependencies
show_installation_instructions() {
    local platform=$(detect_platform)

    echo -e "${YELLOW}Please install the missing dependencies:${NC}"
    echo ""
    echo -e "${BLUE}Detected platform: ${platform}${NC}"
    echo ""

    # Show LaTeX installation instructions
    if ! command_exists pdflatex && ! command_exists xelatex && ! command_exists lualatex; then
        echo -e "${YELLOW}LaTeX Distribution:${NC}"
        echo "  - Required for compiling LaTeX documents"
        echo ""

        case "$platform" in
            macOS)
                echo -e "${GREEN}macOS Installation:${NC}"
                echo "  Option 1 (Recommended): Install MacTeX via Homebrew"
                echo "    brew install --cask mactex"
                echo ""
                echo "  Option 2: Download from https://www.tug.org/mactex/"
                echo "    - Full installation (~4GB)"
                echo "    - Includes all LaTeX packages and tools"
                echo ""
                ;;
            Linux)
                echo -e "${GREEN}Linux Installation:${NC}"
                echo "  Debian/Ubuntu:"
                echo "    sudo apt-get update"
                echo "    sudo apt-get install texlive-full"
                echo ""
                echo "  Fedora/RHEL:"
                echo "    sudo dnf install texlive-scheme-full"
                echo ""
                echo "  Arch Linux:"
                echo "    sudo pacman -S texlive-most"
                echo ""
                ;;
            WSL)
                echo -e "${GREEN}WSL (Windows Subsystem for Linux) Installation:${NC}"
                echo "  ${YELLOW}IMPORTANT:${NC} Install TeX Live inside WSL, not in Windows!"
                echo ""
                echo "  Inside your WSL terminal:"
                echo "    sudo apt-get update"
                echo "    sudo apt-get install texlive-full"
                echo ""
                echo "  ${YELLOW}Note:${NC} Do not use the Windows LaTeX installation."
                echo "  The script needs LaTeX accessible from within WSL."
                echo ""
                ;;
            *)
                echo -e "${GREEN}General Installation:${NC}"
                echo "  Visit: https://www.tug.org/texlive/"
                echo "  Or: https://www.latex-project.org/get/"
                echo ""
                ;;
        esac
    fi

    # Show Make installation instructions
    if ! command_exists make; then
        echo -e "${YELLOW}Make:${NC}"
        echo "  - Required for building the project"
        echo ""

        case "$platform" in
            macOS)
                echo -e "${GREEN}macOS Installation:${NC}"
                echo "  Install Xcode Command Line Tools:"
                echo "    xcode-select --install"
                echo ""
                ;;
            Linux)
                echo -e "${GREEN}Linux Installation:${NC}"
                echo "  Debian/Ubuntu:"
                echo "    sudo apt-get install build-essential"
                echo ""
                echo "  Fedora/RHEL:"
                echo "    sudo dnf groupinstall 'Development Tools'"
                echo ""
                echo "  Arch Linux:"
                echo "    sudo pacman -S base-devel"
                echo ""
                ;;
            WSL)
                echo -e "${GREEN}WSL Installation:${NC}"
                echo "  Inside your WSL terminal:"
                echo "    sudo apt-get update"
                echo "    sudo apt-get install build-essential"
                echo ""
                ;;
            *)
                echo -e "${GREEN}General Installation:${NC}"
                echo "  Install development tools for your system"
                echo ""
                ;;
        esac
    fi

    echo -e "${YELLOW}For more information, visit:${NC}"
    echo "  https://github.com/yourusername/latex-paper-template#dependencies"
    echo ""
}

# =================================================================
# PROJECT SETUP
# =================================================================

# Run init-project.sh to set up the project
run_init_project() {
    echo ""
    echo -e "${BLUE}==================================================================${NC}"
    echo -e "${BLUE}Running project initialization...${NC}"
    echo -e "${BLUE}==================================================================${NC}"
    echo ""

    # Check if init-project.sh exists
    if [ ! -f "init-project.sh" ]; then
        echo -e "${RED}Error: init-project.sh not found in current directory${NC}" >&2
        echo -e "${YELLOW}Are you running this script from the project root?${NC}" >&2
        echo "" >&2
        echo "Expected file location: ./init-project.sh" >&2
        echo "" >&2
        return 1
    fi

    # Check if init-project.sh is executable
    if [ ! -r "init-project.sh" ]; then
        echo -e "${RED}Error: init-project.sh is not readable${NC}" >&2
        echo -e "${YELLOW}Try: chmod +r init-project.sh${NC}" >&2
        return 1
    fi

    # Run init-project.sh with appropriate mode
    if [ "$NON_INTERACTIVE" = true ]; then
        # Non-interactive mode: use default values
        echo -e "${YELLOW}Running init-project.sh in non-interactive mode with defaults...${NC}"
        echo ""

        if ! bash init-project.sh --non-interactive \
            --name "My Research Paper" \
            --author "Author Name" \
            --institution "Institution Name" \
            --location "City -- State -- Country" \
            --email "author@example.com" \
            --variant "paper" \
            --biblio "thebibliography"; then

            echo "" >&2
            echo -e "${RED}==================================================================${NC}" >&2
            echo -e "${RED}Project initialization failed${NC}" >&2
            echo -e "${RED}==================================================================${NC}" >&2
            echo "" >&2
            echo -e "${YELLOW}Troubleshooting:${NC}" >&2
            echo "  - Check error messages above from init-project.sh" >&2
            echo "  - Verify config/ and chapters/ directories exist" >&2
            echo "  - Try running 'bash init-project.sh --help' for more info" >&2
            echo "" >&2
            return 1
        fi
    else
        # Interactive mode: run init-project.sh interactively
        if ! bash init-project.sh; then
            echo "" >&2
            echo -e "${RED}==================================================================${NC}" >&2
            echo -e "${RED}Project initialization failed or was cancelled${NC}" >&2
            echo -e "${RED}==================================================================${NC}" >&2
            echo "" >&2
            echo -e "${YELLOW}If you cancelled the setup, you can:${NC}" >&2
            echo "  - Run 'bash init-project.sh' to try again" >&2
            echo "  - Run 'bash quick-start.sh --non-interactive' for automatic setup" >&2
            echo "" >&2
            return 1
        fi
    fi

    echo ""
    echo -e "${GREEN}✓ Project initialization complete!${NC}"
    echo ""

    return 0
}

# Compile the initial PDF
compile_initial_pdf() {
    echo ""
    echo -e "${BLUE}==================================================================${NC}"
    echo -e "${BLUE}Compiling initial PDF...${NC}"
    echo -e "${BLUE}==================================================================${NC}"
    echo ""

    # Check if Makefile exists
    if [ ! -f "Makefile" ]; then
        echo -e "${RED}Error: Makefile not found in current directory${NC}" >&2
        echo -e "${YELLOW}Are you running this script from the project root?${NC}" >&2
        echo "" >&2
        return 1
    fi

    # Check if Makefile is readable
    if [ ! -r "Makefile" ]; then
        echo -e "${RED}Error: Makefile is not readable${NC}" >&2
        echo -e "${YELLOW}Try: chmod +r Makefile${NC}" >&2
        return 1
    fi

    # Verify make command exists (should be caught by dependency check, but double-check)
    if ! command_exists make; then
        echo -e "${RED}Error: make command not found${NC}" >&2
        echo -e "${YELLOW}This should have been caught by dependency checks${NC}" >&2
        return 1
    fi

    echo -e "${YELLOW}Running: make compile${NC}"
    echo -e "${YELLOW}This may take a few minutes...${NC}"
    echo ""

    # Run make compile and capture output
    if make compile 2>&1; then
        echo ""
        echo -e "${GREEN}==================================================================${NC}"
        echo -e "${GREEN}PDF compilation successful!${NC}"
        echo -e "${GREEN}==================================================================${NC}"
        echo ""

        # Check if PDF was created and provide specific location
        local pdf_found=false

        if [ -f "output/article-main-v2.pdf" ]; then
            echo -e "${GREEN}✓ PDF created: output/article-main-v2.pdf${NC}"
            pdf_found=true
        fi

        if [ -f "output/paper-main.pdf" ]; then
            echo -e "${GREEN}✓ PDF created: output/paper-main.pdf${NC}"
            pdf_found=true
        fi

        if [ -f "output/monograph-main.pdf" ]; then
            echo -e "${GREEN}✓ PDF created: output/monograph-main.pdf${NC}"
            pdf_found=true
        fi

        if [ -f "output/thesis-main.pdf" ]; then
            echo -e "${GREEN}✓ PDF created: output/thesis-main.pdf${NC}"
            pdf_found=true
        fi

        if [ "$pdf_found" = false ]; then
            echo -e "${YELLOW}⚠ PDF location unknown, checking output/ directory...${NC}"
            if [ -d "output" ]; then
                local pdf_files=$(find output -name "*.pdf" -type f 2>/dev/null)
                if [ -n "$pdf_files" ]; then
                    echo -e "${GREEN}Found PDF files:${NC}"
                    echo "$pdf_files" | while read -r pdf; do
                        echo "  - $pdf"
                    done
                else
                    echo -e "${YELLOW}No PDF files found in output/ directory${NC}"
                fi
            fi
        fi

        echo ""
        return 0
    else
        local make_exit_code=$?
        echo ""
        echo -e "${RED}==================================================================${NC}" >&2
        echo -e "${RED}PDF compilation failed (exit code: $make_exit_code)${NC}" >&2
        echo -e "${RED}==================================================================${NC}" >&2
        echo "" >&2

        # Provide detailed troubleshooting guidance
        echo -e "${YELLOW}Troubleshooting:${NC}" >&2
        echo "" >&2

        # Check for build log
        if [ -f "output/build.log" ]; then
            echo -e "${YELLOW}1. Check the build log for detailed errors:${NC}" >&2
            echo "   cat output/build.log" >&2
            echo "" >&2

            # Try to extract last few lines of errors
            echo -e "${YELLOW}Last few lines of build.log:${NC}" >&2
            tail -n 10 output/build.log 2>/dev/null | sed 's/^/   /' >&2
            echo "" >&2
        else
            echo -e "${YELLOW}1. Build log not found at output/build.log${NC}" >&2
            echo "" >&2
        fi

        echo -e "${YELLOW}2. Common LaTeX compilation issues:${NC}" >&2
        echo "   - Missing LaTeX packages (install texlive-full)" >&2
        echo "   - Syntax errors in .tex files" >&2
        echo "   - Missing bibliography files if using BibTeX/BibLaTeX" >&2
        echo "   - File permission issues" >&2
        echo "" >&2

        echo -e "${YELLOW}3. Try compiling manually to see detailed errors:${NC}" >&2
        echo "   make compile" >&2
        echo "" >&2

        echo -e "${YELLOW}4. Clean build artifacts and try again:${NC}" >&2
        echo "   make clean" >&2
        echo "   make compile" >&2
        echo "" >&2

        return 1
    fi
}

# =================================================================
# MAIN ENTRY POINT
# =================================================================

main() {
    # Parse command-line arguments first
    parse_arguments "$@"

    echo ""
    echo -e "${BLUE}==================================================================${NC}"
    echo -e "${BLUE}LaTeX Paper Template - Quick Start${NC}"
    echo -e "${BLUE}Version: ${VERSION}${NC}"
    echo -e "${BLUE}==================================================================${NC}"

    if [ "$NON_INTERACTIVE" = true ]; then
        echo -e "${YELLOW}Running in non-interactive mode${NC}"
    fi
    echo ""

    # Run pre-flight checks
    echo -e "${BLUE}Running pre-flight checks...${NC}"
    check_prerequisites
    echo -e "${GREEN}✓ Pre-flight checks passed${NC}"
    echo ""

    # Run dependency checks
    if ! check_dependencies; then
        echo -e "${RED}==================================================================${NC}" >&2
        echo -e "${RED}Cannot proceed without required dependencies${NC}" >&2
        echo -e "${RED}==================================================================${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}Please install the missing dependencies and run this script again.${NC}" >&2
        echo "" >&2
        exit 1
    fi

    echo -e "${GREEN}✓ Dependency check complete!${NC}"
    echo ""

    # In interactive mode, ask user if they want to proceed
    if [ "$NON_INTERACTIVE" = false ]; then
        echo -e "${YELLOW}==================================================================${NC}"
        echo -e "${YELLOW}Ready to set up your project${NC}"
        echo -e "${YELLOW}==================================================================${NC}"
        echo ""
        echo "This will:"
        echo "  1. Run init-project.sh to customize your project"
        echo "  2. Compile the initial PDF"
        echo ""
        echo -e "${YELLOW}Note: You can press Ctrl+C at any time to cancel${NC}"
        echo ""

        read -p "Do you want to proceed? (y/n): " -n 1 -r
        echo ""
        echo ""

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}==================================================================${NC}"
            echo -e "${YELLOW}Setup cancelled by user${NC}"
            echo -e "${YELLOW}==================================================================${NC}"
            echo ""
            echo "You can run the following commands manually when ready:"
            echo "  ${GREEN}bash init-project.sh${NC}       # Customize your project"
            echo "  ${GREEN}make compile${NC}               # Compile the PDF"
            echo ""
            echo "Or run this script again:"
            echo "  ${GREEN}bash quick-start.sh${NC}        # Interactive setup"
            echo "  ${GREEN}bash quick-start.sh --non-interactive${NC}  # Automatic setup"
            echo ""
            exit 0
        fi
    fi

    # Run project initialization
    if ! run_init_project; then
        echo -e "${RED}==================================================================${NC}" >&2
        echo -e "${RED}Setup failed during project initialization${NC}" >&2
        echo -e "${RED}==================================================================${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}You can try:${NC}" >&2
        echo "  1. Fix the error above and run 'bash quick-start.sh' again" >&2
        echo "  2. Run 'bash init-project.sh' directly to customize your project" >&2
        echo "" >&2
        exit 1
    fi

    # Compile initial PDF
    if ! compile_initial_pdf; then
        echo -e "${RED}==================================================================${NC}" >&2
        echo -e "${RED}Setup incomplete: PDF compilation failed${NC}" >&2
        echo -e "${RED}==================================================================${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}Your project has been initialized, but PDF compilation failed.${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}To resolve:${NC}" >&2
        echo "  1. Review the error messages above" >&2
        echo "  2. Check output/build.log for detailed errors" >&2
        echo "  3. Try running: make clean && make compile" >&2
        echo "" >&2
        exit 1
    fi

    # Success message
    echo -e "${GREEN}==================================================================${NC}"
    echo -e "${GREEN}🎉 Quick start complete! 🎉${NC}"
    echo -e "${GREEN}==================================================================${NC}"
    echo ""
    echo -e "${GREEN}✓ Pre-flight checks passed${NC}"
    echo -e "${GREEN}✓ Dependencies verified${NC}"
    echo -e "${GREEN}✓ Project initialized${NC}"
    echo -e "${GREEN}✓ Initial PDF compiled${NC}"
    echo ""
    echo -e "${YELLOW}==================================================================${NC}"
    echo -e "${YELLOW}Next Steps${NC}"
    echo -e "${YELLOW}==================================================================${NC}"
    echo ""
    echo "  ${BLUE}1. Edit your content:${NC}"
    echo "     - chapters/     # Main content files"
    echo "     - sections/     # Section files"
    echo "     - config/       # Project configuration"
    echo ""
    echo "  ${BLUE}2. Rebuild the PDF:${NC}"
    echo "     make compile"
    echo ""
    echo "  ${BLUE}3. Explore other commands:${NC}"
    echo "     make help       # Show all available commands"
    echo "     make clean      # Clean build artifacts"
    echo "     make watch      # Auto-compile on changes (if available)"
    echo ""
    echo -e "${GREEN}Happy writing! 📝${NC}"
    echo ""
}

# Run main function
main "$@"
