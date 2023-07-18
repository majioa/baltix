Given('options for baltix CLI:') do |text|
   subs = []
   args =
      text.gsub(/"[^"]*"/) do |m|
         i = subs.size
         /"([^"]*)"/ =~ m
         subs << $1
         "\x1#{i.chr}"
      end.split(/\s+/).map do |token|
         token.gsub(/\x1./) do |chr|
            /\x1(.)/ =~ chr
            subs[$1.ord]
         end
      end

   cli.option_parser.default_argv = args
end

Given('blank baltix CLI') do
   @cli = nil
   cli.option_parser.default_argv = []
end

Given('the default option for {string} is {string}') do |name, value|
   cli.options[name] = value
end

When('developer loads baltix executable') do
   cli.run
end

Then('property {string} of space is blank') do |property|
   expect(space.send(property)).to be_blank
end

Then('property {string} of space isn\'t blank') do |property|
   expect(space.send(property)).to_not be_blank
end

Then('property {string} of space matches to:') do |property, text|
   expect(space.send(property)).to match(text.split("\n"))
end

Then('space\'s property {string} is:') do |property, text|
   value = property.split(".").reduce(space) do |object, sub|
      sub =~ /^\d+$/ && object[sub.to_i] || object.respond_to?(sub) && object.send(sub) || nil
   end

   expect(value).to eql(text)
end

Then('space\'s property {string} is blank') do |property|
   value = property.split(".").reduce(space) do |object, sub|
      sub =~ /^\d+$/ && object[sub.to_i] || object.respond_to?(sub) && object.send(sub) || nil
   end

   expect(value).to be_blank
end

Then('property {string} of options is {string}') do |property, value|
   expect(space.options.send(property)).to eql(value)
end

Then('space\'s options {string} is {string}') do |option, value|
   expect(space.options[option]).to eql(value)
end

Then('property {string} of space is of kind {string}') do |property, kind|
   expect(space.send(property)).to be_kind_of(kind.constantize)
end

Then('space\'s options {string} is:') do |option, text|
   expect(space.options[option]).to eql(YAML.load(text))
end

Then('property {string} of options is:') do |property, text|
   expect(space.options.send(property)).to eql(YAML.load(text))
end

Then('space\'s property {string} is not blank') do |property|
   expect(space.send(property)).to_not be_blank
end
