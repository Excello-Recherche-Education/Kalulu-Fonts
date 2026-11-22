# Kalulu-Fonts

The fonts of [Kalulu](https://github.com/Excello-Recherche-Education/Kalulu-Frontend),
the reading app by [Excello Recherche & Éducation](https://github.com/Excello-Recherche-Education):
Kalulu's modified **Mulish**, for script letters, and **Marelle**, the French
school cursive, plus any font a language's printed booklets use instead.

Every Kalulu repository that uses a font mounts this one as a git submodule.
**No other repository keeps a copy of a font**, so this is the only place a font
is ever changed.

All the fonts are under the **SIL Open Font License 1.1**, each family with its
`OFL.txt`. [`LICENSE.md`](LICENSE.md) is the record of every font: its
copyright, its version, and what Excello changed in Mulish. Nothing here is
under the CC BY-SA license of the other Kalulu repositories.

## Where it is mounted

| Repository | Path | What it uses |
|---|---|---|
| [Kalulu-Languages](https://github.com/Excello-Recherche-Education/Kalulu-Languages) | `fonts/` | every font: a pack's `BookletFonts` names its files by their path here |
| [Kalulu-Frontend](https://github.com/Excello-Recherche-Education/Kalulu-Frontend) | `fonts/` (`res://fonts/`) | Mulish, for the game's interface. Its export presets leave everything else out |
| [Kalulu-ProfTool](https://github.com/Excello-Recherche-Education/Kalulu-ProfTool) | `project/fonts/` (`res://fonts/`) | Mulish now; every font once it previews the booklets |
| [Kalulu-Manuals](https://github.com/Excello-Recherche-Education/Kalulu-Manuals) | `kalulu-fonts/` | Mulish, converted to TrueType at build time for ReportLab |
| [Kalulu-Booklets](https://github.com/Excello-Recherche-Education/Kalulu-Booklets) | through its `kalulu-languages/` | every font a booklet prints with |

Each repository records the commit of this one it uses, and moves to a newer
one in a pull request of its own. A clone needs `--recurse-submodules`, or
`git submodule update --init --recursive` afterwards.

**The two Godot projects must keep mounting it at `res://fonts/`.** Godot writes
an `.import` file beside every font it finds, and those files are committed
here. Each one names its font's `res://` path, so it is the same file in both
projects only because the path is the same. At another path, Godot would
rewrite them and the submodule would show as modified.

## Changing or adding a font

Every change is a pull request here. The **Check** workflow (`tools/check.sh`)
makes sure every font has:

- its `.import` file;
- a license text in its folder;
- a line in `LICENSE.md` naming the font file in backticks.

1. Put the font in its folder. A new family gets a folder of its own
   (`andika/Andika-Regular.ttf`), with its license text beside it. Check first
   that its license lets it be redistributed: this repository is public, and a
   font that comes with an operating system or a word processor usually cannot
   be.
2. Run `tools/import.sh`, which writes the `.import` file with Godot (set
   `GODOT`, or have `godot` on the `PATH`).
3. Describe the font in `LICENSE.md`, as the others are.
4. Once the pull request is merged, move the pointer in each repository that
   should use the change, in a pull request there. A booklet font only needs
   Kalulu-Languages; Mulish needs all of them.
5. **A new folder is also added to the `exclude_filter` of Kalulu-Frontend's
   export presets.** Otherwise the game ships a font it never uses: it exports
   every resource, and Godot's filters cannot say "everything but `mulish/`".

Do not modify the Marelle files: "Marelle" is a Reserved Font Name (see
`LICENSE.md`).
