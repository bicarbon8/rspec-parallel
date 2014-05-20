require_relative 'spec_helper'

describe 'Parallel Testing Two' do
  before(:suite) { puts 'Before Suite Two' }
  before(:all) { puts 'Before All Two' }
  before(:each) { puts 'Before Each Two' }
  after(:each) { puts 'After Each Two' }
  after(:all) { puts 'After All Two' }
  after(:suite) { puts 'After Suite Two' }

  it 'example 3' do 
    sleep 2; puts 'Example 3' 
  end
  it 'example 4' do 
    sleep 2; puts 'Example 4' 
  end
end