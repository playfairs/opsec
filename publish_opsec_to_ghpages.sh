#!/usr/bin/env bash
set -euo pipefail

# === Edit these ===
GITHUB_USER="playfairs"
REPO="opsec"
DEB_FILE="opsec_1.0_all.deb"
BRANCH="gh-pages"

# === Derived things (you shouldn't need to change) ===
REMOTE_URL="git@github.com:${GITHUB_USER}/${REPO}.git"
PUBLISH_DIR="publish-temp"

# sanity checks
if [ ! -f "$DEB_FILE" ]; then
  echo "Error: $DEB_FILE not found in cwd. Put your .deb here or change DEB_FILE."
  exit 1
fi

# create a fresh folder for the repo contents
rm -rf "$PUBLISH_DIR"
mkdir -p "$PUBLISH_DIR"

# copy the deb into the root of the publish dir
cp "$DEB_FILE" "$PUBLISH_DIR/"

# create Packages.gz (dpkg-scanpackages scans the current dir for .deb files)
pushd "$PUBLISH_DIR" >/dev/null
if ! command -v dpkg-scanpackages >/dev/null 2>&1; then
  echo "dpkg-scanpackages not found. Installing dpkg via brew..."
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Install Homebrew or install dpkg manually: brew install dpkg"
    exit 1
  fi
  brew install dpkg
fi

# generate package index
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
popd >/dev/null

# prepare the git repo (will create if doesn't exist)
if [ ! -d ".git" ]; then
  # create a local git repo to push content to remote branch
  git init
fi

# create a orphan branch with only the published files so gh-pages is clean
git checkout --orphan "${BRANCH}" >/dev/null 2>&1 || git checkout "${BRANCH}" 2>/dev/null || true
git rm -rf . >/dev/null 2>&1 || true

# copy files into root of current git worktree
cp -r "${PUBLISH_DIR}/." .

# commit & push
git add -A
git commit -m "Publish opsec .deb and Packages.gz for GitHub Pages" || true

# set or add remote
if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$REMOTE_URL"
fi

# push branch to origin (force update so branch mirrors this content)
git push -u origin "${BRANCH}" --force

echo ""
echo "PUBLISHED to branch ${BRANCH} on ${GITHUB_USER}/${REPO}."
echo "Next steps:"
echo "  1) Go to https://github.com/${GITHUB_USER}/${REPO}/settings/pages and enable GitHub Pages for the '${BRANCH}' branch (root)."
echo "  2) Wait a minute for GitHub Pages to publish."
echo ""
echo "Client install instructions are below (replace YOURUSER with ${GITHUB_USER}):"
echo "  echo \"deb [trusted=yes] https://${GITHUB_USER}.github.io/${REPO} ./\" | sudo tee /etc/apt/sources.list.d/opsec-github.list"
echo "  sudo apt update"
echo "  sudo apt install opsec"
