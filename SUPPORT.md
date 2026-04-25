# Support

Use GitHub Issues for both usage questions and bug reports. If GitHub Discussions are enabled for the repository, general usage questions may go there instead.

## Usage Questions

Open an issue when you need help choosing a variant, configuring bibliography, understanding a build command, or adapting the template to your project.

Before opening a question, check:

- `README.md`
- `tests/README.md`
- `output/build.log`, if a build failed

## Bug Reports

Use the bug report template when the template, scripts, or documented commands do not behave as expected.

For LaTeX or build failures, include:

- template variant: `paper`, `monograph`, or `thesis`
- bibliography backend: `thebibliography`, `bibtex`, or `biblatex`
- TeX engine: `pdflatex`, `xelatex`, or `lualatex`
- operating system and TeX distribution, if known
- the exact command that failed
- clear reproduction steps
- the relevant log excerpt from `output/build.log`
- whether the issue reproduces on an unmodified copy of the template

Checking an unmodified copy helps separate template bugs from project-specific edits.

## Self-Diagnostic Test

If you are comfortable running the test suite, this command is useful context for maintainers:

```bash
bash tests/run_all_tests.sh
```

Include the failing test name or a short output excerpt when it helps explain the issue.

