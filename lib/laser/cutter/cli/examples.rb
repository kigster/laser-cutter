# frozen_string_literal: true

module Laser
  module Cutter
    module CLI
      class Examples < Command
        desc 'Show detailed usage examples'

        TEXT = <<~EXAMPLES
          1. A box in inches, with the kerf set to 0.008", opened once it is written:

               laser-cutter generate -b 3x2x2/0.125 -k 0.008 -O -o box.pdf

          2. A box in millimeters on a landscape A3 page, with a 0.5mm stroke:

               laser-cutter generate -u mm -w 70 -H 20 -d 50 -t 4.3 -n 5 -i A3 -l landscape -s 0.5 -o box.pdf

          3. The same box as an SVG:

               laser-cutter generate -b 3x2x2/0.125 -f svg -o box.svg

          4. Every page size, in millimeters:

               laser-cutter page-sizes -u mm

          5. A box whose settings are saved for later:

               laser-cutter generate -b 1.1x2.5x1.5/0.125/0.125 -p 0.1 -o box.pdf -W box-settings.json

          6. A box from settings saved earlier, from a file or from STDIN:

               laser-cutter generate -o box.pdf -R box-settings.json
               cat box-settings.json | laser-cutter generate -o box.pdf -R -

          7. A box with a lid that lifts off: a plain rectangle, or one notched into the back wall only:

               laser-cutter generate -b 3x2x2/0.125 --lid plain -o box.pdf
               laser-cutter generate -b 3x2x2/0.125 --lid back -o box.pdf
        EXAMPLES

        def call(**)
          out.puts TEXT
        end
      end
    end
  end
end
