module LaserCutter
  module Errors
    class CommandLineArgumentsError < RuntimeError;  end
    class ZeroValueNotAllowed < CommandLineArgumentsError; end
    class FileNotFound < CommandLineArgumentsError; end
  end
end
