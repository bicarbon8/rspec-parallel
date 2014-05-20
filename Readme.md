# Run rspec tests in Parallel.

This gem will add some extra methods to rspec allowing for execution of examples in parallel by passing in an additional option of *--parallel-test* followed by the number of parallel threads to use.
The main concept and differentiator from other gems that allow for parallel execution of rspec tests (such as parallel_tests and prspec) is that this gem ensures that all suite, context and all before and after blocks are run only once while the before and after each blocks are run for each example. Additionally, all output formatters will report to a single output file instead of multiple files so there will be no need for consolidating results at the end of testing

### Build Gem
```ruby
gem build rspec-parallel.gemspec
```

### Install (current supported version of rspec is 2.14.x in the 2.14 branch of this repo)
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
#### Difference between rspec-parallel and other, similar gems
Using one spec file with 2 examples in a single example_group (the _describe_ block):
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
  it 'example 1' do 
    sleep 2; puts 'Example 1' 
  end
  it 'example 2' do 
    sleep 2; puts 'Example 2' 
  end
end
```
Comparison between _rspec-parallel_, _prspec_ and _parallel\_tests_

| ``` > rspec --parallel-test 2 ``` | ``` > prspec -n 2 ``` | ``` > parallel_rspec spec -n 2 ``` |
| --------------------------------- | --------------------- | ----------------------------- |
|     Before Suite<br />Before All<br />Before Each<br />Example 2<br />After Each<br />Before Each<br />Example 1<br />After Each<br />After All<br />After Suite<br /><br /><br />Finished in 2.01 seconds<br />2 examples, 0 failures<br /> |     Before Suite<br />Before Suite<br />Before All<br />Before All<br />Before Each<br />Example 1<br />Before Each<br />Example 2<br />After Each<br />After Each<br />After All<br />After All<br />After Suite<br />After Suite<br /><br /><br />Finished in 2.01 seconds<br />1 example, 0 failures<br />Finished in 2.01 seconds<br />1 example, 0 failures<br /> |     Before Suite<br />Before All<br />Before Each<br />Example 1<br />After Each<br />Before Each<br />Example 2<br />After Each<br />After All<br />After Suite<br /><br /><br />Finished in 4 seconds<br />examples, 0 failures<br /><br />2 examples, 0 failures<br /><br />Took 4.36225 seconds<br /> |
| Total execution time is 2.01 seconds (both examples run in parallel) | Total execution time is 2.01 seconds (both examples run in parallel) | Total execution time is 4.36 seconds (both examples run sequentially because parallel_tests splits by spec file, not example) |

Using two spec files with 2 examples in each (spec_helper.rb is used for before(:suite) to ensure both spec files have access to it):
```ruby
# spec_helper.rb
RSpec.configure do |config|
  config.before(:suite) { puts 'Before Suite' }
  config.after(:suite) { puts 'After Suite' }
end
```
```ruby
# one_spec.rb
require_relative 'spec_helper'

describe 'Parallel Testing' do
  before(:all) { puts 'Before All One' }
  before(:each) { puts 'Before Each One' }
  after(:each) { puts 'After Each One' }
  after(:all) { puts 'After All One' }

  it 'example 1' do 
    sleep 2; puts 'Example 1' 
  end
  it 'example 2' do 
    sleep 2; puts 'Example 2' 
  end
end
```
```ruby
# two_spec.rb
require_relative 'spec_helper'

describe 'Parallel Testing Two' do
  before(:all) { puts 'Before All Two' }
  before(:each) { puts 'Before Each Two' }
  after(:each) { puts 'After Each Two' }
  after(:all) { puts 'After All Two' }

  it 'example 3' do 
    sleep 2; puts 'Example 3' 
  end
  it 'example 4' do 
    sleep 2; puts 'Example 4' 
  end
end
```
Comparison between _rspec-parallel_, _prspec_ and _parallel\_tests_

| ``` > rspec --parallel-test 4 ``` | ``` > prspec -n 4 ``` | ``` > parallel_rspec spec -n 4 ``` |
| --------------------------------- | --------------------- | ----------------------------- |
|     Before Suite<br />Before All Two<br />Before All One<br />Before Each Two<br />Before Each Two<br />Before Each One<br />Before Each One<br />Example 3<br />After Each Two<br />Example 4<br />After Each Two<br />Example 2<br />After Each One<br />Example 1<br />After Each One<br />After All Two<br />After All<br />After Suite<br /><br /><br />Finished in 2.02 seconds<br />4 examples, 0 failures<br /> |     Before Suite<br />Before All Two<br />Before Each Two<br />Before Suite<br />Before All Two<br />Before Each Two<br />Before Suite<br />Before All One<br />Before Each One<br />Before Suite<br />Before All One<br />Before Each One<br />Example 4<br />After Each Two<br />After All Two<br />After Suite<br /><br /><br />Finished in 2.01 seconds<br />1 example, 0 failures<br />Example 3<br />After Each Two<br />After All Two<br />After Suite<br /><br /><br />Finished in 2.01 seconds<br />1 example, 0 failures<br />Example 2<br />After Each One<br />After All One<br />After Suite<br /><br /><br />Finished in 2.01 seconds<br />1 example, 0 failures<br />Example 1<br />After Each One<br />After All One<br />After Suite<br /><br /><br />Finished in 2.01 seconds<br />1 example, 0 failures<br /> |     Before Suite<br />Before All Two<br />Before Each Two<br />Before Suite<br />Before All One<br />Before Each One<br />Example 3<br />After Each Two<br />Before Each Two<br />Example 1<br />After Each One<br />Before Each One<br />Example 4<br />After Each Two<br />After All Two<br />After Suite<br /><br /><br />Finished in 4.01 seconds<br />examples, 0 failures<br />Example 2<br />After Each One<br />After All One<br />After Suite<br /><br /><br />Finished in 4 seconds<br />examples, 0 failures<br /><br />4 examples, 0 failures<br /><br />Took 4.406252 seconds<br /> |
| Total execution time is 2.02 seconds (all 4 examples run in parallel) | Total execution time is 2.01 seconds (all 4 examples run in parallel) | Total execution time is 4.40 seconds (both spec files run in parallel, but each example in the spec files is run sequentially because parallel_tests splits by spec file, not example) |

### Known Issues
n/a

===================

Authors
====
inspired by [rspec-core pull request 1527](https://github.com/rspec/rspec-core/pull/1527)<br />
[Jason Holt Smith](https://github.com/bicarbon8)<br/>
bicarbon8@gmail.com<br/>
