Feature: Manage WordPress transient cache

  Scenario: Transient CRUD
    Given a WP install

    When I try `wp transient get foo`
    Then STDERR should be:
      """
      Warning: Transient with key "foo" is not set.
      """

    When I run `wp transient set foo bar`
    Then STDOUT should be:
      """
      Success: Transient added.
      """

    When I run `wp transient get foo`
    Then STDOUT should be:
      """
      bar
      """

    When I run `wp transient delete foo`
    Then STDOUT should be:
      """
      Success: Transient deleted.
      """

  Scenario: Network transient CRUD
    Given a WP multisite install
    And I run `wp site create --slug=foo`

    When I run `wp transient set foo bar --network`
    Then STDOUT should be:
      """
      Success: Transient added.
      """

    When I run `wp --url=example.com/foo transient get foo --network`
    Then STDOUT should be:
      """
      bar
      """

    When I try `wp transient get foo`
    Then STDERR should be:
      """
      Warning: Transient with key "foo" is not set.
      """

    When I run `wp transient delete foo --network`
    Then STDOUT should be:
      """
      Success: Transient deleted.
      """

  Scenario: Deleting all transients on single site
    Given a WP install

    When I try `wp transient delete`
    Then STDERR should be:
      """
      Error: Please specify transient key, or use --all or --expired.
      """

    When I run `wp transient set foo bar`
    And I run `wp transient set foo2 bar2 600`
    And I run `wp transient set foo3 bar3 --network`
    And I run `wp transient set foo4 bar4 600 --network`
    And I run `wp transient delete --all`
    Then STDOUT should be:
      """
      Success: 2 transients deleted from the database.
      """

    When I try `wp transient get foo`
    Then STDERR should be:
      """
      Warning: Transient with key "foo" is not set.
      """

    When I try `wp transient get foo2`
    Then STDERR should be:
      """
      Warning: Transient with key "foo2" is not set.
      """

    When I run `wp transient get foo3 --network`
    Then STDOUT should be:
      """
      bar3
      """

    When I run `wp transient get foo4 --network`
    Then STDOUT should be:
      """
      bar4
      """

    When I run `wp transient delete --all --network`
    Then STDOUT should be:
      """
      Success: 2 transients deleted from the database.
      """

    When I try `wp transient get foo3 --network`
    Then STDERR should be:
      """
      Warning: Transient with key "foo3" is not set.
      """

    When I try `wp transient get foo4 --network`
    Then STDERR should be:
      """
      Warning: Transient with key "foo4" is not set.
      """

  Scenario: Deleting expired transients on single site
    Given a WP install
    And I run `wp transient set foo bar 60`
    And I run `wp transient set foo2 bar2 60`
    And I run `wp transient set foo3 bar3 60 --network`
    And I run `wp transient set foo4 bar4 60 --network`
    # Change timeout to be in the past.
    And I run `wp option update _transient_timeout_foo 1321009871`
    And I run `wp option update _site_transient_timeout_foo3 1321009871`

    When I run `wp transient delete --expired`
    Then STDOUT should be:
      """
      Success: 1 expired transient deleted from the database.
      """

    When I try `wp transient get foo`
    Then STDERR should be:
      """
      Warning: Transient with key "foo" is not set.
      """

    When I run `wp transient get foo2`
    Then STDOUT should be:
      """
      bar2
      """

    # Check if option still exists as a get transient call will remove it.
    When I run `wp option get _site_transient_foo3`
    Then STDOUT should be:
      """
      bar3
      """

    When I run `wp transient get foo4 --network`
    Then STDOUT should be:
      """
      bar4
      """

    When I run `wp transient delete --expired --network`
    Then STDOUT should be:
      """
      Success: 1 expired transient deleted from the database.
      """

    When I try `wp transient get foo`
    Then STDERR should be:
      """
      Warning: Transient with key "foo" is not set.
      """

    When I run `wp transient get foo2`
    Then STDOUT should be:
      """
      bar2
      """

    When I try `wp transient get foo3 --network`
    Then STDERR should be:
      """
      Warning: Transient with key "foo3" is not set.
      """

    When I run `wp transient get foo4 --network`
    Then STDOUT should be:
      """
      bar4
      """

  Scenario: Deleting all transients on multisite
    Given a WP multisite install
    And I run `wp site create --slug=foo`

    When I try `wp transient delete`
    Then STDERR should be:
      """
      Error: Please specify transient key, or use --all or --expired.
      """

    When I run `wp transient set foo bar`
    And I run `wp transient set foo2 bar2 600`
    And I run `wp transient set foo3 bar3 --network`
    And I run `wp transient set foo4 bar4 600 --network`
    And I run `wp --url=example.com/foo transient set foo5 bar5 --network`
    And I run `wp --url=example.com/foo transient set foo6 bar6 600 --network`
    And I run `wp transient delete --all`
    Then STDOUT should be:
      """
      Success: 2 transients deleted from the database.
      """

    When I try `wp transient get foo`
    Then STDERR should be:
      """
      Warning: Transient with key "foo" is not set.
      """

    When I try `wp transient get foo2`
    Then STDERR should be:
      """
      Warning: Transient with key "foo2" is not set.
      """

    When I run `wp transient get foo3 --network`
    Then STDOUT should be:
      """
      bar3
      """

    When I run `wp transient get foo4 --network`
    Then STDOUT should be:
      """
      bar4
      """

    When I run `wp --url=example.com/foo transient get foo5 --network`
    Then STDOUT should be:
      """
      bar5
      """

    When I run `wp --url=example.com/foo transient get foo6 --network`
    Then STDOUT should be:
      """
      bar6
      """

    When I run `wp transient delete --all --network`
    Then STDOUT should be:
      """
      Success: 4 transients deleted from the database.
      """

    When I try `wp transient get foo3 --network`
    Then STDERR should be:
      """
      Warning: Transient with key "foo3" is not set.
      """

    When I try `wp transient get foo4 --network`
    Then STDERR should be:
      """
      Warning: Transient with key "foo4" is not set.
      """

    When I try `wp --url=example.com/foo transient get foo5 --network`
    Then STDERR should be:
      """
      Warning: Transient with key "foo5" is not set.
      """

    When I try `wp --url=example.com/foo transient get foo6 --network`
    Then STDERR should be:
      """
      Warning: Transient with key "foo6" is not set.
      """

  Scenario: Deleting expired transients on multisite
    Given a WP multisite install
    And I run `wp site create --slug=foo`
    And I run `wp transient set foo bar 60`
    And I run `wp transient set foo2 bar2 60`
    And I run `wp transient set foo3 bar3 60 --network`
    And I run `wp transient set foo4 bar4 60 --network`
    And I run `wp --url=example.com/foo transient set foo5 bar5 60 --network`
    And I run `wp --url=example.com/foo transient set foo6 bar6 60 --network`
    # Change timeout to be in the past.
    And I run `wp option update _transient_timeout_foo 1321009871`
    And I run `wp site option update _site_transient_timeout_foo3 1321009871`
    And I run `wp --url=example.com/foo site option update _site_transient_timeout_foo5 1321009871`

    When I run `wp transient delete --expired`
    Then STDOUT should be:
      """
      Success: 1 expired transient deleted from the database.
      """

    When I try `wp transient get foo`
    Then STDERR should be:
      """
      Warning: Transient with key "foo" is not set.
      """

    When I run `wp transient get foo2`
    Then STDOUT should be:
      """
      bar2
      """

    # Check if option still exists as a get transient call will remove it.
    When I run `wp site option get _site_transient_foo3`
    Then STDOUT should be:
      """
      bar3
      """

    When I run `wp transient get foo4 --network`
    Then STDOUT should be:
      """
      bar4
      """

    # Check if option still exists as a get transient call will remove it.
    When I run `wp --url=example.com/foo site option get _site_transient_foo5`
    Then STDOUT should be:
      """
      bar5
      """

    When I run `wp --url=example.com/foo transient get foo6 --network`
    Then STDOUT should be:
      """
      bar6
      """

    When I run `wp transient delete --expired --network`
    Then STDOUT should be:
      """
      Success: 2 expired transients deleted from the database.
      """

    When I try `wp transient get foo`
    Then STDERR should be:
      """
      Warning: Transient with key "foo" is not set.
      """

    When I run `wp transient get foo2`
    Then STDOUT should be:
      """
      bar2
      """

    When I try `wp transient get foo3 --network`
    Then STDERR should be:
      """
      Warning: Transient with key "foo3" is not set.
      """

    When I run `wp transient get foo4 --network`
    Then STDOUT should be:
      """
      bar4
      """

    When I try `wp --url=example.com/foo transient get foo5 --network`
    Then STDERR should be:
      """
      Warning: Transient with key "foo5" is not set.
      """

    When I run `wp --url=example.com/foo transient get foo6 --network`
    Then STDOUT should be:
      """
      bar6
      """

    Scenario: List transients on single site
      Given a WP install
      And I run `wp transient set foo bar`
      And I run `wp transient set foo2 bar2 610`
      And I run `wp transient set foo3 bar3 --network`
      And I run `wp transient set foo4 bar4 610 --network`

      When I run `wp transient list --format=csv`
      Then STDOUT should be:
        """
        name,value,expiration
        foo,bar,"no expiration"
        foo2,bar2,"10 mins"
        """

      When I run `wp transient list --network --format=csv`
      Then STDOUT should be:
        """
        name,value,expiration
        foo3,bar3,"no expiration"
        foo4,bar4,"10 mins"
        """

    Scenario: List transients on multisite
      Given a WP multisite install
      And I run `wp transient set foo bar`
      And I run `wp transient set foo2 bar2 610`
      And I run `wp transient set foo3 bar3 --network`
      And I run `wp transient set foo4 bar4 610 --network`

      When I run `wp transient list --format=csv`
      Then STDOUT should be:
        """
        name,value,expiration
        foo,bar,"no expiration"
        foo2,bar2,"10 mins"
        """

      When I run `wp transient list --network --format=csv`
      Then STDOUT should be:
        """
        name,value,expiration
        foo3,bar3,"no expiration"
        foo4,bar4,"10 mins"
        """
