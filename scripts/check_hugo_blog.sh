#!/usr/bin/env bash
set -euo pipefail

repo="${1:-.}"
cd "$repo"

required=(
  hugo.toml
  content/posts
  layouts/_default/baseof.html
  layouts/_default/list.html
  layouts/_default/single.html
  assets/css/main.css
)

for path in "${required[@]}"; do
  if [[ ! -e "$path" ]]; then
    printf 'FAIL missing %s\n' "$path" >&2
    exit 1
  fi
done

if ! command -v hugo >/dev/null 2>&1; then
  printf 'FAIL hugo is not installed\n' >&2
  exit 1
fi

hugo --gc --minify --cleanDestinationDir --panicOnWarning

if [[ ! -f public/index.html ]]; then
  printf 'FAIL Hugo did not generate public/index.html\n' >&2
  exit 1
fi

if rg -n 'src=/images/|href=/posts/' public --glob '*.html' >/dev/null; then
  printf 'FAIL root-relative project assets found in generated HTML\n' >&2
  rg -n 'src=/images/|href=/posts/' public --glob '*.html' >&2
  exit 1
fi

if [[ -f .github/workflows/hugo.yml ]] && ! rg -q 'cleanDestinationDir' .github/workflows/hugo.yml; then
  printf 'WARN workflow does not use --cleanDestinationDir\n' >&2
fi

printf 'PASS Hugo blog build and path checks\n'
