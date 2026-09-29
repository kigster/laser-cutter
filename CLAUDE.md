# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`laser-cutter` is a Ruby gem and CLI that generates a PDF of the six notched panels of a box. You cut the panels on a laser cutter and they snap together. Prawn renders the PDF. The notch algorithm favors **symmetric** panels over identical notch lengths.

## Commands

The `justfile` drives everything. Its recipes wrap `bundle exec` in `eval "$(rbenv init - bash)"`. There is no `.ruby-version`. CI and `.rubocop.yml` target Ruby **4.0** (CI pins 4.0.6).

```bash
just lint                     # rubocop
just format                   # rubocop -a, plus mdformat on every *.md
just test                     # rspec (progress format, random order)
just test spec/lib/laser_cutter/edge_spec.rb:42   # one file or example
just test-docs                # rspec --format documentation
just ci                       # lint + test-coverage
just doc                      # YARD docs
```

- `bundle exec rspec`, `bundle exec rubocop` and `bundle exec rake` (default task `spec`) also work.
- Every rspec run rewrites `docs/badges/coverage_badge.svg` through the SimpleCov `at_exit` hook in `spec/spec_helper.rb`. That file shows up in `git status` after any test run.
- The justfile comment says a full run "enforces 100% coverage", and `test-coverage` sets `COVERAGE=true`. `spec_helper.rb` reads neither, and no `minimum_coverage` is set, so nothing enforces coverage today.
- `just build` is an empty recipe, so `just publish` builds nothing. `rake build` (Bundler gem tasks, chained after `rake permissions`) is the real build.

## Architecture

Everything lives under `Laser::Cutter`. The entry point is `lib/laser-cutter.rb`, which requires each subsystem by hand. `lib/laser_cutter.rb` is a shim for it. Zeitwerk appears in the gemspec but is not used.

Pipeline, from config to PDF:

1. **`Configuration`** (`configuration.rb`) is a `Hashie::Mash` with symbolized keys. It parses the `--box WxHxD/T[/N]` shorthand into width, height, depth, thickness and notch, casts numeric strings to floats, and merges per-unit defaults for kerf, margin, padding and stroke from the `defaults[:in]` / `defaults[:mm]` table. Notch defaults to `3 × thickness`. `validate!` raises `MissingOption` / `ZeroValueNotAllowed`. `change_units` converts every float field in place.
2. **`Renderer::LayoutRenderer`** orchestrates. It builds a `BoxRenderer`, plus a `MetaRenderer` when `config.metadata` is set. It reserves space for the metadata block via `ensure_space_for`, and adds a red unkerfed `BoxRenderer` when `config.debug` is set. It sizes the page from the box enclosure unless `page_size` is given, then renders into a `Prawn::Document`. Renderers share `Renderer::Base` (`config`, `subject`, `enclosure`, `page_manager`) and draw inside `pdf.instance_eval`.
3. **`Box`** (`box.rb`) models the six faces as `Geometry::Rect`s. `position_faces!` lays them out in a cross (see the ASCII diagram in that method). `generate_notches` then walks each face. For every side it pairs the face's outer bounding rect (face grown by `thickness`) with the face itself as a **`Notching::Edge`**. A `conf` table sets per-face alignment: `valign`/`halign` decide whether a side's center notch points `:out` or `:in`. `corners` plus `pick_corners_face` decide which face fills the corner squares: `:front` by default, `:top` when every front edge's notch count is `≡ 3 (mod 4)`.
4. **`Notching::Edge`** holds the inside and outside lines of one side, both shifted by `kerf / 2`. `calculate_notch_width!` forces an **odd** notch count of at least `MINIMUM_NOTCHES_PER_SIDE = 3` and then recomputes the real notch width, so the requested notch is only a guide. `first_notch_out?` combines `center_out` with `notch_count % 4`.
5. **`Notching::PathGenerator`** turns an `Edge` into `Geometry::Line`s. It zigzags between the inside and outside lines using `Shift` deltas from two alternating `InfiniteIterator`s (one along the edge, one across it). It widens or narrows notches by `kerf` and adds corner boxes plus the kerf corner fix-ups (`add_corners_when_out` / `add_boxes_when_in`).
6. **`Aggregator`** receives every line of a face and cleans it up with `dedup!.deoverlap!.dedup!`. `dedup!` drops **both** copies of any identical pair. `deoverlap!` replaces overlapping lines with their `xor`. Neighboring edges draw shared segments twice, and this pass removes them.

`Geometry` provides `Tuple` (backed by `Vector` from stdlib `matrix`), `Point`, `Dimensions`, `Shape`, `Line` and `Rect` (`Rect[p1, p2]`, `Rect.create(point, w, h, name)`, `sides`, `relocate!`). Internal geometry is unitless in the config's units. Conversion to PDF points happens only at render time via Prawn's measurement extensions (`value.send(:in)` / `.send(:mm)`). `PageManager#value_from_units` converts the other way, from PDF points (1/72 in) back to config units.

CLI: `lib/laser_cutter/cli/opt_parser.rb` (OptionParser, `colored2`) and `cli/serializer.rb` (`-W` / `-R` JSON config save and load, `-` means stdout or stdin).

## Known broken or in-flux (2.0.0-alpha branch)

- `bin/laser-cutter` and `bin/lc` require `../lib/laser-cutter/cli/opt_parser`, but that file lives at `lib/laser_cutter/cli/opt_parser.rb`, so the executables fail to load.
- `opt_parser.rb` requires `colored2`, which is missing from the gemspec. The gemspec lists `dry-cli*`, `tty-*`, `victor`, `pastel` and `zeitwerk`, and nothing in `lib/` uses them yet. The CLI looks mid-migration to dry-cli.
- The `Rakefile` YARD title is copied from another project (`dry-cli-ui`), and it references a `CHANGELOG.md` that does not exist.
- The box shorthand flag is `-b` in `opt_parser.rb` and in the README examples, but the README option table lists it as `-z, --box`.
- `Box` still carries the comment "badly needs refactoring and tests".

## Conventions

- `.rubocop.yml` inherits `.relaxed_rubocop.yml` and `.rubocop_todo.yml`, with a 120-column line limit and table-aligned hashes.
- Specs live in `spec/lib/laser_cutter/*_spec.rb` and use `rspec-its`, `disable_monkey_patching!` and random order.
