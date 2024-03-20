# Baltix

Dependency detector, and spec generator and reader for projects based on the Ruby.

## Status

[![GitHub](http://img.shields.io/badge/github-majioa/baltix-blue.svg)](http://github.com/majioa/baltix)
[![GitHub tag](https://img.shields.io/github/tag/majioa/baltix.svg)](https://github.com/majioa/baltix/tags/)
[![Open Source? Yes!](https://badgen.net/badge/Open%20Source%20%3F/Yes%21/blue?icon=github)](https://github.com/majioa/baltix)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Ruby Github Action](https://github.com/majioa/baltix/actions/workflows/ci.yml/badge.svg)](https://github.com/majioa/baltix/actions/workflows/ci.yml)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/4d99e63d3d7349d5adfdbc4250666ef2)](https://app.codacy.com/gh/majioa/baltix/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![Codacy Badge](https://app.codacy.com/project/badge/Coverage/4d99e63d3d7349d5adfdbc4250666ef2)](https://app.codacy.com/gh/majioa/baltix/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_coverage)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/majioa/baltix/pulls)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'baltix', github: "majioa/baltix"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install baltix

## Usage

### From a Command Line

When you are creating a spec for the space from a scratch sample call may be as follows:

    $ sudo /usr/bin/setup.rb -o $(echo $(pwd)|sed "s|.*/||").spec  --maintainer-name="Pavel Skrylev" --maintainer-email="majioa@altlinux.org" -g/home/majioa/available-list.yaml spec --debug-io=- --verbose=debug --ignore-path-tokens=templates,example,examples,sample,samples,spec,test,features,fixtures,doc,docs,contrib,demo,acceptance,conformance,myapp,website,benchmarks,benchmark,gemfiles,misc,steep  2>/dev/null; sudo chown majioa:majioa . -R

When you are updating the spec do something like:

    $ sudo /usr/bin/setup.rb -s $(find -name "*.spec~") -o _.spec  --maintainer-name="Pavel Skrylev" --maintainer-email="majioa@altlinux.org" -g/home/majioa/available-list.yaml spec --debug-io=- --verbose=debug --ignore-path-tokens=templates,example,examples,sample,samples,spec,test,features,fixtures,doc,docs,contrib,demo,acceptance,conformance,myapp,website,benchmarks,benchmark,gemfiles,misc,steep  2>/dev/null; sudo chown majioa:majioa . -R


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Test

To run tests written in Cucumber's Gherkin just run:

    $ cucumber

or you are able to run them with rake as a default task:

    $ bundle exec rake

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/majioa/baltix.

