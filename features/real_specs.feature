@actor @spec @gem
Feature: Spec actor

   @policy1_0 @gem_change @main_is_gem
   Scenario: Apply the Spec actor to setup for ucf gem and old Ruby Policy 1.0 setup
      Given blank space
      And a spec from fixture "ucf"
      When developer locks the time to "21.04.2021"
      And he sets the space option "rootdir" to fixture "ucf"
      And he sets the space option "maintainer_name" to "Pavel Skrylev"
      And he sets the space option "maintainer_email" to "majioa@altlinux.org"
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "ucf" fixture spec for the baltix setup

   @policy1_0 @gem_change @gem_obsolete_list @main_is_gem
   Scenario: Apply the Spec actor to setup for zip-container gem and old Ruby Policy 1.0 setup
      Given blank space
      And a spec from fixture "zip-container"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                                         |
         | rootdir               | features/fixtures/zip-container               |
         | use_gem_obsolete_list | {rubyzip: rubyzip}                            |
         | maintainer_name       | Pavel Skrylev                                 |
         | maintainer_email      | majioa@altlinux.org                           |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "zip-container" fixture spec for the baltix setup

   @policy1_0 @gem_change @olddoc @wrongdoc @main_is_gem
   Scenario: Apply the Spec actor to setup for kgio gem with Olddoc/Wrongdoc specification
         and old Ruby Policy 1.0 setup, where root main source is a gem so it doesnt parse
         the the prefix, and suffix, and just use a default in output spec
      Given blank space
      And a spec from fixture "kgio"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                                         |
         | rootdir               | features/fixtures/kgio                        |
         | maintainer_name       | Pavel Skrylev                                 |
         | maintainer_email      | majioa@altlinux.org                           |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "kgio" fixture spec for the baltix setup

   @policy2_0 @gem_change @main_is_gem
   Scenario: Apply the Spec actor to setup for rbvmomi gem and manual Ruby Policy 2.0 setup
         with optimize available gem list feature
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                                         |
         | rootdir            | features/fixtures/rbvmomi                     |
         | available_gem_list | {racc: 1.5.1, rake: '15.0', test-unit: '3.0'} |
         | maintainer_name    | Pavel Skrylev                                 |
         | maintainer_email   | majioa@altlinux.org                           |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "rbvmomi" fixture spec for the baltix setup

   @policy2_0 @release_change @main_is_gem
   Scenario: Apply the Spec actor to setup for rspec-support gem and manual Ruby Policy 2.0 setup
         with no gem version upgrade and skipping devel package
      Given blank space
      And a spec from fixture "rspec-support"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                             |
         | rootdir            | features/fixtures/rspec-support   |
         | devel_dep_setup    | :skip                             |
         | maintainer_name    | Pavel Skrylev                     |
         | maintainer_email   | majioa@altlinux.org               |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "rspec-support" fixture spec for the baltix setup

   @policy2_0 @gem_change @main_is_gem
   Scenario: Apply the Spec actor to setup for parser gem and manual Ruby Policy 2.0 setup
         with no gem version upgrade
      Given blank space
      And a spec from fixture "parser"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options                              | value                    |
         | rootdir                              | features/fixtures/parser |
         | available_gem_list                   | {racc: 1.5.1}            |
         | use_gem_version_list                 | parser:3.0.1.1           |
         | maintainer_name                      | Pavel Skrylev            |
         | maintainer_email                     | majioa@altlinux.org      |
         | high_default_dependencies_priority   | true                     |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "parser" fixture spec for the baltix setup

   @scratch @index_gemspec
   Scenario: Apply the Spec actor to setup for turn gem to blank setup
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                             |
         | rootdir               | features/fixtures/turn            |
         | available_gem_list    | {minitest: 5.14.0}                |
         | spec_type             | rpm                               |
         | maintainer_name       | Pavel Skrylev                     |
         | maintainer_email      | majioa@altlinux.org               |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "turn" fixture spec for the baltix setup

   @policy2_0 @gem_change
   Scenario: Apply the Spec actor to setup for ruby-gnome2 gemset and Ruby Policy pre 2.0 setup
      - expand %summary in descriptions
      - pickup core version from common versions of submodules
      - proper detection of host rpm name line ruby-gnome2 not to rename to gem-gnome2
      - autoskip packages when they lost gemspecs like ruby-gnome2 *-no-gi packages or gem-vte defined in the original spec
      - since the top source is an application / group, so it doesn't parse a prefix, and use no prefix then
      Given blank space
      And a spec from fixture "ruby-gnome2"
      When developer locks the time to "09.03.2022"
      And he sets the space options as:
         | options               | value                             |
         | rootdir               | features/fixtures/ruby-gnome2     |
         | available_gem_list    | {minitest: 5.14.0}                |
         | spec_type             | rpm                               |
         | ignored_names         | [rake]                            |
         | maintainer_name       | Pavel Skrylev                     |
         | maintainer_email      | majioa@altlinux.org               |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "ruby-gnome2" fixture spec for the baltix setup

   @scratch @hoe
   Scenario: Apply the Spec actor to setup for oedipus-lex gem to blank setup
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                             |
         | packager.name         | Ruby Maintainers Team             |
         | packager.email        | ruby@packages.altlinux.org        |
         | rootdir               | features/fixtures/oedipus-lex     |
         | spec_type             | rpm                               |
         | maintainer_name       | Pavel Skrylev                     |
         | maintainer_email      | majioa@altlinux.org               |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "oedipus-lex" fixture spec for the baltix setup

   @scratch @bones
   Scenario: Apply the Spec actor to setup for little-plugger gem to blank setup
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                             |
         | packager.name         | Ruby Maintainers Team             |
         | packager.email        | ruby@packages.altlinux.org        |
         | rootdir               | features/fixtures/little-plugger  |
         | spec_type             | rpm                               |
         | maintainer_name       | Pavel Skrylev                     |
         | maintainer_email      | majioa@altlinux.org               |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "little-plugger" fixture spec for the baltix setup

   @scratch @jeweler
   Scenario: Apply the Spec actor to setup for polyglot gem to blank setup
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                             |
         | packager.name         | Ruby Maintainers Team             |
         | packager.email        | ruby@packages.altlinux.org        |
         | rootdir               | features/fixtures/polyglot        |
         | spec_type             | rpm                               |
         | maintainer_name       | Pavel Skrylev                     |
         | maintainer_email      | majioa@altlinux.org               |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "polyglot" fixture spec for the baltix setup

   @scratch @echoe
   Scenario: Apply the Spec actor to setup for echoe gem to blank setup
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                             |
         | packager.name         | Ruby Maintainers Team             |
         | packager.email        | ruby@packages.altlinux.org        |
         | rootdir               | features/fixtures/echoe           |
         | spec_type             | rpm                               |
         | maintainer_name       | Pavel Skrylev                     |
         | maintainer_email      | majioa@altlinux.org               |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "echoe" fixture spec for the baltix setup

   @policy2_0 @gem_change @rename @baltix_packager
   Scenario: Apply the Spec actor to setup for ruby-debug-ide gem and Ruby Policy 2.0 setup
      - rename to proper name defined by gem spec
      - use baltix team as packager
      - filter out gems not required by an allowed (currently ruby) platform
      - separate the test and developent gem groups
      - detect required gems for check and build spaces separately
        in gemfile and ext using gem_install_dependencies
      - increment alt release in spec as major due to rename
      - detect required gems for run binaries
      Given blank space
      And a spec from fixture "ruby-debug-ide"
      When developer locks the time to "16.11.2024"
      And he sets the space options as:
         | options               | value                             |
         | rootdir               | features/fixtures/ruby-debug-ide  |
         | available_gem_list    | {rake: 13.2.1, test-unit: 3.6.2}  |
         | spec_type             | rpm                               |
         | packager.name         | Baltix Maintainers Team           |
         | packager.email        | baltix@packages.altlinux.org      |
         | autorender_name       | true                              |
         | maintainer_name       | Baltix Builder Bot                |
         | maintainer_email      | bbb@altlinux.org                  |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "ruby-debug-ide" fixture spec for the baltix setup
