Feature: detect changes

  Scenario: a single file, and no since file
    Given an empty file named "whatever"
    When I run `changes whatever --since non-existent`
    Then the exit status should be 0
