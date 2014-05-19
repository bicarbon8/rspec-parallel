module RSpec
  module Parallel
    class ConfigurationOptions < RSpec::Core::ConfigurationOptions
      NON_FORCED_OPTIONS = [
        :debug, :requires, :profile, :drb, :libs, :files_or_directories_to_run,
        :line_numbers, :full_description, :full_backtrace, :tty, :thread_maximum
      ].to_set

      def env_options
        ENV["SPEC_OPTS"] ? RSpec::Parallel::Parser.parse!(Shellwords.split(ENV["SPEC_OPTS"])) : {}
      end

      def command_line_options
        @command_line_options ||= RSpec::Parallel::Parser.parse!(@args).merge :files_or_directories_to_run => @args
      end
    end
  end
end