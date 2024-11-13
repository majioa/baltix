Given('an full name:') do |text|
   name_list << text
end

Given('an app full name:') do |text|
   @name = Baltix::Spec::Rpm::Name.parse(Baltix.load(text), kind: "app")
end

Given('a lib full name:') do |text|
   @name = Baltix::Spec::Rpm::Name.parse(Baltix.load(text), kind: "lib")
end

When('developer applies to parse the names with Name class') do
   names.replace(name_list.map { |n | Baltix::Spec::Rpm::Name.parse(n) })
end

Then('he get name parsed as:') do |table|
   table.raw.to_h.each do |attr, value|
      expect(names.first.send(attr)).to match_record_yaml(value)
   end
end

When('the name has support name object:') do |table|
   attrs = table.raw.to_h
   names.first.support_name =
     Baltix::Spec::Rpm::Name.new(prefix: attrs["prefix"], suffix: adopt_value(attrs["suffix"]), name: attrs["name"])
end

Then('the names are fully matched:') do
   names.combination(2).each { |(n1, n2)| expect(n1.eql?(n2)).to be_truthy }
end

Then('the names are matched in part of {string}') do |attr|
   names.combination(2).each { |(n1, n2)| expect(n1.eql_by?(attr.to_sym, n2)).to be_truthy }
end

Then('the {string} as {string} matches to {string} as {string}') do |name1, kind1, name2, kind2|
   n1 = names.find {|x| x.name == name1 }
   n2 = names.find {|x| x.name == name2 }
   expect(n1.as(kind1).eql_by?(:name, n2.as(kind2))).to be_truthy
end

Then('the {string} as {string} don\'t match to {string} as {string}') do |name1, kind1, name2, kind2|
   n1 = names.find {|x| x.name == name1 }
   n2 = names.find {|x| x.name == name2 }
   expect(n1.as(kind1).eql_by?(:name, n2.as(kind2))).to be_falsey
end


Then('the names are not matched in part of {string}') do |attr|
   names.combination(2).each { |(n1, n2)| expect(n1.eql_by?(attr.to_sym, n2)).to be_falsey }
end

Then('the names are fully not matched') do
   names.combination(2).each { |(n1, n2)| expect(n1.eql?(n2)).to be_falsey }
end

Then('the name\'s full name is :') do |text|
   expect(names.first.fullname).to eql(text)
end

Then('the name matches to:') do |text|
   second = Baltix::Spec::Rpm::Name.parse(Baltix.load(text))
   expect(@name).to eql(second)
end

Then('the name does\'t match to:') do |text|
   second = Baltix::Spec::Rpm::Name.parse(Baltix.load(text))
   expect(@name).not_to eql(second)
end
