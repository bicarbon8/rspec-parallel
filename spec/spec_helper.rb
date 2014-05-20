RSpec.configure do |config|
  config.before(:suite) { puts 'Before Suite' }
  config.after(:suite) { puts 'After Suite' }
end