@search
Feature: Searching Brands

  Scenario: Searching brands when there are none
    When I send JSON
    And I send a GET request to "http://www.example.com/brands?q=foo"
    Then the JSON response should have "$..name" with a length of 0

  Scenario: Searching brands when there is one matching
    Given there is a brand named "Foo"
    When I send JSON
    And I send a GET request to "http://www.example.com/brands?q=foo"
    Then the JSON response should have "$..name" with a length of 1

  Scenario: Searching brands when there is one not matching
    Given there is a brand named "Bar"
    When I send JSON
    And I send a GET request to "http://www.example.com/brands?q=foo"
    Then the JSON response should have "$..name" with a length of 0

  Scenario: Searching brands when there is one matching, one not
    Given there is a brand named "Foo"
    And there is a brand named "Bar"
    When I send JSON
    And I send a GET request to "http://www.example.com/brands?q=foo"
    Then the JSON response should have "$..name" with a length of 1

