# Release Checklist

This checklist defines the minimum validation and reproducibility evidence for
publishing a template snapshot.

## Pre-release validation

Before creating a tag or GitHub Release, complete these checks:

- Run the full test suite and confirm all tests pass:

  ```bash
  bash tests/run_all_tests.sh
  ```

- Confirm all three document variants compile:
  - `paper-main.tex`
  - `monograph-main.tex`
  - `thesis-main.tex`

- Confirm both external bibliography backends pass validation:
  - BibTeX
  - BibLaTeX/Biber

- Confirm the default `thebibliography` path still compiles through the full
  test suite.

- If template structure, scripts, configuration files, bibliography defaults, or
  examples changed, review `README.md` and the example content before release.

## Reproducibility bundle

Record this information in the GitHub Release notes for each release:

- Release version and tag name.
- Commit SHA for the tagged release.
- CI workflow run link or documented fallback (see below).
- Toolchain baseline from CI or the validated release environment:
  - TeX Live version.
  - `pdflatex --version`.
  - `bibtex --version`.
  - `biber --version`.
  - Runner operating system.
- Validation summary, including whether the full test suite passed and whether
  all three variants and bibliography backends were covered.

Sample output PDFs are not required release artifacts. If sample PDFs, hashes,
or logs are preserved, summarize them in the release notes; otherwise include
short log excerpts or CI references that show the validation result.

### Fallback for CI outage

If CI is unavailable, archive a fallback validation bundle alongside the release
and note it in the release notes. The bundle must include:

- A tarball of the validated environment.
- Captured outputs of `pdflatex --version`, `bibtex --version`, and
  `biber --version`.
- Operating system information for the validated environment.
- The exact CI-equivalent commands used locally and their invocation logs.
- A validation summary confirming whether the full test suite passed and whether
  all three variants and bibliography backends were covered.
- A signed attestation by the releaser explaining why CI was unavailable.
- A SHA256 checksum of the archived bundle.

## GitHub release process

1. Update `CHANGELOG.md` for the release version.
2. Run the pre-release validation checklist.
3. Record the reproducibility bundle.
4. Create an annotated git tag matching the version. Replace `<version>` with
   the actual release tag, such as `vX.Y.Z`:

   ```bash
   git tag -a <version> -m "Release <version>"
   ```

5. Push the tag to GitHub:

   ```bash
   git push origin <version>
   ```

6. Create a GitHub Release from the tag.
7. In the release notes, summarize the changes and include the validation
   evidence from the reproducibility bundle.

## Version increments

Use `vMAJOR.MINOR.PATCH` tags.

- Increment `PATCH` for fixes that preserve the documented template structure
  and user workflow.
- Increment `MINOR` for new features, variants, scripts, examples, or validation
  coverage that remain backward-compatible.
- Increment `MAJOR` for breaking changes to template structure, script
  behavior, build commands, required tooling, or documented user workflows.
