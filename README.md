# Lab@Home

This is the generator for my personal website.

## Further Information

Test the [hugo-book](https://github.com/alex-shpak/hugo-book) theme

Here is how I got MathJax to work: https://geoffruddock.com/math-typesetting-in-hugo/

Here is how this website is automatically being built using GitHub Actions: https://gohugo.io/hosting-and-deployment/hosting-on-github/

private content: https://reverse.put.as/2021/03/11/hugo-githubactions/

https://github.community/t/triggering-by-other-repository/16163/9

https://github.com/actions/github-script#using-a-separate-github-token

https://octokit.github.io/rest.js/v18#actions-create-workflow-dispatch

## Random Notes

* need to setup Personal Access Token to have -content repo access this repo
  --> register in -content repo as SECRET_...
* on first lauch: enable GitHub Pages in this repo's settings (branch gh-pages, folder '/')

## Markdown character convention

There are two rules, depending on the file:

- **`.en.md`, `README.md`, `CLAUDE.md`, and any other English Markdown**: 7-bit
  ASCII only. Use the replacements in the table below.
- **`.de.md` (German content)**: German umlauts (a-/o-/u-umlaut, capitals,
  sharp s -- U+00E4/F6/FC/C4/D6/DC/DF) **and** the degree sign U+00B0 are
  allowed, since they match standard German typography. Everything else from
  the table below should still be replaced.

Replacement table (apply universally except for the two carve-outs above):

| Original (codepoint)                  | ASCII replacement |
|---------------------------------------|-------------------|
| German umlauts + sharp s (U+00C4/D6/DC/DF/E4/F6/FC) | `Ae`/`Oe`/`Ue`/`ss`/`ae`/`oe`/`ue` -- in `.en.md` only; keep as-is in `.de.md` |
| degree sign (U+00B0)                  | `deg` (e.g. `45 deg`, `30 degC`) -- in `.en.md` only; keep as-is in `.de.md` |
| em dash (U+2014)                      | `--`              |
| en dash (U+2013)                      | `-`               |
| minus sign (U+2212)                   | `-`               |
| ellipsis (U+2026)                     | `...`             |
| multiplication sign (U+00D7)          | `x`               |
| middle dot (U+00B7)                   | `*`               |
| superscripts 2, 3 (U+00B2, U+00B3)    | `^2`, `^3`        |
| plus-minus (U+00B1)                   | `+/-`             |
| approx, le, ge (U+2248, U+2264, U+2265) | `~`, `<=`, `>=` |
| micro (U+00B5)                        | `u` (e.g. `5 um`) |
| diameter sign (U+00F8)                | `dia`             |
| capital omega (U+03A9)                | `ohm`             |
| Greek pi, theta, zeta (U+03C0, U+03B8, U+03B6) | `pi`, `theta`, `zeta` |
| arrows (U+2192, U+2190, U+2194)       | `->`, `<-`, `<->` |
| euro (U+20AC)                         | `EUR`             |
| registered sign (U+00AE)              | `(R)`             |
| curly single quotes (U+2018, U+2019)  | `'`               |
| curly double quotes (U+201C, U+201D)  | `"`               |

Math inside `<tex>$...$</tex>` blocks uses LaTeX commands (`\pi`, `\Omega`,
`\cdot`, etc.) -- MathJax renders those into proper Greek/math symbols at
runtime, so the source stays ASCII either way.

To audit the working tree:

```sh
# English files and root docs: must be pure ASCII
LC_ALL=C grep -rPn '[^\x00-\x7F]' $(find content -name '*.en.md') README.md CLAUDE.md

# German files: list all non-ASCII chars; only umlauts (ae/oe/ue/Ae/Oe/Ue/ss)
# and the degree sign should appear -- anything else means a stray char.
python3 -c "
import sys, glob
ok = set(range(128)) | {0x00C4, 0x00D6, 0x00DC, 0x00DF, 0x00E4, 0x00F6, 0x00FC, 0x00B0}
for f in glob.glob('content/**/*.de.md', recursive=True) + glob.glob('content/*.de.md'):
    for ln, line in enumerate(open(f, encoding='utf-8'), 1):
        for c in line:
            if ord(c) not in ok:
                print(f'{f}:{ln}: U+{ord(c):04X} ({c!r})')
                break
"
```
