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
          pdf = Prawn::Document.new(:margin => options.margin.to_f.send(options.units.to_sym),
                                    :page_size => options.page_size,
                                    :page_layout => options.page_layout.to_sym)
          header = <<-EOF

          Made with Laser Cutter Ruby Gem (v#{Laser::Cutter::VERSION})
          Credits to Prawn for ruby PDF generation,
          and BoxMaker for inspiration.

          Online: http://makeabox.io/
          https://github.com/kigster/laser-cutter
          EOF

          renderer = self

          meta_color = "406080"
          meta_top = 150
          metadata = renderer.options.to_hash
          metadata.delete_if { |k| %w(verbose metadata open file).include?(k) }
          pdf.instance_eval do
            self.line_width = renderer.options.stroke.send(renderer.options.units.to_sym)
            if renderer.options.metadata
              float do
                bounding_box([0, meta_top], :width => 140, :height => 150) do
                  stroke_color meta_color
                  stroke_bounds
                  indent 10 do
                    font('Helvetica', :size => 6) do
                      text header, :color => meta_color
                    end
                  end
                  float do
                    bounding_box([0, 100], :width => 140, :height => 100) do
                      stroke_color meta_color
                      stroke_bounds
                      float do
                        bounding_box([0, 100], :width => 70, :height => 100) do
                          indent 10 do
                            font('Helvetica', :size => 6) do
                              out = JSON.pretty_generate(metadata).gsub(/[\{\}",]/, '').gsub(/:.*\n/x, "\n")
                              text out, :color => meta_color, align: :right
                            end
                          end
                        end
                      end
                      float do
                        bounding_box([60, 100], :width => 70, :height => 100) do
                          indent 10 do
                            font('Helvetica', :size => 6) do
                              out = JSON.pretty_generate(metadata).gsub(/[\{\}",]/, '').gsub(/\n?.*:/x, "\n:")
                              text out, :color => meta_color
                            end
                          end
                        end
                      end
                    end
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
