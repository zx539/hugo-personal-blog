---
name: hugo-personal-blog
description: Build, redesign, maintain, and deploy modular Hugo personal blogs with Markdown content, responsive UI, image/video assets, interactive effects, and GitHub Pages workflows. Use when Codex needs to create a Hugo blog, customize layouts or anime/editorial themes, add posts and profile data, implement Goldmark render hooks, fix baseURL or subpath asset bugs, add GitHub Actions deployment, or verify desktop/mobile rendering.
---

# Hugo Personal Blog

Build or modify a Hugo blog as a maintainable content system, not a one-off HTML page. Preserve the repository's existing patterns when working in an established site.

## Workflow

1. Inspect the repository before editing:
   - Read `hugo.toml`, `.github/workflows/`, `layouts/`, `data/`, `content/`, `assets/`, `static/`, and `.gitignore`.
   - Check `git status` and do not overwrite unrelated user changes.
   - Locate supplied visual references and inspect their dimensions/content.
2. Establish the content contracts:
   - Keep profile, projects, skills, links, and reusable labels in `data/*.yaml`.
   - Keep articles in `content/posts/*.md`.
   - Keep render logic in partials and `_markup` hooks.
   - Keep source media under `static/images/`, `static/media/`, or page bundles.
3. Implement the smallest coherent layout change:
   - Use partials for independently maintained regions.
   - Keep responsive behavior explicit at desktop, tablet, and mobile widths.
   - Preserve accessible labels, reduced-motion behavior, and keyboard navigation.
4. Make Markdown complete:
   - Enable Goldmark tables, task lists, footnotes, definition lists, typographer, and heading IDs.
   - Style headings, paragraphs, lists, blockquotes, code, tables, images, footnotes, and pagination.
   - Add render hooks for headings, images, and links when GitHub Pages subpaths matter.
5. Make GitHub Pages paths safe:
   - End `baseURL` with `/`.
   - Use `relURL` or `.RelPermalink`; do not hard-code root-relative internal paths.
   - Strip a leading `/` in Markdown render hooks before applying `relURL`.
6. Add media carefully:
   - Use `autoplay muted loop playsinline` for decorative background video.
   - Include a poster/fallback and a pause control.
   - Compress images to WebP where practical and avoid duplicate source assets in Git.
7. Verify before finishing:
   - Run `scripts/check_hugo_blog.sh <repo>`.
   - Build with `hugo --gc --minify --cleanDestinationDir --panicOnWarning`.
   - Inspect generated HTML for `/MyBlog/`-style subpaths.
   - Use browser screenshots at desktop and mobile sizes for user-facing layout changes.
   - For video, compare screenshots from different timestamps or inspect playback state.
8. Deploy:
   - Publish generated `public/` to `gh-pages` from GitHub Actions.
   - Keep Pages configured as `Deploy from a branch`, `gh-pages`, `/ (root)` when using this workflow.

## Decision Rules

- Prefer data files over hard-coded personal content.
- Prefer Hugo render hooks over post-processing generated HTML.
- Do not commit `public/` when Actions builds it.
- Do not install a theme if the site already owns custom layouts.
- Do not hide failed media loads behind blank overlays; provide a visible fallback.
- Keep operational blog interfaces dense and readable; reserve immersive visuals for the cover/background.
- Respect `prefers-reduced-motion` for all nonessential motion.

## References

Read [references/hugo-blog-reference.md](references/hugo-blog-reference.md) when adding modules, writing front matter, configuring Markdown, working with GitHub Pages paths, or diagnosing build/deployment failures.

## Validation

Run:

```bash
bash skills/hugo-personal-blog/scripts/check_hugo_blog.sh .
```

Treat any failed build, missing required file, absolute `/images/` output, or missing workflow path as incomplete work.
