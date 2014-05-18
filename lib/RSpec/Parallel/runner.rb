module RSpec
  module Parallel
    class Runner < RSpec::Core::Runner
      # Configures and runs a spec suite.
      #
      # @param err [IO] error stream
      # @param out [IO] output stream
      def run(err, out)
        setup(err, out)
        if @options.options[:thread_maximum].nil?
          run_specs(@world.ordered_example_groups)
        else
          require 'thread'
          run_specs_parallel(@world.ordered_example_groups)
        end
      end

      # Runs the provided example groups in parallel.
      #
      # @param example_groups [Array<RSpec::Core::ExampleGroup>] groups to run
      # @return [Fixnum] exit status code. 0 if all specs passed,
      #   or the configured failure exit code (1 by default) if specs
      #   failed.
      def run_specs_parallel(example_groups)
        @configuration.reporter.report(@world.example_count(example_groups)) do |reporter|
          begin
            hook_context = RSpec::Core::SuiteHookContext.new
            @configuration.hooks.run(:before, :suite, hook_context)
            
            group_threads = RSpec::Parallel::ExampleGroupThreadRunner.new(@configuration.thread_maximum)
            example_groups.each { |g| group_threads.run(g, reporter) }
            group_threads.wait_for_completion

            example_groups.all? do |g| 
              result_for_this_group = g.filtered_examples.all? { |example| example.metadata[:execution_result].exception.nil? }
              results_for_descendants = g.children.all? { |child| child.filtered_examples.all? { |example| example.metadata[:execution_result].exception.nil? } }
              result_for_this_group && results_for_descendants
            end ? 0 : @configuration.failure_exit_code
          ensure
            @configuration.hooks.run(:after, :suite, hook_context)
          end
        end
      end
    end
  end
end