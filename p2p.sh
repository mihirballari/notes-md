#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
PAGES_REPO="${PAGES_REPO:-$HOME/mihirballari.github.io}"
TARGET="notes"

echo "[p2p] source : $SRC_DIR"
echo "[p2p] repo   : $PAGES_REPO"
echo "[p2p] target : $TARGET"
echo

# ---------------------------------------------------------
# 1) build
# ---------------------------------------------------------
cd "$SRC_DIR"
echo "[p2p] build"
make html
echo

# ---------------------------------------------------------
# 2) sync JUST the stuff we actually publish
#    - all *.html in src → /notes
#    - css/ → /notes/css
#    - img/ → /notes/img (if exists)
#    THIS is what stops /notes/notes/ from appearing
# ---------------------------------------------------------
echo "[p2p] syncing html → $PAGES_REPO/$TARGET"
mkdir -p "$PAGES_REPO/$TARGET"

# copy all top-level html
rsync -av \
  --exclude '.git' \
  "$SRC_DIR/"*.html \
  "$PAGES_REPO/$TARGET/"

# copy css folder
if [ -d "$SRC_DIR/css" ]; then
  rsync -av "$SRC_DIR/css/" "$PAGES_REPO/$TARGET/css/"
fi

# copy img folder (optional)
if [ -d "$SRC_DIR/img" ]; then
  rsync -av "$SRC_DIR/img/" "$PAGES_REPO/$TARGET/img/"
fi

# ---------------------------------------------------------
# 2b) root index + root css so https://mihirballari.github.io/ looks right
# ---------------------------------------------------------
echo "[p2p] updating root index + css"
cp "$SRC_DIR/home.html" "$PAGES_REPO/index.html"
mkdir -p "$PAGES_REPO/css"
cp "$SRC_DIR/css/markdown-memo.css" "$PAGES_REPO/css/"
echo

# ---------------------------------------------------------
# 3) commit + push (always trigger)
# ---------------------------------------------------------
cd "$PAGES_REPO"
echo "[p2p] summary of changes:"
git status --short || true
echo

if ! git diff --quiet; then
  git add -A
  git commit -m "[p2p] update $(date '+%Y-%m-%d %H:%M:%S')"
  echo "[p2p] committed updated files."
else
  echo "[p2p] no detected changes — forcing trigger"
  echo "<!-- trigger $(date) -->" >>.deploy_trigger
  git add .deploy_trigger
  git commit -m "[p2p] trigger rebuild $(date '+%Y-%m-%d %H:%M:%S')"
fi

git push origin main
echo "[p2p] pushed to GitHub."
echo
echo "[p2p] done ✅"
echo "  view  : https://mihirballari.github.io/"
echo "  notes : https://mihirballari.github.io/notes/"
