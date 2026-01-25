# LaTeX Template Test Suite

Comprehensive test suite for validating the LaTeX Paper/Monograph/Thesis template. Ensures all template variants compile correctly, required files exist, and LaTeX warnings are properly handled.

---

## Quick Start

### Run All Tests
```bash
bash tests/run_all_tests.sh
```

### Run Specific Test
```bash
bash tests/run_all_tests.sh --test required_files
bash tests/run_all_tests.sh --test compilation_bibtex
```

### List Available Tests
```bash
bash tests/run_all_tests.sh --list
```

---

## Test Coverage

The test suite validates all critical aspects of the LaTeX template:

### 1. **Required Files Test** (`test_required_files.sh`)
Validates presence and structure of essential template files:

- ✅ Main LaTeX files (paper-main.tex, monograph-main.tex, thesis-main.tex)
- ✅ Configuration files (config/*.tex)
- ✅ Chapter files (chapters/*.tex)
- ✅ Section files (sections/*.tex)
- ✅ Bibliography files (bibliography/*.tex, *.bib, *.bst)
- ✅ Build system (Makefile, init-project.sh, quick-start.sh)
- ✅ Asset files (template images)

**Purpose:** Ensures template integrity after cloning/download

### 2. **Compilation Tests** (`test_compilation_*.sh`)
Tests PDF compilation for all three bibliography backends:

#### a. `test_compilation_thebibliography.sh`
- Tests all three variants (paper, monograph, thesis)
- Uses built-in `thebibliography` environment
- Validates PDF output generation
- Checks for compilation errors

#### b. `test_compilation_bibtex.sh`
- Tests all three variants with BibTeX
- Validates `.bib` file processing
- Runs full BibTeX workflow (pdflatex → bibtex → pdflatex × 2)
- Checks bibliography integration

#### c. `test_compilation_biblatex.sh`
- Tests all three variants with BibLaTeX/Biber
- Modern bibliography backend
- Runs full BibLaTeX workflow (pdflatex → biber → pdflatex × 2)
- Validates advanced citation features

**Purpose:** Ensures all variants compile successfully with different bibliography backends

### 3. **LaTeX Warnings Test** (`test_latex_warnings.sh`)
Validates LaTeX warning detection and reporting:

- ✅ Detects undefined references
- ✅ Detects citation warnings
- ✅ Detects overfull/underfull hbox warnings
- ✅ Detects missing figure warnings
- ✅ Detects font warnings
- ✅ Provides actionable error messages
- ✅ Tests all three variants

**Purpose:** Helps users identify and fix common LaTeX issues

### 4. **Validation Scripts** (`validate-*.sh`)
End-to-end validation scripts for project infrastructure:

- `validate-init-project.sh` - Validates the init-project.sh CLI tool
- `validate-makefile-targets.sh` - Tests all Makefile targets
- `validate-monograph-variant.sh` - E2E tests for monograph variant
- `validate-thesis-variant.sh` - E2E tests for thesis variant
- `validate-quick-start-e2e.sh` - Full E2E workflow for quick-start.sh

**Purpose:** Comprehensive validation of project tooling and workflows

---

## Test Architecture

### Master Test Runner
`run_all_tests.sh` orchestrates all tests:

1. **Auto-discovery:** Finds all `test_*.sh` scripts in `tests/`
2. **Execution:** Runs tests in isolated environments
3. **Aggregation:** Collects pass/fail results
4. **Reporting:** Displays comprehensive summary

**Key Features:**
- Parallel test execution support
- Verbose mode for debugging
- Filter by test name
- Exit code 0 (pass) or 1 (fail) for CI/CD

### Test Helper Library
`test_helpers.sh` provides reusable utilities:

- **Color-coded output:** Green (✓), Red (✗), Yellow (⚠), Blue (info)
- **Test counters:** Automatic pass/fail/warning tracking
- **Assertion functions:**
  - `check_file()` - Verify file exists
  - `check_dir()` - Verify directory exists
  - `check_pattern()` - Verify pattern in file
- **Summary functions:**
  - `print_test_summary()` - Display results
  - `print_success()` / `print_failure()` - Status banners

**Benefits:**
- Consistent test formatting
- Reusable test logic
- Easy maintenance

---

## Running Tests Locally

### Prerequisites
To run compilation tests, you need:
- LaTeX distribution (TeX Live, MiKTeX, or MacTeX)
- `pdflatex` command available in PATH
- `bibtex` for BibTeX tests
- `biber` for BibLaTeX tests
- `make` utility

**Note:** Required files test runs without LaTeX installation

### Environment Setup
Tests run from the **project root directory**:

```bash
cd /path/to/LaTeX-Paper-Template
bash tests/run_all_tests.sh
```

**Important:** Do NOT run tests from inside the `tests/` directory

### Test Isolation
Each compilation test:
1. Creates temporary output directories
2. Runs compilation in isolation
3. Cleans up after completion
4. Does NOT modify source files

---

## Command-Line Options

### `run_all_tests.sh` Options

| Option | Description | Example |
|--------|-------------|---------|
| `--help`, `-h` | Show help message | `bash tests/run_all_tests.sh --help` |
| `--version` | Show version | `bash tests/run_all_tests.sh --version` |
| `--verbose`, `-v` | Enable verbose output | `bash tests/run_all_tests.sh --verbose` |
| `--test NAME` | Run specific test | `bash tests/run_all_tests.sh --test required_files` |
| `--list` | List available tests | `bash tests/run_all_tests.sh --list` |

### Individual Test Options

Each `test_*.sh` script can be run independently:

```bash
bash tests/test_required_files.sh
bash tests/test_compilation_bibtex.sh
bash tests/test_latex_warnings.sh
```

---

## Understanding Test Output

### Success Output
```
===================================================================
LATEX TEMPLATE TEST SUITE
===================================================================

Project Directory: /path/to/LaTeX-Paper-Template
Tests Directory: /path/to/LaTeX-Paper-Template/tests

===================================================================
Running: required_files
===================================================================

✓ Core LaTeX file exists: paper-main.tex
✓ Core LaTeX file exists: monograph-main.tex
✓ Core LaTeX file exists: thesis-main.tex
...

===================================================================
VALIDATION SUMMARY
===================================================================

Tests run:    42
Tests passed: 42
Errors:       0
Warnings:     0

✓ required_files passed

===================================================================
FINAL TEST SUITE SUMMARY
===================================================================

Test scripts run: 5

==================================================================
✓ ALL TESTS PASSED
==================================================================

All validation tests completed successfully!

The LaTeX template has been validated:
  ✓ All required files present
  ✓ Compilation tests passed
  ✓ Warning detection works
```

### Failure Output
```
===================================================================
Running: compilation_bibtex
===================================================================

✗ Paper variant compilation failed: pdflatex exited with error
✗ PDF output not found: output/paper-main.pdf

===================================================================
VALIDATION SUMMARY
===================================================================

Tests run:    12
Tests passed: 10
Errors:       2
Warnings:     0

✗ compilation_bibtex failed

===================================================================
FINAL TEST SUITE SUMMARY
===================================================================

Test scripts run: 5

==================================================================
✗ SOME TESTS FAILED
==================================================================

Failed tests:
  ✗ compilation_bibtex

Review the output above for details
```

---

## CI/CD Integration

### GitHub Actions Example
```yaml
name: LaTeX Template Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install LaTeX
        run: |
          sudo apt-get update
          sudo apt-get install -y texlive-latex-base texlive-latex-extra texlive-bibtex-extra biber

      - name: Run Template Tests
        run: bash tests/run_all_tests.sh

      - name: Upload Test Logs
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: test-logs
          path: output/*.log
```

### Exit Codes
- `0` - All tests passed (safe to deploy)
- `1` - Some tests failed (block deployment)

---

## Troubleshooting

### Test Fails: "LaTeX not found"
**Problem:** `pdflatex` not in PATH

**Solution:**
```bash
# macOS
brew install --cask mactex-no-gui

# Ubuntu/Debian
sudo apt-get install texlive-latex-base texlive-latex-extra

# Fedora/RHEL
sudo dnf install texlive-scheme-medium
```

### Test Fails: "BibTeX not found"
**Problem:** `bibtex` command missing

**Solution:**
```bash
# Usually installed with LaTeX distribution
# If missing, install full TeX Live:
sudo apt-get install texlive-full  # Ubuntu
brew install --cask mactex          # macOS
```

### Test Fails: "Biber not found"
**Problem:** `biber` command missing (needed for BibLaTeX)

**Solution:**
```bash
sudo apt-get install biber          # Ubuntu
brew install biber                  # macOS (if using BasicTeX)
```

### Test Passes Locally, Fails in CI
**Problem:** Different LaTeX package versions

**Solution:**
- Pin LaTeX distribution version in CI
- Install all required packages explicitly
- Check `output/build.log` for missing packages

### Permission Denied
**Problem:** Test scripts not executable

**Solution:**
```bash
chmod +x tests/*.sh
```

---

## Extending the Test Suite

### Adding New Tests

1. **Create test script:**
```bash
touch tests/test_my_new_feature.sh
chmod +x tests/test_my_new_feature.sh
```

2. **Use standard template:**
```bash
#!/bin/bash
# =================================================================
# Test: My New Feature
# Tests: Brief description of what this tests
# =================================================================

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source helpers
source "${SCRIPT_DIR}/test_helpers.sh"

# Reset counters
reset_counters

# Run tests
echo "Testing my new feature..."

check_file "path/to/file.tex" "My feature file exists"
check_pattern "path/to/file.tex" "\\mycommand" "My command exists"

# Print summary
print_test_summary

# Exit with appropriate code
if [ $ERRORS -gt 0 ]; then
    exit 1
else
    exit 0
fi
```

3. **Run new test:**
```bash
bash tests/run_all_tests.sh --test my_new_feature
```

### Best Practices
- ✅ Use `test_helpers.sh` functions for consistency
- ✅ Reset counters at start with `reset_counters`
- ✅ Always print summary with `print_test_summary`
- ✅ Exit 0 on success, 1 on failure
- ✅ Add descriptive comments
- ✅ Test in isolation (no side effects)
- ✅ Clean up temporary files

---

## Test Maintenance

### When to Update Tests

1. **New Template Variant Added**
   - Add compilation test for new variant
   - Update `test_required_files.sh` to check new files

2. **New Configuration File Added**
   - Update `test_required_files.sh`
   - Add pattern checks if needed

3. **Bibliography Backend Changed**
   - Update relevant `test_compilation_*.sh`
   - Verify BibTeX/BibLaTeX workflows

4. **New LaTeX Package Added**
   - Add package existence check
   - Test compilation with new package

5. **Build System Changed**
   - Update `test_compilation_*.sh` to match new Makefile targets
   - Verify build output paths

### Regular Maintenance
- Run full test suite before releases
- Update test documentation when adding tests
- Review test coverage quarterly
- Keep CI/CD integration up to date

---

## Test Coverage Report

| Category | Tests | Coverage |
|----------|-------|----------|
| **File Structure** | 42 checks | 100% of required files |
| **Compilation** | 9 scenarios | All 3 variants × 3 backends |
| **Bibliography** | 6 backends | thebibliography, BibTeX, BibLaTeX |
| **Warnings** | 15 patterns | Common LaTeX warnings |
| **Build System** | 3 scripts | Makefile, init-project.sh, quick-start.sh |

**Total Test Count:** ~75 individual assertions

---

## Performance

### Execution Time (Typical)
- `test_required_files.sh`: ~2 seconds
- `test_compilation_thebibliography.sh`: ~15 seconds
- `test_compilation_bibtex.sh`: ~20 seconds
- `test_compilation_biblatex.sh`: ~25 seconds
- `test_latex_warnings.sh`: ~18 seconds

**Total:** ~80 seconds for full test suite

### Optimization Tips
- Run `--test NAME` for specific tests during development
- Use `--verbose` only for debugging (reduces output parsing time)
- Clean `output/` directory before running tests

---

## FAQ

**Q: Do I need to run tests before using the template?**
A: No, tests are for maintainers and CI/CD. Users can skip testing.

**Q: Can I run tests without LaTeX installed?**
A: Yes, `test_required_files.sh` works without LaTeX. Compilation tests require LaTeX.

**Q: Why do tests create `output/` directories?**
A: Tests need temporary space for compilation. Cleaned up automatically.

**Q: How do I run tests in parallel?**
A: Tests run sequentially by default. For parallel execution, run individual `test_*.sh` scripts in separate terminals.

**Q: What if a test fails but template works fine?**
A: Check `output/build.log` for details. The test might be outdated or environment-specific.

**Q: Can I use tests to validate my custom changes?**
A: Yes! Tests help catch breaking changes when customizing the template.

---

## Support

**Issues:** If tests fail unexpectedly, open an issue on GitHub with:
1. Test output (use `--verbose`)
2. Your LaTeX distribution (run `pdflatex --version`)
3. Operating system and version
4. Build log (`output/build.log`)

**Contributing:** See main project CONTRIBUTING.md for guidelines on adding tests.

---

## Version History

- **v1.0.0** (2026-01-25): Initial test suite release
  - Required files validation
  - Compilation tests (3 variants × 3 backends)
  - LaTeX warning detection
  - CI/CD integration
