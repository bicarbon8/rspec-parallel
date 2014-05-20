require_relative 'spec_helper'

describe 'Parallel Testing' do
  before(:all) { puts 'Before All' }
  before(:each) { puts 'Before Each' }
  after(:each) { puts 'After Each' }
  after(:all) { puts 'After All' }

  it 'example 1' do 
    sleep 2; puts 'Example 1' 
  end
  it 'example 2' do 
    sleep 2; puts 'Example 2' 
  end
end