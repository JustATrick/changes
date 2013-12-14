Feature: detect changes

  Scenario: change detected for single file and missing since file
    Given an empty file named "target"
    When I run `changes target --since non-existent`
    Then the exit status should be 0

  Scenario: single file without changes
    Given file "target" is modified before file "since"
    When I run `changes target --since since`
    Then the exit status should not be 0

  Scenario: single file with changes
    Given file "target" is modified after file "since"
     When I run `changes target --since since`
     Then the exit status should be 0

  Scenario: single directory without changes
    Given a directory named "target" with no file modified after file "since"
     When I run `changes target --since since`
     Then the exit status should not be 0

  Scenario: single directory with changes
    Given a directory named "target" with no file modified after file "since"
      And file "target/deeply/nested" is modified after file "since"
     When I run `changes target --since since`
     Then the exit status should be 0

  Scenario: multiple files without changes
    Given the following files were modified before file "since":
       | target1 |
       | target2 |
     When I run `changes target1 target2 --since since`
     Then the exit status should not be 0
