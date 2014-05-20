module RSpec
  module Parallel
    class Parser < RSpec::Core::Parser
      def parse!(args)
        return {} if args.empty?

        convert_deprecated_args(args)

        options = args.delete('--tty') ? {:tty => true} : {}
        begin
          parser(options).parse(args)
          delete_next = false
          args.delete_if do |arg|
            if delete_next
              true
            elsif arg == '--parallel-test'
              delete_next = true
              true
            end
          end
          parser(options, true).parse!(args)
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

            parser.on('-v', '--version', 'Display the version.') do
              puts "rspec-parallel: #{RSpec::Parallel::Version::STRING}"
            end

            parser.on_tail('-h', '--help', "You're looking at it.") do
              puts parser
            end
          end
        end
      end
    end
  end
end