# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Hugo static site for `labathome.de` (Jonathan Schilling's personal site), built with the `hugo-book` theme and deployed to GitHub Pages. There is no application code here -- the repo is content (Markdown under `content/`), Hugo configuration (`config.toml`), one Hugo template override (`layouts/partials/`), and a CI workflow.

## Common commands

The theme is a git submodule. After a fresh clone:

```bash
git submodule update --init --recursive
```

Local development (drafts included, matches CI):

```bash
hugo server -D
```

One-off build (mirrors the CI build step):

```bash
hugo -D
```

Hugo **Extended** is required (see `.github/workflows/deploy.yml`). The CI build also renames `public/index.xml` to `.disabled` after building -- site-wide RSS is intentionally suppressed.

Create a new content page:

```bash
hugo new <section>/<slug>/_index.md   # uses archetypes/default.md (draft: true)
```

## Deployment flow

`.github/workflows/deploy.yml` runs Hugo and pushes the result to the `gh-pages` branch on every push to `master`. That's all -- no separate content repo is in the loop today.

The README mentions a `*-content` sibling repo and there's a vestigial workflow at `content/.github/workflows/trigger_deploy.yml`, but neither is wired up: `content/` is a plain directory in this repo (not a submodule, not a checkout) and recent prose commits land here directly. Treat the trigger file and the README's PAT/SECRET notes as historical -- safe to ignore unless you're intentionally re-introducing a split-repo setup.

## MathJax convention

MathJax is opt-in per page, not site-wide:

1. Add `mathjax: true` to the page's front matter.
2. `layouts/partials/docs/html-head.html` overrides the theme's `html-head` partial and conditionally pulls in `layouts/partials/mathjax_support.html`, which loads MathJax 3 from jsdelivr.
3. Wrap math in `<tex>` tags so the custom CSS in `css/custom.css` (`tex.has-jax { ... }`) can strip the inherited `<code>`-style background:
   - inline: `<tex>$E = mc^2$</tex>`
   - display: `<tex>$$ ... $$</tex>`

When editing or adding math content, follow this convention -- bare `$...$` will render but won't be styled correctly.

The `<tex>` wrappers are raw HTML, so `[markup.goldmark.renderer] unsafe = true` is required in `config.toml` -- otherwise modern Hugo strips them at render time and MathJax has nothing to typeset.

## Theme overrides (why they exist)

The `hugo-book` submodule is pinned at v9 (its latest tag, last touched in 2022) and hasn't been updated for Hugo's modern API. A few overrides under `layouts/` work around this -- leave them in place when bumping the submodule (if a newer release ever lands, you can re-evaluate):

- `layouts/partials/docs/html-head.html` -- replaces theme's call to the removed `_internal/google_analytics_async.html` (no GA on this site) and uses `css.Sass` instead of the removed `resources.ToCSS` for SCSS compilation. Also conditionally loads `mathjax_support.html`.
- `layouts/partials/docs/footer.html` -- replaces theme's `.Site.IsMultiLingual` (removed) with `hugo.IsMultilingual`.
- `layouts/404.html` -- copy of the theme's 404 page minus the GA template call.

If/when the theme is updated upstream to use modern Hugo APIs, these overrides can be deleted.

## Content structure

`content/` is organised by topic (`elektrotechnik`, `maschinenbau`, `numerics`, `physics`), each with an `_index` that sets `bookCollapseSection: true` and a `weight` to control sidebar ordering. See "Bilingual setup" below for how each page is split across languages.

**Character convention.** Every Markdown file is 7-bit ASCII plus the degree sign `°` (U+00B0), which is allowed everywhere because it's the conventional notation for angles and temperatures. `.de.md` files additionally keep the German umlauts and sharp s (U+00C4/D6/DC/DF/E4/F6/FC) since they match standard German typography. Everything else (em dash, ellipsis, superscripts, Greek letters, arrows, ...) is replaced with its ASCII equivalent in every file. The full substitution table and audit script are in `README.md` ("Markdown character convention"). Math inside `<tex>$...$</tex>` blocks uses LaTeX commands (`\pi`, `\Omega`, `\cdot`) so MathJax renders the actual symbols at runtime regardless.

`enableGitInfo = true` in `config.toml`, so the theme renders "Last Modified" links -- be aware that file mtimes / git history are user-visible on the rendered site.

## Bilingual setup

Site is configured for English (default, no URL prefix) and German (under `/de/...`) via Hugo's standard multilingual mode. The `[languages]` block lives in `config.toml`. The `hugo-book` theme auto-renders a language switcher in the header once languages are configured -- no template changes needed.

**File-suffix translation.** Every page bundle has two files: `_index.en.md` (or `about.en.md` at the root) and `_index.de.md`. Page-bundle assets (images, PDFs, zips) sit alongside both and are language-agnostic. Never use a bare `_index.md` -- Hugo would treat it as the default-language file and confuse the bilingual setup.

**English-only pages keep an `.de.md` copy.** `_index.md`, `about.md`, `numerics/fftw_tutorial`, and `physics/TVP250` are English-only by design. Their `.de.md` is intentionally a literal copy of the `.en.md` so the page appears in the German sidebar and serves the English body when clicked. Don't "fix" this by deleting the `.de.md` or auto-translating it -- that's the requested fallback behavior.

**Pending translations.** A new `.en.md` whose body is just `<!-- TODO: paste DeepL English translation here -->` is awaiting translation. The workflow: paste the German body from the matching `.de.md` into DeepL's web UI (https://www.deepl.com/translator -- 5,000-char paste limit, so split long pages), write the English output below the marker, then remove the marker. Preserve Markdown structure, code blocks, image references, and `<tex>$...$</tex>` math blocks unchanged.
