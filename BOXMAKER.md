# LaserCutter versus BoxMaker

Another developer [Rahulbot](https://github.com/rahulbot/) created a similar app [BoxMaker](https://github.com/rahulbot/boxmaker/) in Java, which was an inspiration to LaserCutter.

Laser-Cutter library attempts to further advance the concept of programmatically creating 
laser-cut box designs, provides additional fine tuning, many more options, strategies and most 
importantly – extensibility.  

Unlike `BoxMaker` this gem has a suit of automated tests (rspecs) around the core functionality.
In addition, new feature contributions are highly encouraged, and in that 
regard having existing test suit offers confidence against regressions, and thus welcomes colaboration.

Finally, BoxMaker's notch-drawing algorithm generates non-symmetric and sometimes purely broken designs
(see picture below). 
 
`laser-cutter`'s algorithm will create a _symmetric design for most panels_, but it might sacrifice
identical notch length. Depending on the box dimensions you may end up with a slightly different notch 
length on each side of the box.

The choice ultimately comes down to the preference and feature set, so here I show you two boxes made with
each program, so you can pick what you prefer. 

### Example Outputs

Below are two examples of boxes with identical dimensions produced with `laser-cutter` and `boxmaker`:

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
laser-cutter -z 1x1.5x2/0.125/0.125 -O -o box.pdf
```

![LaserCutter Comparison](doc/comparison.jpg).

## Contributing

1. Fork it ( https://github.com/kigster/laser-cutter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
