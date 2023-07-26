require 'pry'
require 'shoulda-matchers/cucumber'
require 'timecop'
require 'simplecov'
require 'simplecov-lcov'

require 'baltix'
require 'baltix/cli'

SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
SimpleCov.start if ENV["COVERAGE"]

Shoulda::Matchers.configure do |config|
   config.integrate do |with|
      with.test_framework :cucumber
   end
end

After do
   instance_variables.reject do |name|
      name.to_s =~ /__/
   end.each do |name|
      instance_variable_set(name, nil)
   end

   Timecop.return
end
