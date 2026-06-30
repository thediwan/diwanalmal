#!/usr/bin/env bash
# Submit Diwan Al-Mal to F-Droid (fdroiddata merge request).
# Run on Linux with fdroidserver installed (sudo apt install fdroidserver).
#
# Prerequisites:
#   - GitLab account with fork of https://gitlab.com/fdroid/fdroiddata
#   - git remote pointing to your fork
#   - Tag v1.0.0 pushed to https://github.com/thediwan/diwanalmal
#
# Usage:
#   git clone https://gitlab.com/<your-user>/fdroiddata.git
#   cd fdroiddata
#   bash /path/to/diwanalmal/scripts/submit-fdroiddata-mr.sh

set -euo pipefail

APP_ID="org.thediwan.diwanalmal"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FDROIDDATADIR="${FDROIDDATADIR:-$(pwd)}"

if [[ ! -d "$FDROIDDATADIR/.git" ]]; then
  echo "Run from fdroiddata clone or set FDROIDDATADIR"
  exit 1
fi

cp "$REPO_ROOT/fdroid/${APP_ID}.yml" "$FDROIDDATADIR/metadata/"
cd "$FDROIDDATADIR"

git checkout -b "add-${APP_ID}" 2>/dev/null || git checkout "add-${APP_ID}"
git add "metadata/${APP_ID}.yml"

fdroid lint "$APP_ID"
echo "Lint passed. Commit and push:"
echo "  git commit -m 'New App: Diwan Al-Mal (${APP_ID})'"
echo "  git push -u origin add-${APP_ID}"
echo "Then open MR: https://gitlab.com/fdroid/fdroiddata/-/merge_requests/new"
