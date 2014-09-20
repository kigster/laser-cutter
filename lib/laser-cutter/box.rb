module Laser
  module Cutter
    class Box
      # Everything is in millimeters

      attr_accessor :dim, :thick, :notch
      attr_accessor :margin, :padding

      attr_accessor :front, :back, :top, :bottom, :left, :right
      attr_accessor :faces, :bounds, :notches

      def initialize(dimension, thick, notch = nil)
        self.dim = dimension if (dimension.is_a?(Geometry::Dimensions) && dimension.valid?)
        self.thick = thick
        self.notch = notch
        self.notch = (self.thick * 2) if self.notch.nil?
        self.margin = 2
        self.padding = 5

        zero = Geometry::Point.new(0,0)

        self.front  = Geometry::Rect.new(zero, dim.w, dim.h, "front")
        self.back   = Geometry::Rect.new(zero, dim.w, dim.h, "back")

        self.top    = Geometry::Rect.new(zero, dim.w, dim.d, "top")
        self.bottom = Geometry::Rect.new(zero, dim.w, dim.d, "bottom")

        self.left   = Geometry::Rect.new(zero, dim.d, dim.h, "left")
        self.right  = Geometry::Rect.new(zero, dim.d, dim.h, "right")

        self.faces  = [top, front, bottom, back, left, right]
        self.bounds = []

        layout_faces
        self
      end

      def layout_faces
        #
        #               +-----------------+
        #               |                 |
        #               | back:     W x H |
        #               |                 |
        #               +-----------------+
        #               +-----------------+
        #               | bottom:   W x D |
        #               +-----------------+
        #   +--------+  +-----------------+  +--------+
        #   |        |  |                 |  |        |
        #   | left   |  | front:    W x H |  | right  |
        #   | D x H  |  |                 |  | D x H  |
        #   +--------+  +-----------------+  +--------+
        #               +-----------------+
        #               | top   :   W x D |
        #               +-----------------+
        #
        # 0,0
        #___________________________________________________________________


        offset = margin + padding + d + 3 * thick

        left.x = top.y = margin + thick

        [bottom, front, top, back].each do |s|
          s.x = offset
        end

        right.x = margin + 2 * padding + w + d + 5 * thick

        [left, front, right].each do |s|
          s.y = offset
        end

        bottom.y = margin + d + 2 * padding + h + 5 * thick
        back.y = margin + 3 * padding + 2 * d + h + 7*thick

        faces.each(&:relocate!)
        self.bounds = faces.map do |face|
          b = face.clone
          b.move_to(b.position.move_by(-thick, -thick))
          b.w += 2 * thick
          b.h += 2 * thick
          b.relocate!
          b
        end

        notch_up!
      end


      def notch_up!
        self.notches = []
        faces.each_with_index do |face, index|
          bound = bounds[index]
          bound.sides.each_with_index do |bounding_side, i1 |
            self.notches << notch_up_edge(face.sides[i1], bounding_side)
          end
        end
        self.notches.flatten!
      end

      def notch_up_edge(face_side, bounding_side)
        c_b = bounding_side.center
        c_s = face_side.center
        # puts "info: bound center: #{c_b}, face_side_center: #{c_s}"

        dim_along, dim_against, dnx, dny, dtx, dty = []

        if c_b.x == c_s.x
          dim_along = 0    # x dimension
          dim_against = 1
          dny = 0
          dnx = (c_b.y > c_s.y) ?  notch : notch
          dtx, dty = 0, thick
        else
          dim_along = 1    # x dimension
          dim_against = 0
          dnx, dny = 0, notch
          dtx, dty = thick, 0
        end
        #puts "info: dnx,dny,dtx,dty: #{dnx}, #{dny}, #{dtx}, #{dty}"
        points = []
        dir_against = (c_b.coordinates[dim_against] < c_s.coordinates[dim_against]) ? 1 : -1
        start_point = bounding_side.point1
        end_point   = bounding_side.point2
        dir_along   = 1
        procs = {1 => lambda { |p_current, p_end| p_current < p_end - notch/2 },
                 -1 => lambda { |p_current, p_end| p_current > p_end + notch/2 }}

        if bounding_side.point1.coordinates[dim_along] < bounding_side.point2.coordinates[dim_along]
          dir_along = 1
        else
          dir_along = -1
        end

        lines = []

        middle = true
        p = c_b
        while procs[dir_along].call(p.coordinates[dim_along], end_point.coordinates[dim_along])
          points << p.clone
          p = p.move_by(dir_along * (middle ? dnx / 2 : dnx),  dir_along * (middle ? dny / 2: dny))
          points << p.clone
          p = p.move_by(dir_against * dtx, dir_against * dty)
          dir_against = dir_against * (-1)
          middle = false
        end

        points.each_with_index do |p, index|
          lines << Geometry::Line.new(p, points[index + 1]) unless index >= (points.size - 2)
        end

        points = []
        dir_against = (c_b.coordinates[dim_against] < c_s.coordinates[dim_against]) ? 1 : -1
        middle = true
        p = c_b
        dir_along = dir_along * (-1)
        while procs[dir_along].call(p.coordinates[dim_along], start_point.coordinates[dim_along])
          points << p.clone
          p = p.move_by(dir_along * (middle ? dnx / 2 : dnx),  dir_along * (middle ? dny / 2: dny))
          points << p.clone
          p = p.move_by(dir_against * dtx, dir_against * dty)
          dir_against = dir_against * (-1)
          middle = false
        end

        points.each_with_index do |p, index|
          lines << Geometry::Line.new(p, points[index + 1]) unless index >= (points.size - 2)
        end

        lines
      end

      def w
        dim.w
      end

      def h
        dim.h
      end

      def d
        dim.d
      end

      def smallest_side
        [w,h,d].min()
      end


      def to_s
        "Box Parameters:\nH:#{dim.h} W:#{dim.w} D:#{dim.d}\nThickness:#{thick}, Notch:#{notch}"
      end
    end
  end
end
