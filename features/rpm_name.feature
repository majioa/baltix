@actor @spec
Feature: RPM Name module for Spec actor testing

   Scenario: PRM Name for library package validation
      Given an full name:
         """
         ruby-foo_bar.baz
         """
      When developer applies to parse the names with Name class
      Then he get name parsed as:
         | kind      |                                            |
         | name      | ruby-foo_bar.baz                           |
         | aliases   | [ruby-foo_bar.baz,foo_bar.baz,foo-bar-baz] |
         | suffix    |                                            |
         | prefix    |                                            |

   Scenario: PRM Name for doc package validation
      Given an full name:
         """
         ruby-foo_bar.baz-doc
         """
      When developer applies to parse the names with Name class
      Then he get name parsed as:
         | kind      |                                                  |
         | name      | ruby-foo_bar.baz-doc                             |
         | aliases   | [ruby-foo_bar.baz-doc,foo_bar.baz,foo-bar-baz]   |
         | suffix    |                                                  |
         | prefix    |                                                  |

   Scenario: PRM Name for devel package validation
      Given an full name:
         """
         gem-foo_bar.baz-devel
         """
      When developer applies to parse the names with Name class
      Then he get name parsed as:
         | kind      |                                                  |
         | name      | gem-foo_bar.baz-devel                            |
         | aliases   | [gem-foo_bar.baz-devel,foo_bar.baz,foo-bar-baz]  |
         | suffix    |                                                  |
         | prefix    |                                                  |

   Scenario: PRM Name for executable package validation
      Given an full name:
         """
         foo_bar.baz
         """
      When developer applies to parse the names with Name class
      And the name has support name object:
         | name      | foo_bar.baz  |
         | suffix    |              |
         | prefix    | gem          |
      Then he get name parsed as:
         | kind      |                                            |
         | name      | foo_bar.baz                                |
         | aliases   | [foo_bar.baz,foo-bar-baz,gem-foo-bar-baz]  |
         | suffix    |                                            |
         | prefix    |                                            |

   Scenario: PRM Name for application package validation
      Given an full name:
         """
         foo_bar.baz
         """
      When developer applies to parse the names with Name class
      Then he get name parsed as:
         | kind      |                             |
         | name      | foo_bar.baz                 |
         | aliases   | [foo_bar.baz,foo-bar-baz]   |
         | suffix    |                             |
         | prefix    |                             |

   Scenario: PRM Name object succeed match validation
      Given an full name:
         """
         gem-foo_bar.baz
         """
      And an full name:
         """
         ruby-foo-bar_baz
         """
      When developer applies to parse the names with Name class
      Then the "gem-foo_bar.baz" as "lib" matches to "ruby-foo-bar_baz" as "lib"

   Scenario: PRM Name object partly succeed match validation
      Given an full name:
         """
         gem-foo_bar.baz-doc
         """
      And an full name:
         """
         ruby-foo-bar_baz
         """
      When developer applies to parse the names with Name class
      Then the "gem-foo_bar.baz-doc" as "doc" matches to "ruby-foo-bar_baz" as "lib"
      And the names are matched in part of "kind"

   Scenario: PRM Name object failed match validation
      Given an full name:
         """
         gem-foo_bar.baz-doc
         """
      And an full name:
         """
         ruby-foo-bar_baz
         """
      When developer applies to parse the names with Name class
      Then the "gem-foo_bar.baz-doc" as "lib" don't match to "ruby-foo-bar_baz" as "lib"

   Scenario: PRM Name for validation
      Given an full name:
         """
         ruby-foo_bar.baz
         """
      When developer applies to parse the names with Name class
      Then the name's full name is :
         """
         ruby-foo-bar-baz
         """

   Scenario: Custom matching with kind lib
      Given a lib full name:
         """
         ruby-foo_bar.baz
         """
      Then the name matches to:
         """
         foo-bar-baz
         """
      And the name does't match to:
         """
         gem-foo-bar-baz
         """
