# frozen_string_literal: true

require "chewy/rspec"

# Cleanup
Chewy.strategy :bypass

RSpec.configure do |config|
  config.before :suite do
    Chewy.massacre
  end

  config.before do
    Chewy.strategy :urgent
  end

  config.after do
    Chewy.strategy.pop
    Chewy.massacre
  end
end
