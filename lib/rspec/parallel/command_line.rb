module RSpec
  module Parallel
    class CommandLine < RSpec::Core::CommandLine
      def initialize(options, configuration=RSpec::configuration, world=RSpec::world)
        if Array === options
          options = ConfigurationOptions.new(options)
          options.parse_options
        end
        @options = options
        @configuration = configuration
        @world = world
      end

      # Configures and runs a suite
      #
      # @param [IO] err
      # @param [IO] out
      def run_parallel(err, out)
        @configuration.error_stream = err
        @configuration.output_stream ||= out
        @options.configure(@configuration)
        @configuration.load_spec_files
        @world.announce_filters

        @configuration.reporter.report(@world.example_count, @configuration.randomize? ? @configuration.seed : nil) do |reporter|
          begin
            @configuration.run_hook(:before, :suite)
            group_threads = RSpec::Parallel::ExampleGroupThreadRunner.new(@configuration.thread_maximum)
            @world.example_groups.ordered.map {|g| group_threads.run(g, reporter)}
            group_threads.wait_for_completion

            @world.example_groups.all? do |g| 
              result_for_this_group = g.filtered_examples.all? { |example| example.metadata[:execution_result].exception.nil? }
              results_for_descendants = g.children.all? { |child| child.filtered_examples.all? { |example| example.metadata[:execution_result].exception.nil? } }
              result_for_this_group && results_for_descendants
            end ? 0 : @configuration.failure_exit_code
          ensure
            @configuration.run_hook(:after, :suite)
          end
        end
      end
    end
  end
end