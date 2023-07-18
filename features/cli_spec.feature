@cli
Feature: Baltix CLI

   Scenario: Baltix CLI rootdir validation
      Given blank baltix CLI
      And options for baltix CLI:
         """
         --rootdir=/var/tmp
         """
      When developer loads baltix executable
      Then property "rootdir" of space is "/var/tmp"


   Scenario: Baltix CLI ignore names validation
      Given blank baltix CLI
      And options for baltix CLI:
         """
         --ignore-names=psych
         """
      And the default option for "rootdir" is "features/fixtures/psych"
      When developer loads baltix executable
      Then property "ignored_names" of space has "psych"
      And space's property "sources.0.spec.name" is:
         """
         psych
         """
      And property "valid_sources" of space is blank


   Scenario: Baltix CLI regard names validation
      Given blank baltix CLI
      And options for baltix CLI:
         """
         --ignore-names=psych --regard-names=,psych,erubis
         """
      And the default option for "rootdir" is "features/fixtures/psych"
      When developer loads baltix executable
      Then property "ignored_names" of space isn't blank
      And property "regarded_names" of space matches to:
         """
         psych
         erubis
         """
      And space's property "sources.0.spec.name" is:
         """
         psych
         """
      And space's property "valid_sources.0.spec.name" is:
         """
         psych
         """


   Scenario: Baltix CLI output path validation
      Given blank baltix CLI
      And options for baltix CLI:
         """
         --output-file=/tmp/output
         """
      When developer loads baltix executable
      Then property "output_file" of options is "/tmp/output"

   Scenario: Baltix CLI spec file argument validation
      Given blank baltix CLI
      And options for baltix CLI:
         """
         --spec-file=features/fixtures/default.spec
         """
      When developer loads baltix executable
      Then space's options "spec_file" is "features/fixtures/default.spec"
      And space's property "spec" is not blank
      And property "spec" of space is of kind "Baltix::Spec::Rpm"

   Scenario: Baltix CLI maintainer metadata validation
      Given blank baltix CLI
      And options for baltix CLI:
         """
         --maintainer-name="Pavel Skrylev" --maintainer-email=majioa@altlinux.org
         """
      When developer loads baltix executable
      Then space's options "maintainer_name" is "Pavel Skrylev"
      And space's options "maintainer_email" is "majioa@altlinux.org"
      And property "maintainer_name" of options is "Pavel Skrylev"
      And property "maintainer_email" of options is "majioa@altlinux.org"

   Scenario: Baltix CLI maintainer metadata validation
      Given blank baltix CLI
      And options for baltix CLI:
         """
         --available-gem-list="features/fixtures/sample.available-gem-list.yaml"
         """
      When developer loads baltix executable
      Then space's options "available_gem_list" is:
         """
         ---
         rake: 13.0.1
         minitest: 5.14.0
         json:
          - 2.3.0
          - 2.3.1
         """
      And property "available_gem_list" of options is:
         """
         ---
         rake: 13.0.1
         minitest: 5.14.0
         json:
          - 2.3.0
          - 2.3.1
         """
