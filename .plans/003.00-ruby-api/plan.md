# 003.00 A Ruby API for MakeABox.io

Branch `kig/add-ruby-api-facade`, off `master` once 002.00 had merged; the API carries the lid that plan added.

## Goal

MakeABox.io, a Rails application, draws boxes in-process. It must not shell out to `laser-cutter`, and it must be able to ask for any lid.

## What 2.0.0 already allowed

`Configuration.new(hash)`, `validate!`, `Renderer::LayoutRenderer.new(config).render` and `PageManager#page_size_values` are what the website calls today against 1.0.3, and all still work. Two things were missing:

- A renderer could only write to `config.file`. A controller wants the bytes.
- `validate!` demanded `file`, so a caller with no file had to invent one.
- `Configuration` is a Mash: it takes any key and any value, and says nothing until a renderer trips over it.

## Decisions

- Asked for by Konstantin mid-way: the facade takes every option as a **typed class**. That is `Laser::Cutter::Options`, a strict `Dry::Struct` with its types in `Laser::Cutter::Types`. dry-struct becomes a runtime dependency.
- `Laser::Cutter.render(options)` returns the document as a String. No file is needed or written.
- `Laser::Cutter.write(options)` writes it to `options.file`. Without a format, the extension of the file decides.
- Both take an `Options`, or a Hash they turn into one, and pass a block through as the per-line callback.
- `Options` coerces Strings, reads a blank String as left out, and refuses unknown keys. A missing dimension raises `MissingOption`, with the message `Configuration#validate!` gives, since the website rewrites that message. Anything else raises `InvalidOption`.
- The `--box` shorthand is not an attribute: it is a way to type four options, not a fifth.
- Renderers answer `document`, the String; `render` writes it to `config.file` as before.
- `Configuration` also reads a blank lid as the default, for callers still building one by hand.
- "The two lid types (or none)" is read as `back`, `plain`, or no lid setting at all, which is `full`. A box with no lid panel is not part of this.
- Requiring the gem still loads dry-cli and the commands. Harmless in a Rails process; splitting the CLI out of the default require is left for later.
- The command line keeps building a `Configuration` itself; it is not moved onto `Options` here.

## Work

- [x] `document` on both renderers
- [x] `Types` and `Options`
- [x] `Laser::Cutter.render` and `Laser::Cutter.write`
- [x] Specs, including Strings from a form and the calls the website makes today
- [x] README section, CLAUDE.md
