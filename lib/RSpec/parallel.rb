RSpec::Support.define_optimized_require_for_rspec(:parallel) { |f| require_relative f }

%w[
  example_thread_runner
  example_group_thread_runner
  runner
].each { |name| RSpec::Support.require_rspec_parallel name }

module RSpec
  module Parallel
    # Runs all the examples in this group in a separate thread for each
    def RSpec::Core::ExampleGroup.run_parallel(reporter, num_threads, mutex, used_threads)
      if RSpec.world.wants_to_quit
        RSpec.world.clear_remaining_example_groups if top_level?
        return
      end
      reporter.example_group_started(self)

      begin
        run_before_context_hooks(new)
        example_threads = RSpec::Core::ExampleThreadRunner.new(num_threads, used_threads)
        run_examples_parallel(reporter, example_threads, mutex)
        ordering_strategy.order(children).map do |child| 
          ParallelExampleGroup.new(child).run_parallel(reporter, num_threads, mutex, used_threads) 
        end
        example_threads.wait_for_completion
      rescue Pending::SkipDeclaredInExample => ex
        for_filtered_examples(reporter) { |example| example.skip_with_exception(reporter, ex) }
      rescue Exception => ex
        RSpec.world.wants_to_quit = true if fail_fast?
        for_filtered_examples(reporter) { |example| example.fail_with_exception(reporter, ex) }
      ensure
        run_after_context_hooks(new)
        before_context_ivars.clear
        reporter.example_group_finished(self)
      end
    end

    # @private
    # Runs the examples in this group in a separate thread each
    def RSpec::Core::ExampleGroup.run_examples_parallel(reporter, threads, mutex)
      ordering_strategy.order(filtered_examples).map do |example|
        next if RSpec.world.wants_to_quit
        instance = new
        set_ivars(instance, before_context_ivars)
        mutex.synchronize do
          threads.run(example, instance, reporter)
        end
      end
    end

    def create_method(name, &block)
      self.class.send(:define_method, name, &block)
    end

    def create_attr(name)
      create_method("#{name}=".to_sym) do |val| 
          instance_variable_set("@" + name, val)
      end

      create_method(name.to_sym) do
          instance_variable_get("@" + name) 
      end
    end
  end
end