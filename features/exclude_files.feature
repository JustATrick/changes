Feature: exclude files and directories

  Scenario: change in excluded directory is not detected
    Given a directory named "target" with no file modified after file "since"
      And a directory named "target/changed" with one file modified after file "since"
     When I run `changes target --since since --but-not target/changed`
     Then the exit status should be 1

  Scenario: change in excluded file is not detected
    Given a directory named "target" with no file modified after file "since"
      And file "target/changed" is modified after file "since"
     When I run `changes target --since since --but-not target/changed`
     Then the exit status should be 1
