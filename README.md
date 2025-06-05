# Baltix

Dependency detector, and spec generator and reader for projects based on the Ruby.

## Status

[![altlinux.space](https://img.shields.io/badge/altlinux.space-majioa/baltix-blue.svg)](https://altlinux.space/majioa/baltix)
[![Gem Version](https://img.shields.io/gem/v/baltix)](https://altlinux.space/majioa/baltix)
[![Open Source? Yes!](https://badgen.net/badge/Open%20Source%20%3F/Yes%21/blue?icon=altlinux)](https://altlinux.space/majioa/baltix)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Latest Release](https://altlinux.space/majioa/baltix/badges/release.svg)](https://altlinux.space/majioa/baltix/releases)
[![Gitea Last Commit](https://img.shields.io/gitea/last-commit/majioa/baltix?gitea_url=https%3A%2F%2Faltlinux.space)](https://altlinux.space/majioa/baltix)
-[![AltLinuxTeam Action](https://altlinux.space/majioa/baltix/badges//workflows/ci.yml/badge.svg:)](https://altlinux.space/majioa/baltix/actions/workflows/ci.yml)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/4d99e63d3d7349d5adfdbc4250666ef2)](https://app.codacy.com/gh/majioa/baltix/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![Codacy Badge](https://app.codacy.com/project/badge/Coverage/4d99e63d3d7349d5adfdbc4250666ef2)](https://app.codacy.com/gh/majioa/baltix/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_coverage)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://altlinux.space/majioa/baltix/pulls)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'baltix', git: "https://altlinux.space/majioa/baltix"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install baltix

## Usage

### Confguration file

Create default config file for baltix, placed it to: ~/.baltix.yaml

```
---
maintainer:
   name: "Pavel Skrylev"
   email: "majioa@altlinux.org"
packager:
   name: "Baltix Maintaining Team"
   email: "baltix@packages.altlinux.org"
devel_dep_baltix: :include
log_level: :debug
warn_io: 'stderr'
error_io: 'stderr'
info_io: 'stdout'
debug_io:
high_default_dependencies_priority: false
autorender_name: false
skip_platforms: [:jruby]
```

### From a Command Line

When you are creating a spec for the space from a scratch sample call may be as follows:

    $ /usr/bin/baltix -o $(echo $(pwd)|sed "s|.*/||").spec -g/home/majioa/available-list.yaml spec

When you are updating the spec do something like:

    $ /usr/bin/baltix -s $(find -name "*.spec~") -o _.spec -g/home/majioa/available-list.yaml spec


## Development

After checking out the repo, run `exe/baltix` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Test

To run tests written in Cucumber's Gherkin just run:

    $ cucumber

or you are able to run them with rake as a default task:

    $ bundle exec rake

## Contributing

Bug reports and pull requests are welcome on AltLinux.space at https://altlinux.space/majioa/baltix.

