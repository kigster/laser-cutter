# Decisions on the angled box

Source: `spec/wishes/wish-tilted-box.png`, plan `004.00`.

## What the wish image shows

A console box, the kind that holds an LCD tilted towards the reader. Seen from the side, the profile is a pentagon:

```mermaid
flowchart LR
  A["back (H, full height)"] --- B["top strip (Dt)"]
  B --- C["tilted panel (S, at angle α)"]
  C --- D["front strip (Hf)"]
  D --- E["bottom (D)"]
  E --- A
```

- **Sides:** two pentagons, notched on all five edges, the sloped one included.
- **Back, bottom:** rectangles notched on all four sides, as today.
- **Tilted panel (LCD), top strip, front strip:** rectangles notched only on their ends, into the sides. Their long edges, where they meet each other at an angle, are plain.
- Seven panels, not six.

## Verdict: feasible

- **Notching a sloped edge** needs no change to the notch algorithm. Lay the edge flat in a local frame, notch it with `Edge` + `PathGenerator`, turn the lines back. Built in this PR: `Geometry::Transform`, `Notching::AngledEdge`.
- **Mating:** the tilted panel is a plain rectangle. Its ends and the sloped wall edge have the same length, so they get the same notch count and width; opposite `center_out` makes them interlock. Covered by `angled_edge_spec.rb`.
- **Aggregator:** no change needed. Sloped edges draw no corner boxes, so nothing on them is drawn twice; their lines pass through as `skewed`.
- **Angled joints** (tilted panel to the strips) are plain butt joints, as in the image. See *Decided*.
- **Renderers:** both draw lines, so PDF and SVG need nothing new.

## Decided

- **Invocation:** flags on `generate`: `--slope DEGREES` and `--front-height HF`. No `--slope` means today's six-panel box. Each flag gets an `Options` attribute.
- **Angled joints:** plain butt joints. Panel lengths are corrected for thickness so the outside lines meet; glue fills the wedge inside.
- **Lid:** `--lid` applies to the tilted panel, which lifts off.
- **Range:** `0 < α < 90`. The top strip is dropped when `Dt = 0` and the front strip when `Hf = 0`. A negative `Dt` raises `InvalidOption`.

## Shape of the work

- `Box` stays the six-panel box. The angled box is a new class beside it (open/closed), sharing `Edge`, `PathGenerator`, `AngledEdge`, `Aggregator`.
- Sides become polygons; a `Geometry::Polygon` with sides at any angle is the next piece.

## Open questions

- [ ] **Q1. Parameters.** Which four numbers define the profile? Proposal: depth `D`, back height `H`, front height `Hf`, angle `α` of the tilted panel; the top strip depth follows, `Dt = D − (H − Hf) / tan α`, and must be ≥ 0.
- [ ] **Q4b. Lid styles.** The tilted panel joins only the two sides; its other edges are plain. So `back` has no back wall to notch into. Which `--lid` values apply: `full` (notched into both sides, fixed) and `plain` (lies on the sides, lifts off), with `back` rejected?
