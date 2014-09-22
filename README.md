[![Build status](https://secure.travis-ci.org/kigster/laser-cutter.png)](http://travis-ci.org/kigster/laser-cutter)
[![Code Climate](https://codeclimate.com/github/kigster/laser-cutter.png)](https://codeclimate.com/github/kigster/laser-cutter)

## LaserCutter

Similar to [BoxMaker](https://github.com/rahulbot/boxmaker/) (which is written in Java a long time ago), 
this ruby gem generates PDFs that can be used as a basis for cutting boxes on a typical laser cutter. 

Unlike ```BoxMaker```, this gem has a lot of automated tests around creating the geometry of the notches
and calculating locations. This welcomes additional feature contributions from other developers,
as existing test suite offers confidence around not introducing bugs or regressions.

BoxMaker's algorithm _ensures that the same notch length is across all sides, but sacrifices
symmetry as a result_.  So you may have your font panel's left and right sides be pretty different.
 
```laser-cutter```'s algorithm will create a _symmetric design for most panels_, but it might sacrifice
identical notch length_. Depending on the box dimensions you may end up with a slightly different notch 
length on each side of the box.

Finally, ```laser-cutter``` has a ton of options, that allow you to set stroke width, page size,
layout, margins, padding (spacing between boxes), open the PDF file using system viewer right
after generation, and many more are coming.

The choice ultimately comes down to the preference and feature set, so here I show you two boxes made with
each program, so you can pick what you prefer.

Below are two examples of boxes with identical dimensions produced with ```laser-cutter``` and ```boxmaker```:

#### BoxMaker Example

```bash
> java -cp BOX.jar com.rahulbotics.boxmaker.BoxMaker -i -W 2.5 -H 2 -D 1 -T 0.25 -n 0.5 -f file.pdf
```

![BoxMaker Example](doc/boxmaker.jpg).

#### LaserCutter Example

```bash
> laser-cutter -u in -s 2.5x1x2/0.25/0.5 -o file.pdf
```

![LaserCutter Example](doc/laser-cutter.jpg).

## Future Features

* Creating T-style holes and spacers for various sized nuts and bolts (such as common #4-40 and M2)
* Creating lids and front panels that are larger than the box
* Your brilliant idea can be here!  Please see [contributing](CONTRIBUTING.md) for more info.

## Installation

Add this line to your application's Gemfile:

    gem 'laser-cutter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install laser-cutter

## Usage

```bash
> laser-cutter --help
Usage: laser-cutter [options]'

   eg: laser-cutter --units in -s 2x3x2/0.125/0.5   -o box.pdf'
       laser-cutter -w 30 -h 20 -d 10 -t 4.3 -n 10  -o box.pdf


Specific options:
    -s, --size WxHxD/T/N             Combined internal dimensions: W = width, H = height,
                                     D = depth, T = thickness, N = notch length

    -w, --width WIDTH                Internal width of the box
    -h, --height HEIGHT              Internal height of the box
    -d, --depth DEPTH                Internal depth of the box
    -t, --thickness THICKNESS        Thickness of the box material
    -n, --notch NOTCH                Preferred notch length (used only as a guide)
    -o, --file FILE                  Output filename of the PDF
    -u, --units UNITS                Either 'mm' (default) or 'in'
    -m, --margin MARGIN              Margins from the edge of the document
    -p, --padding PADDING            Space between the boxes on the page
    -P, --page_size LETTER           Page size, see docs on Prawn for more options
    -L, --page_layout portrait       Page layout, other option is 'landscape'
    -S, --stroke WIDTH               Numeric stroke width of the line
    -O, --open                       Open generated file with system viewer before exiting
    -v, --[no-]verbose               Run verbosely

Common options:
        --help                       Show this message
        --version                    Show version
```       

## Contributing

1. Fork it ( https://github.com/[my-github-username]/laser-cutter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
