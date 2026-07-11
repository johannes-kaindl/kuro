# Licensing

Kuro is split-licensed by artefact type.

| Artefact | License | File |
|---|---|---|
| Theme code — `src/*.css`, `theme.css`, `build.sh` | MIT | [`LICENSE`](LICENSE) |
| Documentation — `README.md`, `CHANGELOG.md`, `docs/*`, this file | CC BY-SA 4.0 | [`LICENSE-DOCS`](LICENSE-DOCS) |
| Embedded fonts — `src/05-kuro-fonts.css` | SIL Open Font License 1.1 | see `README.md` → Fonts |

## Why MIT for the code

Kuro 5.0 is a **skeleton-fork of the [Minimal](https://github.com/kepano/minimal) theme**
by Stephan Ango (@kepano), which is MIT-licensed. Kuro owns and edits Minimal's variable/chrome
skeleton and replaces its components; to honour Minimal's license and keep the fork friction-free,
Kuro is released under the **same MIT license**. Minimal's copyright is retained in `LICENSE` and
in the `theme.css` header. (Earlier Kuro releases, built on a bespoke armature, carried AGPL-3.0;
the Minimal fork supersedes that lineage.)

## Why CC BY-SA 4.0 for the docs

Prose and documentation are not well served by a software license. CC BY-SA 4.0 keeps the
documentation free and share-alike while staying compatible with reuse in wikis and derivative guides.

## Fonts

The two embedded families (JetBrains Mono, EB Garamond) are each licensed under the SIL Open Font
License 1.1 and are redistributed here as Latin subsets. The OFL permits embedding and
redistribution; the fonts retain their own license and are not relicensed under MIT.
