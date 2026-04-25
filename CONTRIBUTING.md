# Contributing

Thanks for helping improve this LaTeX template. The goal is to keep the repository easy to clone, customize, and validate across its supported variants.

## Workflow

1. Fork the repository.
2. Create a focused branch for your change.
3. Make the smallest change that solves the problem.
4. Run the validation command below.
5. Open a pull request with a short explanation of what changed and why.

## Before Opening a Pull Request

Run the full test suite from the repository root:

```bash
bash tests/run_all_tests.sh
```

This mirrors the CI-oriented validation flow and checks the template structure, scripts, bibliography paths, and compilation scenarios.

If your change is intentionally limited and you cannot run the full suite, mention that in the pull request and include the command you did run, such as:

```bash
make compile MAIN_FILE=paper-main
make bib MAIN_FILE=monograph-main
make ENGINE=xelatex compile MAIN_FILE=thesis-main
```

## Keep Changes Variant-Aware

The repository supports three active variants:

- `paper`
- `monograph`
- `thesis`

Changes to shared configuration, bibliography behavior, scripts, Makefile targets, or directory layout may affect more than one variant. When possible, check the relevant variant files before opening a pull request.

## Bibliography and Engine Compatibility

Please consider whether your change affects the supported bibliography backends:

- `thebibliography`
- `bibtex`
- `biblatex` / Biber

Also consider the supported LaTeX engines when changing packages, compiler flags, or generated files:

- `pdflatex`
- `xelatex`
- `lualatex`

Not every small documentation change needs a full compatibility matrix, but build-related changes should explain what was tested.

## Documentation Alignment

If a change affects setup, build commands, script options, bibliography behavior, variant selection, or expected output, update the relevant documentation in the same pull request. Common places to check are:

- `README.md`
- `tests/README.md`
- `docs/`
- script `--help` output, when applicable

Keep documentation practical and specific to this template.

