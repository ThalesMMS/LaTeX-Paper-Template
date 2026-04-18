# LaTeX Template – Paper / Monograph / Thesis (SBC)

This repository is a skeleton LaTeX template with three variants (`paper`, `monograph`, and `thesis`) based on the SBC template. The content is intentionally reduced to placeholders so it can be customized quickly.

## Project Status

**Stable baseline with incremental improvements.** This template is safe to adopt for academic work, and future updates are expected to preserve backwards-compatible user workflows where possible. Any structure changes that affect document layout, scripts, bibliography configuration, or build commands should be documented in the release notes.

Release snapshots should normally be tagged and validated through CI before publication. If CI is unavailable, the release must use documented fallback evidence, such as manual review notes, signed validation artifacts, or audit logs, and record that evidence with the release.

### Releases and Versioning

- See [CHANGELOG.md](CHANGELOG.md) for release history.
- See [docs/release-checklist.md](docs/release-checklist.md) for the release checklist and reproducibility requirements.
- For reproducible project setup, pin to a specific release tag, for example:

  ```bash
  git clone --branch v1.0.0 https://github.com/ThalesMMS/LaTeX-Paper-Template.git
  ```

## Template Variants

This template offers three variants for different kinds of academic documents:

### 1. Paper (`paper-main.tex`)
- **Use case:** Conference or journal papers (6-10 pages)
- **Class:** `article`
- **Features:**
  - Simplified, streamlined structure
  - Only the essential chapters (introduction, related work, methodology, results, conclusions)
  - No table of contents by default
  - Bibliography via `thebibliography` (simple/manual)
  - Ideal for quick submissions and short papers
- **Config:** `config/paper-config.tex`
- **Build:** `make compile MAIN_FILE=paper-main` or `make view MAIN_FILE=paper-main`

### 2. Monograph (`monograph-main.tex`)
- **Use case:** Undergraduate capstone projects, specialization monographs
- **Class:** `report`
- **Features:**
  - Full structure with numbered chapters
  - Table of contents included automatically
  - All 8 default chapters (introduction, related work, methodology, results, implementation details, technical challenges, future work, conclusions)
  - Bibliography via `thebibliography` or BibTeX
  - Ideal for 30-80 page monographs
- **Config:** `config/monograph-config.tex`
- **Build:** `make compile MAIN_FILE=monograph-main` or `make view MAIN_FILE=monograph-main`

### 3. Thesis / Dissertation (`thesis-main.tex`)
- **Use case:** Master's theses and PhD dissertations
- **Class:** `report`
- **Features:**
  - Full formal structure
  - Table of contents, list of figures, and list of tables
  - Dedication, acknowledgments, and epigraph (optional)
  - Glossary and index enabled by default
  - Bibliography via `thebibliography` or BibTeX
  - Ideal for longer documents (80-300+ pages)
- **Config:** `config/thesis-config.tex`
- **Build:** `make compile MAIN_FILE=thesis-main` or `make view MAIN_FILE=thesis-main`

### Selection Guide

| Criteria | Paper | Monograph | Thesis / Dissertation |
|----------|-------|-----------|------------------------|
| **Typical length** | 6-10 | 30-80 | 80-300+ |
| **LaTeX class** | `article` | `report` | `report` |
| **Table of contents** | No | Yes | Yes |
| **Lists (figures/tables)** | No | Optional | Yes |
| **Glossary / Index** | No | No | Yes |
| **Chapters** | Essential only | Full | Full + extra front/back matter |
| **Setup time** | Fast (~5 min) | Medium (~15 min) | Full (~30 min) |

**Tip:** If you are unsure whether to start with the monograph or thesis variant, start with `monograph-main.tex` and migrate to `thesis-main.tex` later if you need extra features such as a glossary, index, or additional lists.

## Automated Quick Start

**New:** an automated bootstrap script that configures everything in under 5 minutes.

### What is `quick-start.sh`?

The `quick-start.sh` script is the fastest way to start using this template. It automates the initial setup process:

1. **Checks dependencies** - Detects whether LaTeX, Make, and BibTeX/Biber are installed
2. **Detects your platform** - macOS, Linux, or WSL
3. **Provides guidance** - Shows platform-specific install instructions if something is missing
4. **Configures the project** - Runs `init-project.sh` to personalize the template with your information
5. **Builds the first PDF** - Generates an initial document automatically

**Benefits:**
- **Fast** - From download to PDF in under 5 minutes
- **Safer** - Validates dependencies before starting
- **Automatic** - Supports both interactive and non-interactive modes
- **Complete** - Covers the whole initial setup with one command

### Interactive Mode (Recommended)

Run without arguments for step-by-step guided setup:

```bash
bash quick-start.sh
```

The script will:
1. Check whether LaTeX and Make are installed
2. Show installation instructions if anything is missing
3. Ask whether you want to continue with project setup
4. Run `init-project.sh` interactively (name, author, institution, etc.)
5. Automatically build the first PDF

**Result:** a configured project and a generated PDF in under 5 minutes.

### Non-Interactive Mode

For automation, CI/CD, or cases where you do not want interactive prompts:

```bash
bash quick-start.sh --non-interactive
```

This will:
- Check dependencies without interaction
- Run `init-project.sh` with default values
- Build the PDF automatically

**Note:** You can customize the project later by running `bash init-project.sh` again or by editing the files in `config/`.

### Available Options

```bash
bash quick-start.sh --help              # Show full help
bash quick-start.sh --version           # Show version
bash quick-start.sh --non-interactive   # Automatic mode
```

### Troubleshooting

**Dependencies not found?**
- The script automatically detects your operating system
- It prints exact commands to install LaTeX and Make
- Supported platforms: macOS (Homebrew), Linux (apt/dnf/pacman), and WSL

**Compilation error?**
- Check `output/build.log` for details
- Run `make clean && make compile` and try again
- See the [Troubleshooting](#faq--common-errors) section below

**Want to customize later?**
- Run `bash init-project.sh` again at any time
- Or edit the files in `config/` manually

### Next Steps

After running `quick-start.sh`, you will have:
- A project configured with your information
- A first PDF compiled in `output/`
- A template ready for writing

**Then you can:**
1. Edit the content in `chapters/` and `sections/`
2. Rebuild with `make compile` or `make paper/monograph/thesis`
3. Customize settings in `config/`
4. See [Project Initialization CLI](#project-initialization-cli) for advanced options

## Quick Start

Choose your variant and build immediately:

### Paper
```bash
# Build and preview a paper
make paper                          # builds output/paper-main.pdf and opens it automatically
make compile MAIN_FILE=paper-main   # build only
make view MAIN_FILE=paper-main      # build and open
```

### Monograph
```bash
# Build and preview a monograph
make monograph                      # builds output/monograph-main.pdf and opens it automatically
make compile MAIN_FILE=monograph-main
make view MAIN_FILE=monograph-main
```

### Thesis
```bash
# Build and preview a thesis/dissertation
make thesis                         # builds output/thesis-main.pdf and opens it automatically
make compile MAIN_FILE=thesis-main
make view MAIN_FILE=thesis-main
```

### Additional Commands
```bash
make clean                              # remove temporary files
make bib MAIN_FILE=paper-main           # build with BibTeX (if configured)
make view-bib MAIN_FILE=monograph-main  # build with BibTeX and open
```

## Project Initialization CLI

**New feature:** this template includes an interactive CLI that automates initial project setup.

### Overview

The `init-project.sh` script customizes the template with your information (project name, author, institution, bibliography backend) and can also remove unnecessary chapters. It avoids manual edits across multiple configuration files.

**Benefits:**
- Fast setup - configure the project in under 1 minute
- Fewer mistakes - automatic validation of inputs and formats
- Flexible - supports both interactive and non-interactive usage
- Customizable - choose variant, bibliography backend, and chapters

### Interactive Mode (Recommended)

Run the script without arguments for guided setup:

```bash
bash init-project.sh
```

The script will ask for:
- **Project Name:** title of your document
- **Author Name:** your full name
- **Institution:** university or institute name
- **Location:** format `City -- State -- Country`
- **Email:** your email address
- **Variant:** `paper`, `monograph`, or `thesis`
- **Bibliography Backend:** `thebibliography`, `bibtex`, or `biblatex`
- **Chapters to Remove:** optional comma-separated list (for example `chapter2,chapter4`)

### Non-Interactive Mode

For automation or scripting, use non-interactive mode with all arguments:

```bash
bash init-project.sh --non-interactive \
  --name "My Research Paper" \
  --author "John Doe" \
  --institution "MIT" \
  --location "Boston -- MA -- USA" \
  --email "john@mit.edu" \
  --variant paper \
  --biblio thebibliography
```

### Available Options

```text
--help                      Show full help
--version                   Show version
--non-interactive           Non-interactive mode
--name NAME                 Project name
--author AUTHOR             Author name
--institution INSTITUTION   Institution
--location LOCATION         Location (City -- State -- Country)
--email EMAIL               Contact email
--variant VARIANT           Variant: paper, monograph, thesis
--biblio BACKEND            Backend: thebibliography, bibtex, biblatex
--remove-chapters CHAPTERS  Chapters to remove (optional)
```

### Valid Values

**Variants:**
- `paper` - Short paper with a simplified structure (6-10 pages)
- `monograph` - Monograph / capstone with a full table of contents (30-80 pages)
- `thesis` - Thesis / dissertation with front matter and extra structure (80-300+ pages)

**Bibliography backends:**
- `thebibliography` - Manual bibliography environment with no external files
- `bibtex` - Traditional BibTeX using a `.bib` file
- `biblatex` - Modern BibLaTeX with `biber` (recommended for larger projects)

**Chapters:**
Use identifiers `chapter1` through `chapter10`, separated by commas:
- `chapter1` = `01-introducao.tex`
- `chapter2` = `02-trabalhos-relacionados.tex`
- `chapter3` = `03-metodologia.tex`
- `chapter4` = `04-avaliacao-resultados.tex`
- `chapter5` = `05-detalhes-implementacao.tex`
- `chapter6` = `06-desafios-tecnicos.tex`
- `chapter7` = `07-trabalhos-futuros.tex`
- `chapter8` = `08-conclusoes-e-contribuicoes.tex`
- `chapter9` = `09-apendices.tex`
- `chapter10` = `10-cronograma.tex`

### Examples

**Example 1: full interactive setup (easiest)**
```bash
# Starts interactive mode - answer the prompts
bash init-project.sh
```

**Example 2: quick paper with BibTeX**
```bash
bash init-project.sh --non-interactive \
  --name "Machine Learning in Healthcare" \
  --author "Jane Smith" \
  --institution "Stanford University" \
  --location "Stanford -- CA -- USA" \
  --email "jane.smith@stanford.edu" \
  --variant paper \
  --biblio bibtex
```

**Example 3: monograph while removing unnecessary chapters**
```bash
bash init-project.sh --non-interactive \
  --name "Sistema de Recomendação com Deep Learning" \
  --author "Carlos Silva" \
  --institution "Universidade de São Paulo" \
  --location "São Paulo -- SP -- Brasil" \
  --email "carlos.silva@usp.br" \
  --variant monograph \
  --biblio biblatex \
  --remove-chapters "chapter6,chapter7"
```

**Example 4: thesis with BibLaTeX (recommended for longer projects)**
```bash
bash init-project.sh --non-interactive \
  --name "Quantum Computing Applications in Cryptography" \
  --author "Robert Johnson" \
  --institution "California Institute of Technology" \
  --location "Pasadena -- CA -- USA" \
  --email "rjohnson@caltech.edu" \
  --variant thesis \
  --biblio biblatex \
  --remove-chapters "chapter9,chapter10"
```

### Recommended Workflow

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd LaTeX-Paper-Template
   ```

2. **Run the initialization script:**
   ```bash
   bash init-project.sh
   ```

3. **Build and preview:**
   ```bash
   make paper      # or make monograph, or make thesis
   ```

4. **Edit the content:**
   - Replace placeholders in `chapters/`
   - Add your figures to `assets/`
   - Edit references in `bibliography/`

5. **Build again:**
   ```bash
   make paper      # generates an updated PDF
   ```

**Tip:** After running the script, the configuration files in `config/` will already be updated with your data, so you can move directly to `make paper`, `make monograph`, or `make thesis`.

## Structure

```text
├── init-project.sh         # CLI initialization script
├── quick-start.sh          # Quick-start bootstrap script
├── paper-main.tex          # Paper variant (6-10 pages)
├── monograph-main.tex      # Monograph / capstone variant (30-80 pages)
├── thesis-main.tex         # Thesis / dissertation variant (80-300+ pages)
├── article-main-v2.tex     # Legacy variant (compatibility)
├── Makefile                # Build commands
├── chapters/               # Numbered chapters
│   ├── 01-introducao.tex
│   ├── 02-trabalhos-relacionados.tex
│   ├── 03-metodologia.tex
│   ├── 04-avaliacao-resultados.tex       # uses template_fig1.jpg
│   ├── 05-detalhes-implementacao.tex     # uses template_diagram1/2.png
│   ├── 06-desafios-tecnicos.tex
│   ├── 07-trabalhos-futuros.tex
│   └── 08-conclusoes-e-contribuicoes.tex
├── sections/               # Abstract / summary sections
├── bibliography/           # References (`thebibliography` or BibTeX)
│   ├── references.tex      # `thebibliography` example
│   ├── sbc-template.bib    # Optional BibTeX database example
│   └── sbc.bst             # Optional SBC style file
├── config/                 # Styles and config files (SBC + variant configs)
├── tests/                  # Validation and test suite
│   ├── run_all_tests.sh    # Main test runner
│   ├── test_*.sh           # Unit-style tests
│   └── validate-*.sh       # E2E validation scripts
└── output/                 # Compiled output
```

## Basic Usage

1. Choose the appropriate variant (see the selection guide above).
2. Edit metadata in the correct variant config file:
   - Paper: `config/paper-config.tex`
   - Monograph: `config/monograph-config.tex`
   - Thesis: `config/thesis-config.tex`
   - Legacy: `config/article-config.tex`
3. Replace placeholders in files under `chapters/` and `sections/`.
4. Build:

```bash
# For paper-main.tex
make compile MAIN_FILE=paper-main   # generates output/paper-main.pdf
make view MAIN_FILE=paper-main      # builds and opens the PDF

# For monograph-main.tex
make compile MAIN_FILE=monograph-main
make view MAIN_FILE=monograph-main

# For thesis-main.tex
make compile MAIN_FILE=thesis-main
make view MAIN_FILE=thesis-main

# Remove temporary files
make clean
```

### Using BibTeX (`.bib`)

```bash
# After configuring \bibliographystyle and \bibliography in the main file
make bib       # builds with BibTeX and generates the PDF
make view-bib  # builds with BibTeX and opens the PDF
```

## Conventions

- Chapters use numbered files such as `NN-titulo.tex` and are included with `\input{chapters/NN-...}`.
- Suggested labels: `fig:`, `tab:`, `sec:`, `eq:`. Example: `\label{fig:exemplo}`.
- Images use `graphicx`. The template already includes real examples:
  - Assets live in `assets/` (`\graphicspath` is already configured).
  - `chapters/05-detalhes-implementacao.tex` uses `template_diagram1.png` and `template_diagram2.png`.
  - `chapters/04-avaliacao-resultados.tex` uses `template_fig1.jpg`.
  - Replace those files with your own figures or adjust the paths.
- Subfigures: because the SBC template uses `caption2`, the `subcaption` package is incompatible. Use `minipage` with text captions instead (see `sections/guia-rapido.tex`).
- Minimal bibliography lives in `bibliography/references.tex` if you prefer `thebibliography`.
- Bibliography options:
  - Default: `bibliography/references.tex` (`thebibliography`)
  - Alternative: BibTeX with `bibliography/sbc-template.bib` + `bibliography/sbc.bst`
  - Detailed `sbc.bst` provenance lives in `docs/sbc-bst-provenance.md`
  - Manual example:
    `pdflatex article-main-v2.tex && bibtex article-main-v2 && pdflatex article-main-v2.tex && pdflatex article-main-v2.tex`

## Bibliography: `.tex` vs `.bib`

- **`.tex` file (`thebibliography`)**
  - Entries are written manually in `bibliography/references.tex`
  - No extra tooling required; ideal for small or static lists
- **`.bib` file (BibTeX)**
  - References live in `bibliography/sbc-template.bib`, with style defined by `sbc.bst`
  - Better consistency and reuse across projects; ideal for larger bibliographies
- **How to switch this template to BibTeX**
  - In your main variant file (for example `paper-main.tex`, `monograph-main.tex`, or `thesis-main.tex`), comment out: `\input{bibliography/references}`
  - Add the following at the end of the main file:
    `\bibliographystyle{sbc}` and `\bibliography{bibliography/sbc-template}`
  - Build with `make bib MAIN_FILE=<variant>` (or manually `pdflatex → bibtex → pdflatex → pdflatex`)
  - If BibTeX cannot find `sbc.bst` inside `bibliography/`, move `sbc.bst` to the project root or adjust `TEXINPUTS`

## Step-by-Step Usage

### 1) Metadata (title, author, institution)
Edit the correct variant config file:
- Paper: `config/paper-config.tex`
- Monograph: `config/monograph-config.tex`
- Thesis: `config/thesis-config.tex`
- Legacy: `config/article-config.tex`

Fill in the commands:
- `\newcommand{\DocumentTitle}{[Work Title]}`
- `\newcommand{\AuthorName}{[Author Name]}`
- `\newcommand{\AuthorInstitution}{[Department / Program] -- [Institution]}`
- `\newcommand{\AuthorLocation}{[City] -- [State] -- [Country]}`
- `\newcommand{\AuthorEmail}{[email@example.com]}`

PDF metadata (`hypersetup`) is filled automatically.

### 2) Folder structure
- `chapters/`: numbered chapters included via `\input{chapters/NN-name}`
- `sections/`: abstract / summary sections
- `bibliography/`: references in `references.tex` (`thebibliography`) or `sbc-template.bib` (BibTeX) + `sbc.bst`
- `config/`: styles and centralized packages/macros
- `assets/`: images/diagrams, already included via `\graphicspath`
- `output/`: final PDF and `build.log` generated by the Makefile

### 3) Add chapters / sections
- Create `chapters/09-apendices.tex` (for example) and add it to the main file of your variant:
  `\input{chapters/09-apendices}`
- Use labels such as `\label{sec:my-section}` and references such as `\ref{sec:my-section}`.

### 4) Figures and tables
- Images: place files in `assets/` and include them with `\includegraphics[width=...]{file}` (without a path, thanks to `\graphicspath`). Add `\label{fig:...}` and refer to them with `\ref{fig:...}`.
- Tables: prefer `booktabs` (`\toprule`, `\midrule`, `\bottomrule`). See the example in `04-avaliacao-resultados.tex`.
- Wide tables with `tabularx`: see the example in `sections/guia-rapido.tex` using `X` columns.

### 5) Citations and bibliography
- `thebibliography`: edit `bibliography/references.tex` and cite with `\cite{key}`
- BibTeX: comment out `\input{bibliography/references}` and uncomment:
  `\bibliographystyle{sbc}` and `\bibliography{bibliography/sbc-template}`
  Then run `make bib`.

### 6) Table of contents and hyperlinks
- **Paper:** a table of contents is uncommon in short papers; uncomment `\tableofcontents` only if needed
- **Monograph / Thesis:** `\tableofcontents` is already included automatically
- PDF links and metadata are configured by `hyperref` in the config files

### 7) Quick LaTeX guide
Ready-made examples (side-by-side figures with `minipage`, wide tables with `tabularx`, equations with `\eqref`, `listings`, and optional `minted`) live in `sections/guia-rapido.tex`. Include them with:

```tex
\input{sections/guia-rapido}
```

### 8) Glossary and index (optional)
- **Glossary**
  - Enable in `config/article-config.tex`: `\usepackage[acronym]{glossaries}` and `\makeglossaries`
  - Define entries with `\newglossaryentry` / `\newacronym` and call `\printglossaries` at the end of the document
  - Build with `make glossary`
- **Index**
  - Enable in `config/article-config.tex`: `\usepackage{imakeidx}` and `\makeindex`
  - Mark terms with `\index{term}` and call `\printindex` at the end
  - Build with `make index`

### 9) Build and preview
- Default: `make compile` (2 `pdflatex` passes) and `make view`
- BibTeX: `make bib` or `make view-bib`
- Logs: inspect `output/build.log` when there is an error

## Makefile Explained

### Variables
- `MAIN_FILE`: main file without extension (default: `article-main-v2`)
  - For the other variants, use `MAIN_FILE=paper-main`, `MAIN_FILE=monograph-main`, or `MAIN_FILE=thesis-main`
- `OUTPUT_DIR`: output directory (`output/`)
- `BACKUP_DIR`: backup location (`backups/`)
- `ENGINE`: LaTeX engine (`pdflatex`, `xelatex`, or `lualatex`)
- `TEXFLAGS`: extra flags (for example `-shell-escape` when using `minted`)

### Targets
- `make compile`: builds with `thebibliography`; quiet output; log written to `output/build.log`
- `make toc`: runs a third engine pass when the log indicates TOC/reference changes
- `make bib`: builds with BibTeX (requires `\bibliographystyle` and `\bibliography`)
- `make view` / `make view-bib` / `make view-biblatex`: build and open the PDF
- `make clean`: remove temporary files and delete `output/`
- `make backup`: create a `.tar.gz` containing the main directories (excluding `output/`)
- `make stats`: simple line/word counts
- `make help`: summarize commands and point to `output/build.log`
- `ENGINE` override examples:
  - `make ENGINE=xelatex compile`
  - `make ENGINE=lualatex biblatex`

## FAQ / Common Errors

### Undefined references (`??`) or blank citations
- Run another `make compile` pass for internal references
- Or run `make bib` / `make biblatex` when using an external bibliography backend
- Check that matching `\label{...}` and `\cite{...}` keys exist

### Figure not found
- Confirm the filename and extension inside `assets/` (case-sensitive)
- `\graphicspath` already points to `assets/`, so use `\includegraphics{file}` without a path

### Font / accent issues
- The template uses `\usepackage[T1]{fontenc}` and `\usepackage[utf8]{inputenc}`
- If you use XeLaTeX or LuaLaTeX, remove `inputenc` and configure fonts with `fontspec` if desired

### Links are not clickable
- `hyperref` is already enabled
- Compile twice so the table of contents and anchors are refreshed correctly

## Tips

- Keep new macros and packages centralized in the variant config file (`config/paper-config.tex`, `config/monograph-config.tex`, or `config/thesis-config.tex`)
- Keep the text concise and avoid very long lines where possible
- If something breaks, run `make clean` and build again
- When migrating between variants, copy metadata from the config file and adjust the `\input{chapters/...}` lines in the main file

## Testing & Validation

This template includes a comprehensive test suite that validates template integrity automatically and ensures that all variants compile correctly.

### Overview

The test suite validates:
- **Required files** - All essential template files are present
- **Compilation** - All 3 variants (`paper`, `monograph`, `thesis`) compile successfully
- **Bibliography** - All 3 backends (`thebibliography`, BibTeX, BibLaTeX) work
- **LaTeX warnings** - Detects undefined references, citations, overfull hboxes, and related issues
- **Build system** - Confirms that the Makefile and initialization scripts work correctly

**Total coverage:** about 75 individual checks in roughly 80 seconds.

### Running Tests

**Run all tests:**
```bash
bash tests/run_all_tests.sh
```

**Run a specific test:**
```bash
bash tests/run_all_tests.sh --test required_files
bash tests/run_all_tests.sh --test compilation_bibtex
```

**List available tests:**
```bash
bash tests/run_all_tests.sh --list
```

**Verbose mode (debugging):**
```bash
bash tests/run_all_tests.sh --verbose
```

### Available Tests

1. `test_required_files` - validates the presence of all essential files
2. `test_compilation_thebibliography` - compiles all variants with `thebibliography`
3. `test_compilation_bibtex` - compiles all variants with BibTeX
4. `test_compilation_biblatex` - compiles all variants with BibLaTeX / Biber
5. `test_latex_warnings` - detects and reports common LaTeX warnings

### Test Prerequisites

For compilation tests, you need:
- A LaTeX distribution (TeX Live, MiKTeX, or MacTeX)
- `pdflatex` available in `PATH`
- `bibtex` for BibTeX tests
- `biber` for BibLaTeX tests
- `make`

**Note:** `test_required_files` works even without LaTeX installed.

### Complete Documentation

For detailed test-suite documentation, including:
- Test architecture
- CI/CD integration
- How to add new tests
- Troubleshooting
- Best practices

See [`tests/README.md`](tests/README.md).

### CI/CD Integration

The test suite is designed for CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Run LaTeX Template Tests
  run: bash tests/run_all_tests.sh
```

**Exit codes:**
- `0` - All tests passed (safe to deploy)
- `1` - Some tests failed (block deployment)
