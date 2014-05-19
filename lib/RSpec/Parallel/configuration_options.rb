module RSpec
  module Parallel
    class ConfigurationOptions < RSpec::Core::ConfigurationOptions
      UNFORCED_OPTIONS = [
        :requires, :profile, :drb, :libs, :files_or_directories_to_run,
        :full_description, :full_backtrace, :tty, :thread_maximum
      ].to_set
    end
  end
end