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
