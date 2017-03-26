Feature: Register statement
  Statements are registered from a company page

  Scenario: Register a new statement
    Given company "Cucumber Ltd" has been submitted
    When Patricia submits the following statement for "Cucumber Ltd":
      | url                | https://cucumber.io/anti-slavery-statement |
      | signed_by_director | no                                         |
      | board_approval     | yes                                        |
      | link_on_homepage   | no                                         |
    Then Patricia should see 1 statement for "Cucumber Ltd"