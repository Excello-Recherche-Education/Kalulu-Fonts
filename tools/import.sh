#!/usr/bin/env bash
# Writes the Godot .import file of every font in this repository.
#
# Kalulu-Frontend and Kalulu-ProfTool both mount this repository at res://fonts/,
# and Godot writes an .import file beside every font it finds there. Those files
# are committed here, so that neither project leaves the submodule modified. Run
# this after adding or replacing a font, and commit the .import file with it.
#
#   tools/import.sh        GODOT=/path/to/godot tools/import.sh
#
# It imports a copy of the working tree in a scratch project, at the same
# res://fonts/ path the two projects use, then copies the .import files back.
# An .import file already here keeps its uid and its settings; a new font gets
# Godot's default import settings.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot="${GODOT:-$(command -v godot || true)}"
if [ -z "$godot" ] || [ ! -x "$godot" ]; then
    echo "import: no Godot. Set GODOT to the binary (Kalulu-Main: . scripts/kalulu-env.sh)." >&2
    exit 2
fi

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
printf 'config_version=5\n\n[application]\n\nconfig/name="kalulu-fonts-import"\n' > "$scratch/project.godot"
mkdir "$scratch/fonts"
tar -C "$root" --exclude .git --exclude .github --exclude tools -cf - . | tar -C "$scratch/fonts" -xf -

"$godot" --headless --path "$scratch" --import > "$scratch/import.log" 2>&1 || true

written=0
while IFS= read -r font; do
    rel="${font#"$scratch/fonts/"}"
    if [ ! -f "$font.import" ]; then
        echo "import: Godot wrote no .import for $rel. Its log:" >&2
        cat "$scratch/import.log" >&2
        exit 1
    fi
    if ! cmp -s "$font.import" "$root/$rel.import"; then
        cp "$font.import" "$root/$rel.import"
        echo "wrote $rel.import"
        written=$((written + 1))
    fi
done < <(find "$scratch/fonts" -type f \( -name '*.ttf' -o -name '*.otf' \) | sort)

echo "import: $written .import file(s) written, with $("$godot" --version)."
