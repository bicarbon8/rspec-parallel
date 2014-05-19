# Run rspec tests in Parallel.

This gem will add some extra methods to rspec allowing for execution of examples in parallel by passing in an additional option of *--parallel-test* followed by the number of parallel threads to use.
The main concept and differentiator from other gems that allow for parallel execution of rspec tests (such as parallel-tests and prspec) is that this gem ensures that all suite, context and all before and after blocks are run only once while the before and after each blocks are run for each example. Additionally, all output formatters will report to a single output file instead of multiple files so there will be no need for consolidating results at the end of testing

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

### Known Issues
n/a

===================

Authors
====
inspired by [rspec-core pull request 1527](https://github.com/rspec/rspec-core/pull/1527)<br />
[Jason Holt Smith](https://github.com/bicarbon8)<br/>
bicarbon8@gmail.com<br/>
