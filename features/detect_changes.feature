Feature: detect changes

  Scenario: change detected for single file and missing since file
    Given an empty file named "target"
    When I run `changes target --since non-existent`
    Then the exit status should be 0

  Scenario: no change detected for a single file older than the since file
    Given file "target" is modified before file "since"
    When I run `changes target --since since`
    Then the exit status should not be 0

  Scenario: change detected for a single file newer than the since file
    Given file "target" is modified after file "since"
     When I run `changes target --since since`
     Then the exit status should be 0

  Scenario: no change detected for a directory where all nested files older
            than the since file
    Given a directory named "target" with no file modified after file "since"
     When I run `changes target --since since`
     Then the exit status should not be 0

  Scenario: change detected for a directory with one nested file newer
            then the since file
    Given a directory named "target" with no file modified after file "since"
      And file "target/deeply/nested" is modified after file "since"
     When I run `changes target --since since`
     Then the exit status should be 0
