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
    # We set `WP_DEVELOPMENT_MODE` to stop WordPress from automatically creating
    # additional transients which cause some steps to fail when testing.
    And I run `wp config set WP_DEVELOPMENT_MODE all`
    And I run `wp config set DISABLE_WP_CRON true --raw`

    And I run `wp transient list --format=count`
    And save STDOUT as {EXISTING_TRANSIENTS}
    And I run `expr {EXISTING_TRANSIENTS} + 2`
    And save STDOUT as {EXPECTED_TRANSIENTS}

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
      Success: {EXPECTED_TRANSIENTS} transients deleted from the database.
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
    # We set `WP_DEVELOPMENT_MODE` to stop WordPress from automatically creating
    # additional transients which cause some steps to fail when testing.
    And I run `wp config set WP_DEVELOPMENT_MODE all`
    And I run `wp site create --slug=foo`
    And I run `wp transient list --format=count`
    And save STDOUT as {EXISTING_TRANSIENTS}
    And I run `expr {EXISTING_TRANSIENTS} + 2`
    And save STDOUT as {EXPECTED_TRANSIENTS}

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
      Success: {EXPECTED_TRANSIENTS} transients deleted from the database.
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
    And I run `wp option update _transient_timeout_foo2 95649119999`
    And I run `wp transient set foo3 bar3 300`
    And I run `wp option update _transient_timeout_foo3 1321009871`
    And I run `wp transient set foo4 bar4 --network`
    And I run `wp transient set foo5 bar5 610 --network`
    And I run `wp option update _site_transient_timeout_foo5 95649119999`
    And I run `wp transient set foo6 bar6 300 --network`
    And I run `wp option update _site_transient_timeout_foo6 1321009871`

    When I run `wp transient list --format=csv`
    Then STDOUT should contain:
      """
      foo,bar,false
      """
    And STDOUT should contain:
      """
      foo2,bar2,95649119999
      """
    And STDOUT should contain:
      """
      foo3,bar3,1321009871
      """

    When I run `wp transient list --format=csv --human-readable`
    Then STDOUT should contain:
      """
      foo,bar,"never expires"
      """
    And STDOUT should contain:
      """
      foo3,bar3,expired
      """
    And STDOUT should not contain:
      """
      foo2,bar2,95649119999
      """

    When I run `wp transient list --network --format=csv`
    Then STDOUT should contain:
      """
      foo4,bar4,false
      """
    And STDOUT should contain:
      """
      foo5,bar5,95649119999
      """
    And STDOUT should contain:
      """
      foo6,bar6,1321009871
      """

  Scenario: List transients on multisite
    Given a WP multisite install
    # We set `WP_DEVELOPMENT_MODE` to stop WordPress from automatically creating
    # additional transients which cause some steps to fail when testing.
    And I run `wp config set WP_DEVELOPMENT_MODE all`
    And I run `wp transient set foo bar`
    And I run `wp transient set foo2 bar2 610`
    And I run `wp option update _transient_timeout_foo2 95649119999`
    And I run `wp transient set foo3 bar3 300`
    And I run `wp option update _transient_timeout_foo3 1321009871`
    And I run `wp transient set foo4 bar4 --network`
    And I run `wp transient set foo5 bar5 610 --network`
    And I run `wp site option update _site_transient_timeout_foo5 95649119999`
    And I run `wp transient set foo6 bar6 300 --network`
    And I run `wp site option update _site_transient_timeout_foo6 1321009871`

    When I run `wp transient list --format=csv`
    Then STDOUT should contain:
      """
      foo,bar,false
      """
    And STDOUT should contain:
      """
      foo2,bar2,95649119999
      """
    And STDOUT should contain:
      """
      foo3,bar3,1321009871
      """

    When I run `wp transient list --format=csv --human-readable`
    Then STDOUT should contain:
      """
      foo,bar,"never expires"
      """
    And STDOUT should contain:
      """
      foo3,bar3,expired
      """
    And STDOUT should not contain:
      """
      foo2,bar2,95649119999
      """

    When I run `wp transient list --network --format=csv`
    Then STDOUT should contain:
      """
      foo4,bar4,false
      """
    And STDOUT should contain:
      """
      foo5,bar5,95649119999
      """
    And STDOUT should contain:
      """
      foo6,bar6,1321009871
      """

  Scenario: List transients with search and exclude pattern
    Given a WP install
    And I run `wp transient set foo bar`
    And I run `wp transient set foo2 bar2`
    And I run `wp transient set foo3 bar3`
    And I run `wp transient set foo4 bar4 --network`
    And I run `wp transient set foo5 bar5 --network`

    When I run `wp transient list --format=csv --fields=name --search="foo"`
    Then STDOUT should be:
      """
      name
      foo
      """

    When I run `wp transient list --format=csv --fields=name --search="foo*"`
    Then STDOUT should be:
      """
      name
      foo
      foo2
      foo3
      """

    When I run `wp transient list --format=csv --fields=name --search="*oo"`
    Then STDOUT should be:
      """
      name
      foo
      """

    When I run `wp transient list --format=csv --fields=name --search="*oo*"`
    Then STDOUT should be:
      """
      name
      foo
      foo2
      foo3
      """

    When I run `wp transient list --format=csv --fields=name --search="*oo?"`
    Then STDOUT should be:
      """
      name
      foo2
      foo3
      """

    When I run `wp transient list --format=csv --fields=name --search="foo?"`
    Then STDOUT should be:
      """
      name
      foo2
      foo3
      """

    When I run `wp transient list --format=csv --fields=name --search="doesnotexist*"`
    Then STDOUT should be:
      """
      name
      """

    When I run `wp transient list --format=csv --fields=name --search="foo*" --exclude="foo2"`
    Then STDOUT should be:
      """
      name
      foo
      foo3
      """

    When I run `wp transient list --format=csv --fields=name --search="foo*" --exclude="*3"`
    Then STDOUT should be:
      """
      name
      foo
      foo2
      """

    When I run `wp transient list --format=csv --fields=name --search="foo*" --exclude="foo?"`
    Then STDOUT should be:
      """
      name
      foo
      """

    When I run `wp transient list --format=csv --fields=name --search="foo*" --network`
    Then STDOUT should be:
      """
      name
      foo4
      foo5
      """

    When I run `wp transient list --format=csv --fields=name --search="foo*" --exclude="foo5" --network`
    Then STDOUT should be:
      """
      name
      foo4
      """

  Scenario: Nested values from transient can be retrieved at any depth.
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $set_foo = function(){
        set_transient( 'my_key', ['foo' => 'bar'] );
        set_transient( 'my_key_2', ['foo' => ['bar' => 'baz']] );
      };

      WP_CLI::add_hook( 'before_invoke:transient pluck', $set_foo );
      """

    When I try `wp transient pluck my_key foo`
    Then STDOUT should be:
      """
      bar
      """

    When I try `wp transient pluck my_key_2 foo bar`
    Then STDOUT should be:
      """
      baz
      """

  Scenario: Nested values from site transient can be retrieved at any depth.
    Given a WP multisite install
    And I run `wp site create --slug=foo`
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $set_foo = function(){
        set_site_transient( 'my_key', ['foo' => 'bar'] );
      };

      WP_CLI::add_hook( 'before_invoke:transient pluck', $set_foo );
      """

    When I try `wp transient pluck my_key foo --network`
    Then STDOUT should be:
      """
      bar
      """

    When I try `wp transient pluck my_key foo`
    Then STDERR should be:
      """
      Warning: Transient with key "my_key" is not set.
      """

  Scenario: Nested values from transient can be updated at any depth.
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $set_foo = function(){
        set_transient( 'my_key', ['foo' => 'bar'] );
        set_transient( 'my_key_2', ['foo' => ['bar' => 'baz']] );
      };

      WP_CLI::add_hook( 'before_invoke:transient patch', $set_foo );
      """

    When I try `wp transient patch insert my_key fuz baz`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I try `wp transient patch insert my_key_2 foo fuz bar`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I try `wp transient patch insert unknown_key foo bar`
    Then STDERR should be:
      """
      Error: Cannot create key "foo" on data type boolean
      """

    When I try `wp transient patch insert my_key foo bar`
    Then STDOUT should be:
      """
      Success: Value passed for transient 'my_key' is unchanged.
      """

    When I try `wp transient patch update my_key foo biz`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I try `wp transient patch update my_key_2 foo bar biz`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I try `wp transient patch update unknown_key foo bar`
    Then STDERR should be:
      """
      Error: No data exists for key "foo"
      """

    When I try `wp transient patch update my_key foo bar`
    Then STDOUT should be:
      """
      Success: Value passed for transient 'my_key' is unchanged.
      """

    When I try `wp transient patch delete my_key foo`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I try `wp transient patch delete my_key_2 foo bar`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I try `wp transient patch delete unknown_key foo`
    Then STDERR should be:
      """
      Error: No data exists for key "foo"
      """

    Scenario: Nested values from site transient can be updated at any depth.
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $set_foo = function(){
        set_site_transient( 'my_key', ['foo' => 'bar'] );
        set_site_transient( 'my_key_2', ['foo' => ['bar' => 'baz']] );
      };

      WP_CLI::add_hook( 'before_invoke:transient patch', $set_foo );
      """

    When I try `wp transient patch insert my_key fuz baz --network`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I try `wp transient patch insert my_key_2 foo fuz bar --network`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I try `wp transient patch insert unknown_key foo bar --network`
    Then STDERR should be:
      """
      Error: Cannot create key "foo" on data type boolean
      """

    When I try `wp transient patch insert my_key foo bar --network`
    Then STDOUT should be:
      """
      Success: Value passed for transient 'my_key' is unchanged.
      """

    When I try `wp transient patch update my_key foo biz --network`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I try `wp transient patch update my_key_2 foo bar biz --network`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I try `wp transient patch update unknown_key foo bar --network`
    Then STDERR should be:
      """
      Error: No data exists for key "foo"
      """

    When I try `wp transient patch update my_key foo bar --network`
    Then STDOUT should be:
      """
      Success: Value passed for transient 'my_key' is unchanged.
      """

    When I try `wp transient patch delete my_key foo --network`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I try `wp transient patch delete my_key_2 foo bar --network`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I try `wp transient patch delete unknown_key foo --network`
    Then STDERR should be:
      """
      Error: No data exists for key "foo"
      """
