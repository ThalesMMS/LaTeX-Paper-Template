# `sbc.bst` Provenance

`bibliography/sbc.bst` is a copy of the BibTeX `apalike` bibliography
style adapted for SBC use. The local difference noted in the style header is
that citation labels omit the comma before the year.

## Original `apalike` Notes

BibTeX `apalike` bibliography style, 24-Jan-88 version.

Adapted from the `alpha` style, version 0.99a, for BibTeX version 0.99a.
Copyright (C) 1988, all rights reserved.

Copying of the original file is allowed, provided that if you make any changes
at all you name it something other than `apalike.bst`. This restriction helps
ensure that all copies are identical. Differences between this style and
`alpha` are generally heralded by a `%`. The file `btxbst.doc` has the
documentation for `alpha.bst`.

This style should be used with the `apalike` LaTeX style (`apalike.sty`).
`\cite` commands come out like `(Jones, 1986)` in the text, but there are no
labels in the bibliography. Something like `(1986)` appears immediately after
the author. Author and editor names appear as last name, comma, initials. A
`year` field is required for every entry, and so is either an `author` field
(or, in some cases, an `editor` field) or a `key` field.

## Editorial Note From `apalike`

Many journals require a style like `apalike`, but the original author strongly
recommended using a style like `plain` instead when possible. Mary-Claire van
Leunen's *A Handbook for Scholars* (Knopf, 1979) argues that a style like
`plain` encourages better writing than one like `apalike`. The original note
also points out that an old argument against numbered references, namely that
additions or deletions required renumbering text references and the reference
list, does not apply in the same way when LaTeX manages numbering.

## History

- 15-sep-86: Original version by Susan King and Oren Patashnik.
- 10-nov-86: Truncated the `sort.key$` string to the correct length in
  `bib.sort.order` to eliminate an error message.
- 24-jan-88: Updated for BibTeX version 0.99a from `alpha.bst` 0.99a.
  `apalike` now sorts by author, then year, then title. This `apalike` version
  does not work with BibTeX 0.98i.
