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

Then('property {string} of options is {string}') do |name, value|
   names = name.split(".")
   o = names[0...-1].reduce(space.options) {|os_, x| os_[x].nil? ? os_[x] = {}.to_os : os_[x].frozen? ? os_[x] = os_[x].dup : os_[x] }

   expect(o.send(names.last)).to eql(value)
end

Then('space\'s options {string} is {string}') do |name, value|
   names = name.split(".")
   o = names[0...-1].reduce(space.options) {|os_, x| os_[x].nil? ? os_[x] = {}.to_os : os_[x].frozen? ? os_[x] = os_[x].dup : os_[x] }

   expect(o[names.last]).to eql(value)
end

Then('property {string} of space is of kind {string}') do |property, kind|
   expect(space.send(property)).to be_kind_of(kind.constantize)
end

Then('space\'s options {string} is:') do |option, text|
   expect(space.options[option]).to match_record_yaml(text)
end

Then('property {string} of options is:') do |property, text|
   expect(space.options.send(property)).to match_record_yaml(text)
end

Then('space\'s property {string} is not blank') do |property|
   expect(space.send(property)).to_not be_blank
end
