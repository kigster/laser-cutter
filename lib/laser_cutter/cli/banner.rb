require 'colored2'
require 'colored2/version'
require 'laser_cutter/version'
require 'prawn/version'

module LaserCutter
  module CLI
    BANNER = <<-EOF
#{'L A S E R'.yellow.italic + ' —— '.red + 'C U T T E R ®'.green.bold.italic + ' ✂ ✄ '.bold.yellow}                                version #{LaserCutter::VERSION.bold.cyan}

Prawn PDF Library        #{Prawn::VERSION.bold.cyan}
Techno-color by Colored2 #{Colored2::VERSION.bold.cyan}

Make Boxes Online!      ➩   #{'http://makeabox.io/'.bold.blue}
Contribute to source!   ➩   #{'https://github.com/kigster/laser-cutter'.bold.blue}
#{'⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽'.bold.red.underlined}

Usage: #{'laser-cutter [options] -o filename.pdf'.bold.green}

Example: 
   Set units to inches (default is 'mm') & specify dimensions using --size 
   shortcut, save result to a file, and then preview with system viewer (-P)
 
   #{'laser-cutter -u inches -s "3x4x5/0.125" -o box.pdf -P '.bold.blue}

    EOF

    EXAMPLES = <<-EOF

Examples:

Create a box defined in inches, set kerf to 0.008" and open PDF in preview 
right after:

   #{'laser-cutter -z 1x1x2/0.125 -k 0.008 -o box.pdf -P'.bold.green}

Create a box with given dimension, print verbose info, preview, and set 
stroke width to 1/2mm:

   #{'laser-cutter -w70 -h20 -d50 -t4.3 -n5 -s0.5 -v -P -o box.pdf'.bold.green}

Create a box with provided dimensions, set the padding, and save the config to a 
file for later use:

   #{'laser-cutter -z 1.1x2.1x2.5/0.125/0.5 -p 0.1 -o box.pdf -W box.json'.bold.green}

Read settings from a previously saved file:

   #{'laser-cutter -R box.json -O -o box.pdf'.bold.green} 
   #{'cat box.json | laser-cutter -O -o box.pdf -R -'.bold.green}

    EOF
    .freeze
  end
end
