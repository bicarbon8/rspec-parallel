# Run rspec tests in Parallel.

This gem will add some extra methods to rspec allowing for execution of examples in parallel by passing in an additional option of *--parallel-test* followed by the number of parallel threads to use.
The main concept and differentiator from other gems that allow for parallel execution of rspec tests (such as parallel_tests and prspec) is that this gem ensures that all suite, context and all before and after blocks are run only once while the before and after each blocks are run for each example. Additionally, all output formatters will report to a single output file instead of multiple files so there will be no need for consolidating results at the end of testing

### Supported RSpec Versions
- 2.14.8
    - rspec-parallel-2.14.8.x at [RubyGems.org](http://rubygems.org/gems/rspec-parallel)
    - rspec-parallel-2.14.8.x at [GitHub.com](https://github.com/bicarbon8/rspec-parallel/tree/2-14)
- 3.0.0 (coming soon)

### Build Gem
```ruby
gem build rspec-parallel.gemspec
```

### Install 
```ruby
gem install rspec-parallel-[version].gem
```
or get from rubygems.org
```ruby
gem install rspec-parallel
```

### Run
```
rspec --parallel-test 4          # run from the default 'spec' directory using 4 threads
```

### Examples
moved to wiki at [Examples](https://github.com/bicarbon8/rspec-parallel/wiki/Examples)

### Known Issues
- this gem must overwrite the rspec-core executable in order to allow for processing of the additional arguments. this can cause issues if using with the *bundler* gem as it may not be able to handle the overwrite and the arguments will then not be recognised

===================

Authors
====
inspired by [rspec-core pull request 1527](https://github.com/rspec/rspec-core/pull/1527)<br />
[Jason Holt Smith](https://github.com/bicarbon8)<br/>
bicarbon8@gmail.com<br/>
