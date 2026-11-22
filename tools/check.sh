#!/usr/bin/env bash
# Checks what every font in this repository must come with:
#
# - an .import file, written by tools/import.sh for the res://fonts/ path the
#   Godot projects mount this repository at;
# - a license text in its folder (OFL.txt, or a LICENSE / LICENCE file);
# - a line in LICENSE.md naming its file in backticks: that file is the record
#   of what may be redistributed, and Kalulu-Languages' pack validator reads it.
#
# It also refuses an .import file whose font is gone. Run by the Check workflow
# on every pull request; exits 1 on any problem.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

problems=0
problem() { echo "PROBLEM: $*"; problems=$((problems + 1)); }

fonts=0
while IFS= read -r font; do
    font="${font#./}"
    fonts=$((fonts + 1))
    if [ ! -f "$font.import" ]; then
        problem "$font has no .import file (run tools/import.sh)"
    elif ! grep -qx "source_file=\"res://fonts/$font\"" "$font.import"; then
        problem "$font.import was not written for res://fonts/$font (run tools/import.sh)"
    fi
    folder="$(dirname "$font")"
    if ! ls "$folder" | grep -qE '^(OFL\.txt|LICEN[CS]E(\.(md|txt))?)$'; then
        problem "$folder/ has no license text beside $font"
    fi
    if ! grep -qF "\`$(basename "$font")\`" LICENSE.md; then
        problem "LICENSE.md does not name \`$(basename "$font")\`"
    fi
done < <(find . -path ./.git -prune -o -type f \( -name '*.ttf' -o -name '*.otf' \) -print | sort)

while IFS= read -r import; do
    import="${import#./}"
    [ -f "${import%.import}" ] || problem "$import has no font beside it"
done < <(find . -path ./.git -prune -o -type f -name '*.import' -print | sort)

if [ "$problems" -gt 0 ]; then
    echo "check: $problems problem(s) in $fonts font(s)."
    exit 1
fi
echo "check: $fonts font(s), each with its .import file, its license and its line in LICENSE.md."
