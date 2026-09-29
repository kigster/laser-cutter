# 001.00 Migrate the CLI to dry-cli, load with Zeitwerk

Branch `kig/migrate-to-dry-cli`, off `kig/2.0.0-alpha`; the PR targets `kig/2.0.0-alpha`.

## Decisions

- `lib/laser_cutter/` moves to `lib/laser/cutter/`, loaded by `Zeitwerk::Loader.for_gem_extension(Laser)`, eager-loaded. `lib/laser-cutter.rb` and `lib/laser_cutter.rb` remain as shims.
- `generate` takes height as `-H` / `--height`: dry-cli owns `-h`, and `-v` means verbose. `version` answers to `-V` / `--version`.
- Ruby 4.0.6, pinned in `.ruby-version`.
- The executables move from `bin/` to `exe/` and call `Laser::Cutter::Launcher`.

## Work

- [ ] Zeitwerk: one constant per file (split `configuration.rb` and `path_generator.rb`, move `geometry/shape/{line,rect}.rb` up), eager load
- [ ] dry-cli with dry-cli-help, dry-cli-ui and dry-cli-autocomplete; commands `generate`, `page-sizes`, `examples`, `help`, `version`, `completion`
- [ ] `generate -f/--format pdf|svg`, PDF by default
- [ ] Green progress bar, at most 60 cells wide, advancing once per line drawn
- [ ] SVG output through `victor`
- [ ] Launcher plus in-process Aruba suite
- [ ] Bug: a notch that divides the sides exactly (4x3x2, notch 0.5) makes adjacent sides mismatch
- [ ] README and CLAUDE.md updated
