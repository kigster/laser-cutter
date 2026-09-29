# frozen_string_literal: true

RSpec.describe 'laser-cutter', type: :aruba do
  let(:box) { '-b 4x3x2/0.125/0.5' }

  describe 'without arguments' do
    before { run_command_and_stop('laser-cutter') }

    it 'lists the commands and exits 0' do
      expect(last_command_started).to have_output(/generate.*page-sizes.*examples.*help/m)
    end

    it 'wraps help at 90 columns or fewer' do
      expect(last_command_started.output.lines.map { |line| line.chomp.length }.max).to be <= 90
    end
  end

  describe 'the width of help' do
    { 200 => 90, 80 => 74, 0 => 74, nil => 74 }.each do |columns, width|
      it "is #{width} on a terminal #{columns.inspect} columns wide" do
        expect(Laser::Cutter::CLI.help_width(columns)).to eq(width)
      end
    end
  end

  describe 'help' do
    it 'prints the top-level help' do
      run_command_and_stop('laser-cutter help')
      expect(last_command_started).to have_output(/COMMANDS/)
    end

    it 'describes the completion command' do
      run_command_and_stop('laser-cutter help')
      expect(last_command_started).to have_output(/completion\s+Generates auto-complete for BASH or ZSH/)
    end

    # In-process, dry-cli names the program after the process: rspec.
    it 'shows the shell the completion command takes' do
      run_command_and_stop('laser-cutter help completion')
      expect(last_command_started).to have_output(/completion SHELL \[OPTIONS\]/)
    end

    it 'explains one command' do
      run_command_and_stop('laser-cutter help generate')
      expect(last_command_started).to have_output(/-H, --height=VALUE/)
    end
  end

  describe 'version' do
    %w[version -V --version].each do |argument|
      it "answers to #{argument}" do
        run_command_and_stop("laser-cutter #{argument}")
        expect(last_command_started).to have_output(Laser::Cutter::VERSION)
      end
    end
  end

  describe 'examples' do
    it 'shows how to generate a box' do
      run_command_and_stop('laser-cutter examples')
      expect(last_command_started).to have_output(/laser-cutter generate -b 3x2x2/)
    end
  end

  describe 'page-sizes' do
    it 'lists the sizes in inches' do
      run_command_and_stop('laser-cutter page-sizes')
      expect(last_command_started).to have_output(/B10:\s+1\.2\s+x\s+1\.7/)
    end

    it 'lists the sizes in millimeters' do
      run_command_and_stop('laser-cutter page-sizes -u mm')
      expect(last_command_started).to have_output(/B10:\s+31\.0\s+x\s+44\.0/)
    end
  end

  # dry-cli-autocomplete writes to $stdout rather than the stream Aruba hands
  # the command, so this reads the process's stdout instead.
  describe 'completion' do
    it 'prints a zsh completion script' do
      expect { run_command_and_stop('laser-cutter completion zsh') }.to output(/laser-cutter/).to_stdout
    end
  end

  describe 'generate' do
    it 'writes a PDF by default' do
      run_command_and_stop("laser-cutter generate #{box} -o box.pdf")
      expect(read('box.pdf').first).to start_with('%PDF')
    end

    it 'reports one unit of progress per line drawn' do
      run_command_and_stop("laser-cutter generate #{box} -o box.pdf")
      expect(last_command_started).to have_output(%r{Drawing box\.pdf 360/360})
    end

    it 'draws the info box 60 columns wide' do
      run_command_and_stop("laser-cutter generate #{box} -o box.pdf")
      info = last_command_started.stdout.split('┌─ Success').first
      expect(info.lines.map { |line| line.chomp.length }.max).to eq(60)
    end

    it 'keeps the path of the file on one line' do
      run_command_and_stop("laser-cutter generate #{box} -o box.pdf")
      expect(last_command_started.stdout).to include(expand_path('box.pdf'))
    end

    it 'opens with an info box that names the gem and the dimensions' do
      run_command_and_stop("laser-cutter generate #{box} -o box.pdf")
      expect(last_command_started.stdout).to match(/─ Info ─.*Laser-Cutter \(ruby gem\) Version #{Laser::Cutter::VERSION}, ©/m)
        .and match(/Width:\s+4\.0 in.*Height:\s+3\.0 in.*Depth:\s+2\.0 in.*Notch:\s+0\.5 in.*Format: PDF/m)
    end

    it 'closes with a success box that gives the path of the file' do
      run_command_and_stop("laser-cutter generate #{box} -f svg -o box.svg")
      expect(last_command_started.stdout).to match(/─ Info ─.*─ Success ─.*Generated SVG file:.*box\.svg/m)
    end

    it 'writes an SVG, whatever the case of the format' do
      run_command_and_stop("laser-cutter generate #{box} -f SVG -o box.svg")
      expect(read('box.svg').join).to include('<svg', '<line').and include('viewBox="0 0 9.2012 11.5512"')
    end

    it 'draws the box without kerf as well with --inside-box' do
      run_command_and_stop("laser-cutter generate #{box} --inside-box -o box.pdf")
      expect(last_command_started).to have_output(%r{Drawing box\.pdf 712/712})
    end

    it 'takes each dimension as its own option, in millimeters' do
      run_command_and_stop('laser-cutter generate -u mm -w 70 -H 20 -d 50 -t 4.3 -n 5 -f svg -o box.svg')
      expect(read('box.svg').first).to match(/width="[\d.]+mm"/)
    end

    it 'prints the configuration with --verbose' do
      run_command_and_stop("laser-cutter generate #{box} -o box.pdf -v")
      expect(last_command_started).to have_output(/"thickness": 0\.125/)
    end

    it 'saves the configuration, and reads it back' do
      run_command_and_stop("laser-cutter generate #{box} -o box.pdf -W settings.json")
      expect(JSON.parse(read('settings.json').join)).to include('width' => 4.0, 'notch' => 0.5)

      run_command_and_stop('laser-cutter generate -R settings.json -f svg -o again.svg')
      expect(read('again.svg').join).to include('viewBox="0 0 9.2012 11.5512"')
    end

    it 'prints the configuration to STDOUT when saving to -' do
      run_command_and_stop("laser-cutter generate #{box} -o box.pdf -W -")
      expect(last_command_started).to have_output(/"depth": 2\.0/)
    end

    it 'opens the file with --open' do
      allow_any_instance_of(Laser::Cutter::CLI::Generate).to receive(:system)
      run_command_and_stop("laser-cutter generate #{box} -o box.pdf --open")
      expect(last_command_started).to have_exit_status(0)
    end

    context 'when it cannot run' do
      it 'fails without a file' do
        run_command_and_stop("laser-cutter generate #{box}", fail_on_error: false)
        expect(last_command_started).to have_exit_status(1)
        expect(last_command_started.stderr).to match(/─ Error ─.*file is required/m)
        expect(last_command_started.stdout).to be_empty
      end

      it 'fails on an unknown format' do
        run_command_and_stop("laser-cutter generate #{box} -f dxf -o box.dxf", fail_on_error: false)
        expect(last_command_started).to have_output(/unknown format "dxf", expected one of: pdf, svg/)
      end

      it 'fails on a missing configuration file' do
        run_command_and_stop('laser-cutter generate -R nothing.json -o box.pdf', fail_on_error: false)
        expect(last_command_started).to have_output(/cannot read the configuration from nothing\.json/)
      end

      it 'prints the backtrace with --verbose' do
        run_command_and_stop("laser-cutter generate #{box} -f dxf -o box.dxf -v", fail_on_error: false)
        expect(last_command_started).to have_output(/renderer\.rb/)
      end
    end
  end
end
