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