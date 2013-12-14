Feature: detect changes

  Scenario: change detected for single file and missing since file
    Given an empty file named "target"
    When I run `changes target --since non-existent`
    Then the exit status should be 0

  Scenario: no change detected for a single file older than the since file
    Given an empty file named "target"
      And an empty file named "since"
      And "since" is modified before "target"
    When I run `changes target --since since`
    Then the exit status should not be 0

  Scenario: change detected for a single file newer than the since file
    Given an empty file named "target"
      And an empty file named "since"
      And "target" is modified after "since"
     When I run `changes target --since since`
     Then the exit status should be 0
