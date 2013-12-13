Feature: detect changes

  Scenario: Yes for a single file, and no since file
    Given an empty file named "whatever"
    When I run `changes whatever --since non-existent`
    Then the exit status should be 0

  Scenario: No for a single file, older than the since file
    Given an empty file named "target"
      And an empty file named "since"
      And "since" is modified before "target"
    When I run `changes target --since since`
    Then the exit status should not be 0
