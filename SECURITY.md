# Security Policy

This repository is a LaTeX template, not a hosted service, but security-sensitive reports are still welcome.

## Reporting a Vulnerability

Please do not open a public issue for a security-sensitive report. Use GitHub's private security advisory flow:

https://github.com/ThalesMMS/LaTeX-Paper-Template/security/advisories/new

## What Belongs Here

Security reports may include:

- unsafe behavior in shell scripts such as `init-project.sh` or `quick-start.sh`
- CI workflow issues that could expose secrets or execute untrusted input unsafely
- dependency or toolchain concerns that create a meaningful risk for template users

Regular LaTeX build failures, missing packages, formatting differences, or template usage questions should be filed as normal GitHub issues instead.

## Supported Versions

**Supported branches:** Security fixes are considered for the default branch and the latest tagged release, once releases are available. Before the first tagged release, reports should identify the affected commit or branch.

**EOL policy:** Older branches, forks, and untagged snapshots are considered end-of-life unless the maintainer explicitly marks them as supported. Fixes are normally applied to the default branch first; backports are best-effort and depend on severity, compatibility risk, and maintainer availability.

**How to report your version:** Include the affected branch, tag, or commit SHA in the private advisory. If the issue depends on a TeX distribution, shell version, operating system, or CI environment, include those details too. The maintainer will confirm whether the reported version is in scope or explain if the issue is out of scope for this repository.

## Response and Disclosure

The maintainer will try to acknowledge valid private reports within a few business days. Fix timing depends on severity and maintainer availability.

If a fix is needed, disclosure should happen after a patch or mitigation is available. For low-risk template issues, the advisory may be closed with an explanation instead of a formal release.
