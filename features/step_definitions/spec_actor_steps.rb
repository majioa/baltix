# vim:setl sw=3 sts=3 ts=3 et:
Given('default baltix setup') do
   # load baltix setup from a file
   cli.space = Baltix::Space.load_from(state: "features/fixtures/default.setup", options: cli.options)
end

When(/(?:he|developer) applies "([^"]*)" actor to the baltix setup/) do |actor_name|
   actor = Baltix::Actor.for(actor_name, space)
   @spec = actor.apply_to(space)
end

Then('he acquires a present spec for the baltix setup') do
   expect(@spec).to_not be_nil
end

When(/(?:developer|he) renders the template:/) do |text|
   @spec = Baltix::Actor.for('spec', space).apply_to(space, text)
end

Then('he gets the RPM spec') do |doc_string|
   expect(@spec).to eql(doc_string)
end

Then('he gets blank RPM spec') do
   expect(@spec).to eql("")
end
