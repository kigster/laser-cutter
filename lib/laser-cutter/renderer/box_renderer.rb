# encoding: utf-8
require 'json'
module Laser
  module Cutter
    module Renderer
      class BoxRenderer < AbstractRenderer
        alias_method :box, :subject
        def initialize(options = {})
          self.options = options
          self.subject = Laser::Cutter::Box.new(options)
        end

        def render pdf = nil
          pdf = Prawn::Document.new(:margin => options.margin.send(options.units),
                                    :page_size => options.page_size,
                                    :page_layout => options.page_layout.to_sym)
          header = <<-EOF

          Produced with Laser Cutter Ruby Gem (v#{Laser::Cutter::VERSION})
          Credits to Prawn (for ruby PDF generation),
          and BoxMaker (for the inspiration).
          © 2014 Konstantin Gredeskoul, MIT license.
          https://github.com/kigster/laser-cutter
          Generated at #{Time.new}.
          EOF

          renderer = self

          pdf.instance_eval do
            self.line_width = renderer.options.stroke.send(renderer.options.units.to_sym)
            float do
              bounding_box([0, 50], :width => 150, :height => 40) do
                stroke_color '0080FF'
                stroke_bounds

                indent 10 do
                  font('Courier', :size => 5) do
                    text header, :color => "0080FF"
                  end
                end
              end
              bounding_box([480, 120], :width => 110, :height => 110) do
                stroke_color '00DF20'
                stroke_bounds
                indent 10 do
                  font('Courier', :size => 6) do
                    out = JSON.pretty_generate(renderer.options.to_hash).gsub(/[\{\}",]/,'')
                    text out, :color => "00DF20"
                  end
                end
              end
            end

            stroke_color "000000"
            renderer.box.notches.each do |notch|
              LineRenderer.new(notch, renderer.options).render(self)
            end

            render_file(renderer.options.file)
          end

          if options.verbose
            puts "file #{options.file} has been written."
          end
        end

      end
    end
  end
end
