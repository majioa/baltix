@actor @spec @gem
Feature: Spec actor

   @policy1_0 @gem_change
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

   @policy1_0 @gem_change
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

   @policy2_0 @gem_change
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

   @policy2_0 @release_change
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

   @policy2_0 @gem_change
   Scenario: Apply the Spec actor to setup for rspec-support gem and manual Ruby Policy 2.0 setup
         with no gem version upgrade
      Given blank space
      And a spec from fixture "parser"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                             |
         | rootdir               | features/fixtures/parser          |
         | available_gem_list    | {racc: 1.5.1}                     |
         | use_gem_version_list  | parser:3.0.1.1                    |
         | maintainer_name       | Pavel Skrylev                     |
         | maintainer_email      | majioa@altlinux.org               |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "parser" fixture spec for the baltix setup

   @scratch @index_gemspec
   Scenario: Apply the Spec actor to setup for ucf gem and old Ruby Policy 1.0 setup
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
      Given blank space
      And a spec from fixture "ruby-gnome2"
      When developer locks the time to "09.03.2022"
      And he sets the space options as:
         | options               | value                             |
         | rootdir               | features/fixtures/ruby-gnome2     |
         | available_gem_list    | {minitest: 5.14.0}                |
         | spec_type             | rpm                               |
         | maintainer_name       | Pavel Skrylev                     |
         | maintainer_email      | majioa@altlinux.org               |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "ruby-gnome2" fixture spec for the baltix setup
