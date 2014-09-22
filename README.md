[![Build status](https://secure.travis-ci.org/kigster/laser-cutter.png)](http://travis-ci.org/kigster/laser-cutter)
[![Code Climate](https://codeclimate.com/github/kigster/laser-cutter.png)](https://codeclimate.com/github/kigster/laser-cutter)

LaserCutter
============

Similar to boxmaker, this ruby gem generates PDFs that can be used as a 
basis for cutting boxes on a typical laser cutter. 

## Installation

Add this line to your application's Gemfile:

    gem 'laser-cutter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install laser-cutter

## Usage

```bash
> gem install bundler
> git clone https://github.com/kigster/laser-cutter.git
> cd laser-cutter && bundle
> bundle exec bin/laser-cutter --help
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
