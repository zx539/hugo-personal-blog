# Hugo Blog Reference

## Contents

1. Recommended structure
2. Data contracts
3. Article front matter
4. Markdown configuration
5. GitHub Pages path handling
6. Media, avatars, and interaction
7. Reading performance and styling
8. Deployment workflow
9. Verification and troubleshooting

## 1. Recommended Structure

```text
.
├── assets/css/main.css
├── content/
│   ├── about.md
│   └── posts/*.md
├── data/
│   ├── profile.yaml
│   ├── friends.yaml
│   └── daily.yaml
├── layouts/
│   ├── _default/{baseof,list,single}.html
│   ├── _default/_markup/{render-heading,render-image,render-link}.html
│   └── partials/*.html
├── static/
│   ├── images/
│   ├── media/
│   └── files/
├── .github/workflows/hugo.yml
└── hugo.toml
```

Treat `data/`, `content/`, and `static/` as author-facing interfaces. Treat `layouts/` and `assets/` as implementation.

## 2. Data Contracts

Profile example:

```yaml
name: Display Name
role: Developer / Writer
tagline: A short signature.
location: City / School
email: person@example.com
avatar: images/profile.webp
hero_art: images/hero.webp
highlights:
  - AI Agent
skills:
  - Python
projects:
  - title: Project
    period: 2026 - present
    role: Lead
    summary: What it does.
    outcomes:
      - Result
```

Friend link example:

```yaml
- name: Site Name
  url: https://example.com/
  avatar: images/friends/example.webp
  description: Short description.
  tag: Blog
```

Store friend avatars under `static/images/friends/`, preferably as square 96x96 WebP files. Render them at stable dimensions with `object-fit: cover`; if `avatar` is absent, show the site's first character rather than a broken image.

Use the profile avatar in the navigation when requested. Generate dedicated 96x96 favicon and 180x180 touch-icon files from it, then declare both in `<head>` using `relURL`.

Daily image example:

```yaml
label: DAILY · 01
image: images/daily/view.webp
alt: Meaningful image description
caption: Short caption.
```

## 3. Article Front Matter

```markdown
---
title: "Article title"
date: 2026-07-14
tags: ["Hugo", "Markdown"]
summary: "Card and header summary with **inline Markdown**."
draft: false
---

## First section

Content.
```

Render summary with `markdownify` when inline Markdown is allowed. Keep drafts out of production builds.

## 4. Markdown Configuration

Recommended `hugo.toml` settings:

```toml
[markup]
  [markup.goldmark]
    [markup.goldmark.parser]
      autoHeadingID = true
      autoHeadingIDType = "github"
    [markup.goldmark.extensions]
      definitionList = true
      footnote = true
      linkify = true
      strikethrough = true
      table = true
      taskList = true
      typographer = true
  [markup.highlight]
    codeFences = true
    noClasses = false
```

Style and test:

- `h2`-`h6` and heading anchors
- paragraphs, ordered/unordered/task lists
- definition lists
- blockquotes
- inline code, fenced code, syntax highlight, copy control
- tables with horizontal overflow
- images and captions
- links and external-link behavior
- footnotes
- horizontal rules and keyboard tags

For list styling, test loose list items that contain `<p>`, nested lists, and task-list checkboxes. Custom `::marker { content: ... }` is inconsistent across browsers; prefer native markers or an absolutely positioned `li::before`, and suppress that decoration for task items. Reduce margins on direct child paragraphs so loose Markdown lists do not produce blank-looking gaps.

Use a moderate component radius (for example 6-8px) where the design calls for softer Markdown panels. Give `pre`, `.highlight`, and horizontally scrolling tables a 5-7px scrollbar with distinct track/thumb colors and a hover state.

## 5. GitHub Pages Path Handling

Choose the site type before setting `baseURL`.

User site (repository must be named `USER.github.io`):

```toml
baseURL = "https://USER.github.io/"
```

Project site:

```toml
baseURL = "https://USER.github.io/REPO/"
```

Template paths:

```go-html-template
<a href="{{ "posts/" | relURL }}">Posts</a>
<img src="{{ .Site.Data.profile.avatar | relURL }}" alt="">
```

Markdown image hook:

```go-html-template
{{- $destination := .Destination -}}
{{- if not (or (strings.HasPrefix $destination "http://") (strings.HasPrefix $destination "https://")) -}}
  {{- $destination = strings.TrimPrefix "/" $destination -}}
  {{- $destination = $destination | relURL -}}
{{- end -}}
```

This supports both `images/x.webp` and `/images/x.webp` in Markdown without losing the repository subpath.

Root-relative output such as `/images/x.webp` is valid for a user site but wrong for a project site. Validation must compare links with the path component of `baseURL`; never reject all root-relative URLs unconditionally.

## 6. Media, Avatars, and Interaction

Decorative video:

```html
<video autoplay muted loop playsinline preload="metadata" poster="fallback.webp">
  <source src="background.mp4" type="video/mp4">
</video>
```

Requirements:

- Keep decorative video muted.
- Provide play/pause control.
- Use a static poster and readable overlay.
- Prefer H.264 MP4 for compatibility.
- Target a small file; 1-5MB is reasonable for short loops.
- Disable or replace motion under `prefers-reduced-motion`.
- On article and other reading pages, prefer `preload="none"` without autoplay so the poster appears immediately and video decoding does not compete with scrolling.

For interactive visual effects, use pointer events and append short-lived DOM nodes. Throttle pointer-move effects and remove nodes on `animationend`.

## 7. Reading Performance and Styling

- Do not stack full-viewport video, multiple `backdrop-filter` layers, and continuous particles behind long articles.
- Remove backdrop blur from article surfaces; use opaque or translucent static colors instead.
- Coalesce scroll progress work with `requestAnimationFrame` and passive listeners.
- Keep fixed controls and progress indicators transform-based to avoid layout work.
- Preserve fixed dimensions for avatars, icons, copy buttons, and scrollbars.
- Validate that Markdown headings, lists, code, tables, images, and footnotes do not overflow at mobile widths.

## 8. Deployment Workflow

Typical `peaceiris/actions-gh-pages` build:

```yaml
permissions:
  contents: write

steps:
  - uses: actions/checkout@v4
  - uses: peaceiris/actions-hugo@v3
    with:
      hugo-version: latest
      extended: true
  - run: hugo --gc --minify --cleanDestinationDir --baseURL "https://USER.github.io/REPO/"
  - uses: peaceiris/actions-gh-pages@v4
    with:
      github_token: ${{ secrets.GITHUB_TOKEN }}
      publish_dir: ./public
      publish_branch: gh-pages
```

GitHub Pages setting: source `Deploy from a branch`, branch `gh-pages`, folder `/ (root)`.

For a user site, change both the repository name and workflow URL:

```text
repository: USER/USER.github.io
baseURL: https://USER.github.io/
```

## 9. Verification and Troubleshooting

Build gate:

```bash
hugo --gc --minify --cleanDestinationDir --panicOnWarning
```

Check generated paths against `baseURL`. For a project site, root-level asset and post paths usually indicate a missing repository prefix:

```bash
rg -n 'src=/images|href=/posts' public
```

Common failures:

- `module "" not found`: remove an empty `theme = ""` entry or install the named theme.
- GitHub Pages shows README: Pages points at the source branch instead of deployed `gh-pages` output.
- Images work locally but not online: root-relative URLs dropped the repository subpath.
- Old pages remain: build with `--cleanDestinationDir` and deploy the clean output.
- Video is blank: verify MP4 codec, muted autoplay attributes, MIME path, poster, and HTTP 200 response.
- Markdown features look raw: verify Goldmark extensions, render hooks, and `.article-body` styles.
- Markdown list has blank-looking gaps: inspect generated loose-list `<p>` nodes, nested-list margins, task-list decoration, and custom marker compatibility.
- Article scrolling is janky: stop article-page autoplay, remove backdrop blur from reading surfaces, and batch scroll updates with `requestAnimationFrame`.

For visual changes, capture desktop and mobile screenshots and inspect text overflow, media framing, card overlap, and fixed controls.
