# vim:setl sw=3 sts=3 ts=3 et:
Given('space file:') do |text|
   @space_in = StringIO.open(text)
end

When('developer loads the space') do
   @space = Baltix::Space.load_from(state: @space_in)
end

When('developer loads the blank space') do
   @space = Baltix::Space.load_from(@space_in, rootdir: File.join(Dir.pwd, 'features/fixtures/blank'))
end

Then('he sees that space\'s {string} is a {string}') do |prop, value|
   expect(@space.send(prop)).to eql(value)
end

When('developer locks the time to {string}') do |time|
   Timecop.freeze(Time.parse(time))
end

When(/(?:he|developer) sets the space option "([^"]+)" to:/) do |option, text|
   space.options[option] = Baltix.load(text)
end

Then('space\'s valid sources has source {string}') do |name|
   names = space.valid_sources.map(&:name).map(&:to_s)

   expect(names).to include(name)
end

Then('space\'s sources has source {string}') do |name|
   names = space.sources.map(&:name).map(&:to_s)

   expect(names).to include(name)
end

Then('space\'s valid sources are blank') do
   expect(space.valid_sources).to be_blank
end

Then("space's valid sources contains not a real {string} source") do |name|
   source_names = space.valid_sources.reject {|x| x.is_a?(Baltix::Source::Fake)}.map {|x| x.name }
   expect(source_names).to_not include(name)
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
   expect(space_value_for(property)).to eql(text)
end

Then('space\'s property {string} is blank') do |property|
   expect(space_value_for(property)).to be_blank
end


