require 'chewy/rspec'

# Cleanup
Chewy.strategy(:bypass)

RSpec.configure do |config|
  config.before(:suite) do
    Chewy.massacre
  end

  config.before :each do
    Chewy.strategy :urgent
  end

  config.after :each do
    Chewy.strategy.pop
    Chewy.massacre
  end
end
