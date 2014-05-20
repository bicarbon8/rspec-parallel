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

### Examples
Using the following spec file:
```ruby
RSpec.configure do |config|
  config.before(:suite) { puts 'Before Suite' }
  config.before(:all) { puts 'Before All' }
  config.before(:each) { puts 'Before Each' }
  config.after(:each) { puts 'After Each' }
  config.after(:all) { puts 'After All' }
  config.after(:suite) { puts 'After Suite' }
end

describe 'Parallel Testing' do
  it 'example 1' do sleep 2; puts 'Example 1' end
  it 'example 2' do sleep 2; puts 'Example 2' end
end
```
#### Difference between rspec-parallel and other, similar gems (like prspec)
``` 
> rspec --parallel-test 2
Before Suite
Before All
Before Each
Example 2
After Each
Before Each
Example 1
After Each
After All
After Suite


Finished in 2.01 seconds
2 examples, 0 failures
```
```
> prspec -n 2
Before Suite
Before Suite
Before All
Before All
Before Each
Example 1
Before Each
Example 2
After Each
After Each
After All
After All
After Suite
After Suite


Finished in 2.01 seconds
1 example, 0 failures
Finished in 2.01 seconds
1 example, 0 failures
```

### Known Issues
n/a

===================

Authors
====
inspired by [rspec-core pull request 1527](https://github.com/rspec/rspec-core/pull/1527)<br />
[Jason Holt Smith](https://github.com/bicarbon8)<br/>
bicarbon8@gmail.com<br/>
