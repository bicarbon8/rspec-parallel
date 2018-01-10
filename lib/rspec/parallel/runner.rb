module RSpec
  module Parallel
    # Provides the main entry point to run a suite of RSpec examples.
    class Runner
      # @attr_reader
      # @private
      attr_reader :options, :configuration, :world

      # Register an `at_exit` hook that runs the suite when the process exits.
      #
      # @note This is not generally needed. The `rspec` command takes care
      #       of running examples for you without involving an `at_exit`
      #       hook. This is only needed if you are running specs using
      #       the `ruby` command, and even then, the normal way to invoke
      #       this is by requiring `rspec/autorun`.
      def self.autorun
        if autorun_disabled?
          RSpec.deprecate("Requiring `rspec/autorun` when running RSpec via the `rspec` command")
          return
        elsif installed_at_exit? || running_in_drb?
          return
        end

        at_exit { perform_at_exit }
        @installed_at_exit = true
      end

      # @private
      def self.perform_at_exit
        # Don't bother running any specs and just let the program terminate
        # if we got here due to an unrescued exception (anything other than
        # SystemExit, which is raised when somebody calls Kernel#exit).
        return unless $!.nil? || $!.is_a?(SystemExit)

        # We got here because either the end of the program was reached or
        # somebody called Kernel#exit. Run the specs and then override any
        # existing exit status with RSpec's exit status if any specs failed.
        invoke
      end

      # Runs the suite of specs and exits the process with an appropriate exit
      # code.
      def self.invoke
        disable_autorun!
        status = run(ARGV, $stderr, $stdout).to_i
        exit(status) if status != 0
      end

      # Run a suite of RSpec examples. Does not exit.
      #
      # This is used internally by RSpec to run a suite, but is available
      # for use by any other automation tool.
      #
      # If you want to run this multiple times in the same process, and you
      # want files like `spec_helper.rb` to be reloaded, be sure to load `load`
      # instead of `require`.
      #
      # @param args [Array] command-line-supported arguments
      # @param err [IO] error stream
      # @param out [IO] output stream
      # @return [Fixnum] exit status code. 0 if all specs passed,
      #   or the configured failure exit code (1 by default) if specs
      #   failed.
      def self.run(args, err=$stderr, out=$stdout)
        trap_interrupt
        options = ConfigurationOptions.new(args)

        if options.options[:runner]
          options.options[:runner].call(options, err, out)
        else
          new(options).run(err, out)
        end
      end

      # Runs the provided example groups in parallel.
      #
      # @param example_groups [Array<RSpec::Core::ExampleGroup>] groups to run
      # @return [Fixnum] exit status code. 0 if all specs passed,
      #   or the configured failure exit code (1 by default) if specs
      #   failed.
      def self.run_specs_parallel(example_groups)
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
