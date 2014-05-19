module RSpec
  module Parallel
    class Runner < RSpec::Core::Runner
      # Run a suite of RSpec examples.
      #
      # This is used internally by RSpec to run a suite, but is available
      # for use by any other automation tool.
      #
      # If you want to run this multiple times in the same process, and you
      # want files like spec_helper.rb to be reloaded, be sure to load `load`
      # instead of `require`.
      #
      # #### Parameters
      # * +args+ - an array of command-line-supported arguments
      # * +err+ - error stream (Default: $stderr)
      # * +out+ - output stream (Default: $stdout)
      #
      # #### Returns
      # * +Fixnum+ - exit status code (0/1)
      def self.run(args, err=$stderr, out=$stdout)
        trap_interrupt
        options = ConfigurationOptions.new(args)
        options.parse_options

        parallel = (options.options[:thread_maximum].nil?) ? false : true

        if options.options[:drb]
          require 'rspec/core/drb_command_line'
          begin
            DRbCommandLine.new(options).run(err, out)
          rescue DRb::DRbConnError
            err.puts "No DRb server is running. Running in local process instead ..."
            if parallel
              CommandLine.new(options).run_parallel(err, out)
            else
              CommandLine.new(options).run(err, out)
            end
          end
        else
          if parallel
            CommandLine.new(options).run_parallel(err, out)
          else
            CommandLine.new(options).run(err, out)
          end
        end
      ensure
        RSpec.reset
      end
    end
  end
end