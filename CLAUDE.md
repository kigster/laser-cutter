# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`laser-cutter` is a Ruby gem and CLI that generates a PDF of the six notched panels of a box. You cut the panels on a laser cutter and they snap together. Prawn renders the PDF. The notch algorithm favors **symmetric** panels over identical notch lengths.

## Commands

The `justfile` drives everything. Its recipes wrap `bundle exec` in `eval "$(rbenv init - bash)"`. `.ruby-version` and CI pin Ruby **4.0.6**; dry-cli-help and dry-cli-ui need 4.0.

```bash
just lint                     # rubocop
just format                   # rubocop -a, plus mdformat on every *.md
just test                     # rspec (progress format, random order)
just test spec/laser/cutter/edge_spec.rb:42   # one file or example
just test-docs                # rspec --format documentation
just ci                       # lint + test-coverage
just doc                      # YARD docs
```

- `bundle exec rspec`, `bundle exec rubocop` and `bundle exec rake` (default task `spec`) also work.
- Every rspec run rewrites `docs/badges/coverage_badge.svg` through the SimpleCov `at_exit` hook in `spec/spec_helper.rb`. That file shows up in `git status` after any test run.
- `spec_helper.rb` fails the run under 95% line coverage. The Aruba suite in `spec/laser/cutter/cli_spec.rb` counts towards it.

## Architecture

Everything lives under `Laser::Cutter`, in `lib/laser/cutter/`. `lib/laser/cutter.rb` requires the third-party gems, then sets up `Zeitwerk::Loader.for_gem_extension(Laser)` and **eager-loads** it. So: one constant per file, the file name matches the constant, and no `require` between the gem's own files. `lib/laser-cutter.rb` and `lib/laser_cutter.rb` are shims.

Pipeline, from config to file:

1. **`Configuration`** is a `Hashie::Mash` with symbolized keys. It parses the `--box WxHxD/T[/N]` shorthand, casts numeric strings to floats, and merges per-unit defaults for kerf, margin, padding and stroke. Notch defaults to `3 × thickness`. `validate!` raises `MissingOption` / `ZeroValueNotAllowed`, and `InvalidOption` for a lid it does not know. `units` defaults to the Symbol `:in`, and arrives as a String from the command line, so compare it with `to_s` or `to_sym`.
1. **`Renderer.for(format, config)`** picks `LayoutRenderer` (PDF, Prawn) or `SvgRenderer` (SVG, Victor). Both answer `total` (lines to draw) and `render { |line| }`, which yields after each line. That block drives the progress bar.
   - `LayoutRenderer` draws a `BoxRenderer`, a `MetaRenderer` when `config.metadata` is set, and a second red `BoxRenderer` without kerf when `config.debug` is set. It sizes the page from the box enclosure unless `page_size` is given.
   - `SvgRenderer` fits the page to the box, flips y (SVG counts down from the top), and writes the metadata as a `<desc>`.
1. **`Box`** models the six faces as `Geometry::Rect`s. `position_faces!` lays them out in a cross (see the ASCII diagram in that method). `generate_notches` pairs each side of a face with the matching side of its outer bounding rect (face grown by `thickness`) as a **`Notching::Edge`**. The `conf` table sets per-face alignment: `valign`/`halign` decide whether a side's center notch points `:out` or `:in`. `corners` plus `pick_corners_face` decide which face fills the corner squares.
   - `lid` (`full`, `back`, `plain`) sets how the `top` panel joins the walls. A plain lid edge is the edge's **outside** line, and the wall side under it (`LID_SIDES`) is the edge's **inside** line, so the lid lies on walls that end at the inner height. The lid then owns the corners above the walls: `corner_ends` strips the corner box from the wall sides that touch it.
   - `outlines` holds the merged lines of each face by name; `notches` is all of them, flattened.
1. **`Notching::Edge`** holds the inside and outside lines of one side, both shifted by `kerf / 2`. `calculate_notch_width!` forces an **odd** notch count of at least 3 and recomputes the real notch width, so the requested notch is only a guide. It rounds `length / notch` to `RATIO_DIGITS` before `ceil`: two panels meeting at a joint must get the same count, and float noise used to split them when the notch divided the side exactly.
1. **`Notching::PathGenerator`** turns an `Edge` into `Geometry::Line`s. It zigzags between the inside and outside lines using `Shift` deltas from two alternating `InfiniteIterator`s. It widens or narrows notches by `kerf` and adds the corner boxes, at the ends the edge names in `corner_ends`. Kerf grows every outline by half the kerf on every side; `spec/laser/cutter/box_lid_spec.rb` checks exactly that, point by point, through `spec/support/outline.rb`.
1. **`Aggregator`** merges the lines of a face into the outline to cut. Neighbouring edges draw shared stretches twice, and a shared stretch runs through the material, so each collinear group is combined as a symmetric difference: a point is cut when an odd number of lines cover it. It groups lines by axis and offset and sweeps each group once, so a face takes n log n; the old pairwise version made a 100×80×60 box take 55 seconds.

Geometry is unitless, in the config's units. Conversion to PDF points happens only at render time (`value.send(:in)` / `.send(:mm)`). `PageManager#value_from_units` converts PDF points back.

### Command line

- `exe/laser-cutter` (and `exe/lc`) call `Laser::Cutter::Launcher.new(ARGV).execute!`. The Launcher takes argv, the three streams and `kernel`, and exits only through `kernel.exit`. Aruba runs it in-process (`spec/support/aruba.rb`), so commands must write to `out` and `err`, never to `$stdout`.
- `CLI` (`cli.rb`) is the dry-cli registry and the `Dry::CLI::Help.configure` block. Commands live in `cli/`: `generate`, `page-sizes`, `examples`, `help`, `version`, `completion`.
- Every message goes through `ui`: errors in `ui.error` boxes on STDERR (the Launcher draws them), `generate` opens with `ui.info` and closes with `ui.success`.
- `CLI::Command` is the base: it includes `Dry::CLI::UI`, declares `-v`, and offers `progress(label, total:)`, a green bar of 60 cells. Help and boxes share one width, `CLI.help_width`: the terminal's less 6, and 90 at most.
- `-h` belongs to help, so height is `-H`.

## Known gaps

- `generate` declares defaults for `--units` and `--page-layout`, and they override what `-R` reads from a saved configuration. `--lid` has no dry-cli default for that reason.

- `just build` is an empty recipe, so `just publish` builds nothing. `rake build` is the real build.

- The `Rakefile` YARD title is copied from another project, and it references a `CHANGELOG.md` that does not exist.

- The gemspec lists `tty-*` and `pastel` directly, though only dry-cli-ui uses them.

- `Box` still carries the comment "badly needs refactoring and tests".

## Conventions

- `.rubocop.yml` inherits `.relaxed_rubocop.yml` and `.rubocop_todo.yml`, with a 120-column line limit and table-aligned hashes.
- Specs mirror `lib/` under `spec/laser/cutter/` and use `rspec-its`, `disable_monkey_patching!` and random order.
