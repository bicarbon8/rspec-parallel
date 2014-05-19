module RSpec
  module Parallel
    class Configuration < RSpec::Core::Configuration
      attr_accessor :thread_maximum

      def initialize
        super
        @thread_maximum = 1
      end
    end
  end
end