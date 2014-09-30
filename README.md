[![Gem Version](https://badge.fury.io/rb/laser-cutter.svg)](http://badge.fury.io/rb/laser-cutter)
[![Build status](https://secure.travis-ci.org/kigster/laser-cutter.png)](http://travis-ci.org/kigster/laser-cutter)
[![Code Climate](https://codeclimate.com/github/kigster/laser-cutter.png)](https://codeclimate.com/github/kigster/laser-cutter)
[![Test Coverage](https://codeclimate.com/github/kigster/laser-cutter/badges/coverage.svg)](https://codeclimate.com/github/kigster/laser-cutter)

## LaserCutter

Similar to [BoxMaker](https://github.com/rahulbot/boxmaker/) (which is written in Java a long time ago), 
this ruby gem generates PDFs that can be used as a basis for creating a "snap-in" boxes with notched
sides on a typical laser cutter, by providing dimensions, material thickness and output file name. 

For more detailed comparison with BoxMaker and motivation behind this project, please see the section 
at the bottom of this README.

One of the design goals of this project is to provide a highly extensible platform for creating 
laser-cut designs, where alternative strategies can be added over time, and supported by various 
command line options, and perhaps a light weight web application.  If you are interested in 
contributing to the project, please see [contributing](CONTRIBUTING.md) for more details. 

```laser-cutter``` supports many flexible command line options that allow setting dimensions, 
stroke width, page size, layout, margins, padding (spacing between the boxes), and many more.
  
## Web Front-End

There is a web online application that uses this gem and allows you to generate PDFs with 
a friendly UI.

Please visit [http://makeabox.io](http://makeabox.io).

## Dependencies

The gem depends primarily on [Prawn](http://prawnpdf.org) – a fantastic PDF generation library. 

## Installation

Add this line to your application's Gemfile:

    gem 'laser-cutter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install laser-cutter

## Usage

```bash
Usage: laser-cutter [options] -o filename.pdf
   eg: laser-cutter -s 1x1.5x2/0.125/0.125 -O -o box.pdf

Specific Options:
    -w, --width WIDTH                Internal width of the box
    -h, --height HEIGHT              Internal height of the box
    -d, --depth DEPTH                Internal depth of the box
    -t, --thickness THICKNESS        Thickness of the box material
    -n, --notch NOTCH                Preferred notch length (used only as a guide)

    -m, --margin MARGIN              Margins from the edge of the document
    -p, --padding PADDING            Space between the boxes on the page
    -k, --stroke WIDTH               Numeric stroke width of the line
    -z, --page_size LETTER           Page size, see --list-all-page-sizes for more info.
    -y, --page_layout portrait       Page layout, other option is 'landscape'

    -O, --open                       Open generated file with system viewer before exiting
    -W, --write FILE                 Save provided configuration to a file, use '-' for STDOUT
    -R, --read FILE                  Read configuration from a file, or use '-' for STDIN

    -l, --list-all-page-sizes        Print all available page sizes with dimensions and exit
    -M, --no-metadata                Do not print box metadata on the PDF
    -v, --[no-]verbose               Run verbosely

        --examples                   Show detailed usage examples
        --help                       Show this message
        --version                    Show version

Common Options:
    -o, --file FILE                  Required output filename of the PDF
    -s, --size WxHxD/T/N             Combined internal dimensions: W = width, H = height,
                                     D = depth, T = thickness, N = notch length

    -u, --units UNITS                Either 'in' for inches (default) or 'mm'
```

### Examples

Create a box defined in inches, and open PDF in preview right after:

```bash
    laser-cutter -s 3x2x2/0.125/0.5 -O -o box.pdf
```       

Create a box defined in millimeters, print verbose info, and set
page size to A3, and layout to landscape, and stroke width to 1/2mm:

```bash
    laser-cutter -u mm -w70 -h20 -d50 -t4.3 -n5 -zA3 -y landscape -k0.5 -v -O -o box.pdf
```   

List all possible page sizes in metric system:

```bash
    laser-cutter -l -u mm
```                 

Create a box with provided dimensions, and save the config to a file for later use:

```bash
    laser-cutter -s 1.1x2.5x1.5/0.125/0.125 -p 0.1 -O -o box.pdf -W box-settings.json
```    

Read settings from a previously saved file:

```bash
    laser-cutter -O -o box.pdf -R box-settings.json
    cat box-settings.json | laser-cutter -O -o box.pdf -R -
```

## Future Features

* Extensibility with various layout strategies, notch drawing strategies, basically plug and play
  model for adding new algorithms for path creation and box joining
* Support more shapes than just box
* Create T-style joins, using various standard sizes of nuts and bolts (such as common #4-40 and M2 sizes)
* Supporting lids and front panels, that are larger than the box itself and have holes for notches. 
* Your brilliant idea can be here too!  Please see [contributing](CONTRIBUTING.md) for more info.

## Comparison with BoxMaker

It's important to note that the author believes that BoxMaker is a greatly useful piece of software 
generously open sourced by the author, and so in no way this project disputes BoxMaker's viability. 
  
In fact BoxMaker was an inspiration for this project. Laser-Cutter library attempts to further advance 
concept of programmatically creating laser-cut boxes, provide additional tuning, options, strategies
and most importantly – extensibility.  

Unlike ```BoxMaker```, this gem has a suit of automated tests (rspecs) around creating the geometry. 
In addition, we welcome new feature contributions, or bug fixes from other developers, and in that 
regard rspecs offer confidence that functionality still works.

BoxMaker's algorithm _tries to ensures that the same notch length is across all sides, but sacrifices
symmetry as a result_.  So you may have a front panel's left and right edges be simply non symmetric. 
And that might be entirely OK with you :)
 
```laser-cutter```'s algorithm will create a _symmetric design for most panels_, but it might sacrifice
identical notch length. Depending on the box dimensions you may end up with a slightly different notch 
length on each side of the box.

The choice ultimately comes down to the preference and feature set, so here I show you two boxes made with
each program, so you can pick what you prefer. 

### Example Outputs

Below are two examples of boxes with identical dimensions produced with ```laser-cutter``` and ```boxmaker```:

This is how you would make a box with Adam Phelp's fork of BoxMaker (which adds flags and a lot of 
niceties): 

```bash
git clone https://github.com/aphelps/boxmaker && cd boxmaker && ant
java -cp BOX.jar com.rahulbotics.boxmaker.BoxMaker \
      -W 1 -H 2 -D 1.5 -T 0.125 -n 0.125 -o box.pdf
```

And laser-cutter:

```bash
gem install laser-cutter
laser-cutter -s 1x1.5x2/0.125/0.125 -O -o box.pdf
```

![LaserCutter Comparison](doc/comparison.jpg).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/laser-cutter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
