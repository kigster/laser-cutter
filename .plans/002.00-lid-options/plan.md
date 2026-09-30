# 002.00 Lid options: notched on one side, or plain

Branch `kig/add-lid-options`, off `master`; the PR targets `master`. Released as 2.0.1.

## Goal

A box whose lid lifts off. Today the lid (the `top` panel) is notched on all four sides and can only be glued shut.

## Decisions

Answered by Konstantin on 2026-09-30:

- The lid rests on top of the walls. Where a lid edge is plain, the wall edge under it is straight at the inner height `H`, and the lid reaches the outer footprint.
- The lid notched on one side joins the **back** wall, always.
- The option is `--lid full|back|plain`, `-L`, `full` by default. `full` draws exactly what 2.0.0 drew.

Decided without an answer (he had gone to bed), so worth a look in review:

- In `back` and `plain` the lid owns all four top corner squares, so no wall rises above `H` at a corner. In `back` the lid's two back corners are the feet either side of its notched edge.
- The internal height stays `H` in every mode: the underside of the lid is at `H`.
- The layout does not move. A wall without its tabs leaves its old space unused.

## Geometry

Faces are laid out in a column (`top`, `front`, `bottom`, `back`) with `left` and `right` beside `front`. A `Rect`'s sides run 0 bottom, 1 right, 2 top, 3 left. The lid's joints:

| Lid side | Wall    | Wall side |
| :------- | :------ | :-------- |
| 0        | `back`  | 2         |
| 1        | `right` | 0         |
| 2        | `front` | 0         |
| 3        | `left`  | 0         |

- A plain wall edge is the edge's **inside** line. The sides next to it lose the corner box, and its kerf fix-ups, at that end only.
- A plain lid edge is the edge's **outside** line.
- Kerf grows every outline by half the kerf, as it does for notches.

## Work

- [x] `Configuration`: `lid`, default `full`, rejected by `validate!` when unknown
- [x] `Notching::Edge` and `PathGenerator`: a corner box per end, not per edge
- [x] `Box`: per-face outlines; plain and back lids; straight wall edges
- [x] `generate --lid`, README, CLAUDE.md
- [x] Specs: each outline against an independent even-odd oracle, with and without kerf
- [x] Version 2.0.1
