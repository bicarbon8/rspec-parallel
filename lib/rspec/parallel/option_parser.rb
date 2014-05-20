module RSpec
  module Parallel
    class Parser < RSpec::Core::Parser
      def parse!(args)
        return {} if args.empty?

        convert_deprecated_args(args)

        options = args.delete('--tty') ? {:tty => true} : {}
        delete_next = false
        removed_parallel = false
        parallel_value = nil
        args.delete_if do |arg|
          if delete_next
            parallel_value = arg
            true
          elsif arg == '--parallel-test'
            delete_next = true
            removed_parallel = true
            true
          end
        end
        begin
          parser(options, true).parse!(args)
          if removed_parallel
            args.push '--parallel-test'
            args.push parallel_value
            parser(options).parse!(args)
          end
        rescue OptionParser::InvalidOption => e
          abort "#{e.message}\n\nPlease use --help for a listing of valid options"
        end

        options
      end

      def parser(options, bypass = false)
        if bypass
          super(options)
        else
          OptionParser.new do |parser|
            parser.banner = "\n  **** Parallel Testing ****\n\n"

            parser.on('--parallel-test NUMBER', Integer, 'Run the tests with the specified number of parallel threads (default: 1).') do |n|
              options[:thread_maximum] = n || 1
            end
          end
        end
      end
    end
  end
end