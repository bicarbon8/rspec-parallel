require 'rspec'
require_rspec = if defined?(require_relative)
  lambda do |path|
    require_relative path
  end
else
  lambda do |path|
    require "rspec/#{path}"
  end
end

require_rspec['parallel/version']
require_rspec['parallel/configuration']
require_rspec['parallel/option_parser']
require_rspec['parallel/configuration_options']
require_rspec['parallel/command_line']
require_rspec['parallel/example_thread_runner']
require_rspec['parallel/example_group_thread_runner']
require_rspec['parallel/runner']

module RSpec
  # Returns the global [Configuration](RSpec/Core/Configuration) object. While you
  # _can_ use this method to access the configuration, the more common
  # convention is to use [RSpec.configure](RSpec#configure-class_method).
  #
  # @example
  #     RSpec.configuration.drb_port = 1234
  # @see RSpec.configure
  # @see Core::Configuration
  def self.configuration
    if block_given?
      RSpec.warn_deprecation <<-WARNING

*****************************************************************
DEPRECATION WARNING

* RSpec.configuration with a block is deprecated and has no effect.
* please use RSpec.configure with a block instead.

Called from #{caller(0)[1]}
*****************************************************************

WARNING
    end
    @configuration ||= RSpec::Parallel::Configuration.new
  end

  module Parallel
    class << RSpec::Core::ExampleGroup
      # Runs all the examples in this group in a separate thread for each
      def run_parallel(reporter, num_threads, mutex, used_threads)
        if RSpec.wants_to_quit
          RSpec.clear_remaining_example_groups if top_level?
          return
        end
        reporter.example_group_started(self)

        begin
          run_before_all_hooks(new)
          example_threads = RSpec::Parallel::ExampleThreadRunner.new(num_threads, used_threads)
          run_examples_parallel(reporter, example_threads, mutex)
          children.ordered.map {|child| child.run_parallel(reporter, num_threads, mutex, used_threads)}
          example_threads.wait_for_completion
        rescue Exception => ex
          RSpec.wants_to_quit = true if fail_fast?
          fail_filtered_examples(ex, reporter)
        ensure
          run_after_all_hooks(new)
          before_all_ivars.clear
          reporter.example_group_finished(self)
        end
      end

      # @private
      # Runs the examples in this group in a separate thread each
      def run_examples_parallel(reporter, threads, mutex)
        filtered_examples.ordered.map do |example|
          next if RSpec.wants_to_quit
          instance = new
          set_ivars(instance, before_all_ivars)
          mutex.synchronize do
            threads.run(example, instance, reporter)
          end
          RSpec.wants_to_quit = true if fail_fast?
        end
      end
    end
  end
end