require 'forwardable'
module Laser
  module Cutter
    # Note: this class badly needs refactoring and tests.  Both are coming.


    class Face
      attr_accessor :edges, :rect
      extend Forwardable
      def_delegators :@rect, *((Geometry::Rect.new(Geometry::Point.new(0,0), Geometry::Point.new(1,1))).methods - Object.methods)
      def initialize(rect, edges = [])
        self.rect  = rect
        self.edges = edges
      end
    end

  end
end
