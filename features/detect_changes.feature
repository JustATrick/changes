Feature: detect changes

  Scenario: change detected for single file and missing since file
    Given an empty file named "target"
    When I run `changes target --since non-existent`
    Then the exit status should be 0

  Scenario Outline: single file
    Given file "unchanged" is modified before file "since"
      And file "changed" is modified after file "since"
     When I run `changes <Target> --since since`
     Then the exit status <Exit Status>

    Examples:
      | Target    | Exit Status     |
      | unchanged | should not be 0 |
      | changed   | should be 0     |

  Scenario Outline: single directory
    Given a directory named "unchanged" with no file modified after file "since"
      And a directory named "changed" with one file modified after file "since"
     When I run `changes <Target> --since since`
     Then the exit status <Exit Status>

    Examples:
      | Target    | Exit Status     |
      | unchanged | should not be 0 |
      | changed   | should be 0     |

  Scenario Outline: multiple targets
    Given file "unchanged-file" is modified before file "since"
      And file "changed-file" is modified after file "since"
      And a directory named "unchanged-dir" with no file modified after file "since"
      And a directory named "changed-dir" with one file modified after file "since"
     When I run `changes <Targets> --since since`
     Then the exit status <Exit Status>

    Examples:
      | Targets                      | Exit Status     |
      | unchanged-file unchanged-dir | should not be 0 |
      | unchanged-dir unchanged-file | should not be 0 |
      | changed-file unchanged-dir   | should be 0     |
      | unchanged-dir changed-file   | should be 0     |
      | changed-dir unchanged-file   | should be 0     |
      | unchanged-file changed-dir   | should be 0     |
