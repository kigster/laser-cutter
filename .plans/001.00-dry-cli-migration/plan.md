# 001.00 Migrate the CLI to dry-cli, load with Zeitwerk

Branch `kig/migrate-to-dry-cli`, off `kig/2.0.0-alpha`; the PR targets `kig/2.0.0-alpha`.

## Decisions

- `lib/laser_cutter/` moves to `lib/laser/cutter/`, loaded by `Zeitwerk::Loader.for_gem_extension(Laser)`, eager-loaded. `lib/laser-cutter.rb` and `lib/laser_cutter.rb` remain as shims.

- `generate` takes height as `-H` / `--height`: dry-cli owns `-h`, and `-v` means verbose. `version` answers to `-V` / `--version`.

- Ruby 4.0.6, pinned in `.ruby-version`.

- The executables move from `bin/` to `exe/` and call `Laser::Cutter::Launcher`.

- Help and boxes share one width, 90 columns or fewer; a progress bar is 60 cells.

- `--inside-box` draws the unkerfed outline, which `--debug` used to do by accident; `--debug` is gone, `--verbose` prints the backtrace.

## Work

- [x] Zeitwerk: one constant per file (split `configuration.rb` and `path_generator.rb`, move `geometry/shape/{line,rect}.rb` up), eager load
- [x] dry-cli with dry-cli-help, dry-cli-ui and dry-cli-autocomplete; commands `generate`, `page-sizes`, `examples`, `help`, `version`, `completion`
- [x] `generate -f/--format pdf|svg`, PDF by default
- [x] Green progress bar, at most 60 cells wide, advancing once per line drawn
- [x] SVG output through `victor`
- [x] Launcher plus in-process Aruba suite
- [x] Bug: a notch that divides the sides exactly (4x3x2, notch 0.5) makes adjacent sides mismatch
- [x] README and CLAUDE.md updated
- [x] Bug: PageManager read the default Symbol units as millimeters
