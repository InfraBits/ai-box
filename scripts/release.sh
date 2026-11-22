#!/usr/bin/env bash
# Create a release: bump the image tag in entrypoint, commit, tag and push.
# Usage: scripts/release.sh [major|minor|patch]   (default: minor)
set -euo pipefail

bump=${1:-minor}
case "$bump" in
  major|minor|patch) ;;
  *) echo "Usage: $0 [major|minor|patch]" >&2; exit 1 ;;
esac

repo=$(cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo"

branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$branch" != "main" ]];
then
  echo "Must be on main (currently on $branch)" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]];
then
  echo "Working tree is not clean; commit or stash changes first" >&2
  exit 1
fi

git fetch origin main --tags
if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]];
then
  echo "main is not up to date with origin/main" >&2
  exit 1
fi

# Find the latest semantic version tag
latest=$(git tag --list 'v[0-9]*.[0-9]*.[0-9]*' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1 || true)
if [[ -z "$latest" ]];
then
  next="v1.0.0"
else
  IFS=. read -r major minor patch <<< "${latest#v}"
  case "$bump" in
    major) major=$((major + 1)); minor=0; patch=0 ;;
    minor) minor=$((minor + 1)); patch=0 ;;
    patch) patch=$((patch + 1)) ;;
  esac
  next="v${major}.${minor}.${patch}"
fi

if git rev-parse -q --verify "refs/tags/$next" > /dev/null;
then
  echo "Tag $next already exists" >&2
  exit 1
fi

echo "Releasing ${next} (previous: ${latest:-none})"

sed -E -i '' "s#(ghcr\.io/infrabits/ai-box):[A-Za-z0-9._-]+#\1:${next}#" entrypoint
if git diff --quiet -- entrypoint;
then
  echo "entrypoint was not changed; image reference not found?" >&2
  exit 1
fi

git add entrypoint
git commit -m "Creating release $next"
git tag "$next"
git push origin main "$next"
