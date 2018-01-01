[![Gem Version](https://badge.fury.io/rb/laser-cutter.svg)](http://badge.fury.io/rb/laser-cutter)
[![Build status](https://secure.travis-ci.org/kigster/laser-cutter.png)](http://travis-ci.org/kigster/laser-cutter)
[![Maintainability](https://api.codeclimate.com/v1/badges/bea3225fd93ee84d078a/maintainability)](https://codeclimate.com/github/kigster/laser-cutter/maintainability)[![Test Coverage](https://api.codeclimate.com/v1/badges/bea3225fd93ee84d078a/test_coverage)](https://codeclimate.com/github/kigster/laser-cutter/test_coverage)

! [Maintained](https://img.shields.io/maintenance/yes/2017.svg)
[![Join the chat at https://gitter.im/kigster/laser-cutter](https://badges.gitter.im/kigster/laser-cutter.svg)](https://gitter.im/kigster/laser-cutter?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=FSFYYNEQ8RKWU)

# LaserCutter

**LaserCutter** is a ruby library for generating PDF designs for boxes of custom dimensions that suit your project, that are meant to be used as a cut template on a laser-cutter. The sides of the box snap together using alternating notches, that are deliberately laid out in a symmetric form.

To use `laser-cutter` you need to have a recent version of ruby interpreter, install it as a gem, and use command line to generate PDFs.

[MakeABox.IO](http://makeabox.io) is an online web application that uses `laser-cutter` library and provides a straight-forward user interface for generating PDF designs without the need to install the gem or use command line.  

Use whatever suites you better.

> NOTE: Please read our [feature comparison guide](BOXMAKER.md) of LaserCutter against an older tool called [BoxMaker](https://github.com/rahulbot/boxmaker).

## Dependencies

The gem depends primarily on [Prawn](http://prawnpdf.org) – a fantastic PDF generation library. 

## Installation

Add this line to your application's Gemfile:

    gem 'laser-cutter'

And then execute:

    $ bundle

Or install it manually:

    $ gem install laser-cutter

## Usage

We'll start with some examples:

### Examples

Create a box defined in inches, with kerf (cut width) set to `0.005in`, and open PDF in preview right after:

```bash
    laser-cutter -z 3x2x2/0.125 -k 0.005 -O -o box.pdf
```       

Create a box defined in millimeters, print verbose info, and set page size to A3, and layout to landscape, and stroke width to `1/2mm`:

```bash
    laser-cutter -u mm -w70 -h20 -d50 -t4.3 -n5 -iA3 -l landscape -s0.5 -v -O -o box.pdf
```   

List all possible page sizes in metric system:

```bash
    laser-cutter -L -u mm
```                 

Create a box with provided dimensions, and save the config to a file for later use:

```bash
    laser-cutter -z 1.1x2.5x1.5/0.125/0.125 -p 0.1 -O -o box.pdf -W box-settings.json
```    

Read settings from a previously saved file:

```bash
    laser-cutter -O -o box.pdf -R box-settings.json
    cat box-settings.json | laser-cutter -O -o box.pdf -R -
```

### Complete Help

```bash

Usage: laser-cutter [options] -o filename.pdf
   eg: laser-cutter -z 1x1.5x2/0.125 -O -o box.pdf

Specific Options:
    -w, --width WIDTH                Internal width of the box
    -h, --height HEIGHT              Internal height of the box
    -d, --depth DEPTH                Internal depth of the box
    -t, --thickness THICKNESS        Thickness of the box material
    -n, --notch NOTCH                Optional notch length (aka "tab width"), guide only
    -k, --kerf KERF                  Kerf - cut width (default is 0.0024in)

    -m, --margin MARGIN              Margins from the edge of the document
    -p, --padding PADDING            Space between the boxes on the page
    -s, --stroke WIDTH               Numeric stroke width of the line
    -i, --page_size LETTER           Document page size, default is autofit the box.
    -l, --page_layout portrait       Page layout, other option is 'landscape'

    -O, --open                       Open generated file with system viewer before exiting
    -W, --write CONFIG_FILE          Save provided configuration to a file, use '-' for STDOUT
    -R, --read CONFIG_FILE           Read configuration from a file, or use '-' for STDIN

    -L, --list-all-page-sizes        Print all available page sizes with dimensions and exit
    -M, --no-metadata                Do not print box metadata on the PDF
    -v, --[no-]verbose               Run verbosely
    -B, --inside-box                 Draw the inside boxes (helpful to verify kerfing)
    -D, --debug                      Show full exception stack trace on error

        --examples                   Show detailed usage examples
        --help                       Show this message
        --version                    Show version

Common Options:
    -o, --file FILE                  Required output filename of the PDF
    -z, --size WxHxD/T[/N]           Combined internal dimensions: W = width, H = height,
                                     D = depth, T = thickness, and optional N = notch length

    -u, --units UNITS                Either 'in' for inches (default) or 'mm'
```

## Wish List

* Create T-style joins, using various standard sizes of nuts and bolts (such as common #4-40 and M2 sizes)
* Extensibility with various layout strategies, notch drawing strategies, basically plug and play
  model for adding new algorithms for path creation and box joining
* Support more shapes than just box, such as prisms
* Supporting lids and front panels, that are larger than the box itself and have holes for notches. 
* Your brilliant idea can be here too!  Please see [contributing](CONTRIBUTING.md) for more info.

## Contributing

1. Fork it ( https://github.com/kigster/laser-cutter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
