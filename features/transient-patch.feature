Feature: Patch command available for the transient cache

  Scenario: Nested values from transient can be updated at any depth.
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """php
      <?php
      $set_foo = function(){
        set_transient( 'my_key', ['foo' => 'bar'] );
        set_transient( 'my_key_2', ['foo' => ['bar' => 'baz']] );
      };

      WP_CLI::add_hook( 'before_invoke:transient patch', $set_foo );
      """

    When I run `wp transient patch insert my_key fuz baz`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I run `wp transient patch insert my_key_2 foo fuz bar`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I try `wp transient patch insert unknown_key foo bar`
    Then STDERR should be:
      """
      Error: Cannot create key "foo" on data type boolean
      """

    When I run `wp transient patch insert my_key foo bar`
    Then STDOUT should be:
      """
      Success: Value passed for transient 'my_key' is unchanged.
      """

    When I run `wp transient patch update my_key foo biz`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I run `wp transient patch update my_key_2 foo bar biz`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I try `wp transient patch update unknown_key foo bar`
    Then STDERR should be:
      """
      Error: No data exists for key "foo"
      """

    When I run `wp transient patch update my_key foo bar`
    Then STDOUT should be:
      """
      Success: Value passed for transient 'my_key' is unchanged.
      """

    When I run `wp transient patch delete my_key foo`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I run `wp transient patch delete my_key_2 foo bar`
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
      """php
      <?php
      $set_foo = function(){
        set_site_transient( 'my_key', ['foo' => 'bar'] );
        set_site_transient( 'my_key_2', ['foo' => ['bar' => 'baz']] );
      };

      WP_CLI::add_hook( 'before_invoke:transient patch', $set_foo );
      """

    When I run `wp transient patch insert my_key fuz baz --network`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I run `wp transient patch insert my_key_2 foo fuz bar --network`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I try `wp transient patch insert unknown_key foo bar --network`
    Then STDERR should be:
      """
      Error: Cannot create key "foo" on data type boolean
      """

    When I run `wp transient patch insert my_key foo bar --network`
    Then STDOUT should be:
      """
      Success: Value passed for transient 'my_key' is unchanged.
      """

    When I run `wp transient patch update my_key foo biz --network`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I run `wp transient patch update my_key_2 foo bar biz --network`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I try `wp transient patch update unknown_key foo bar --network`
    Then STDERR should be:
      """
      Error: No data exists for key "foo"
      """

    When I run `wp transient patch update my_key foo bar --network`
    Then STDOUT should be:
      """
      Success: Value passed for transient 'my_key' is unchanged.
      """

    When I run `wp transient patch delete my_key foo --network`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I run `wp transient patch delete my_key_2 foo bar --network`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I try `wp transient patch delete unknown_key foo --network`
    Then STDERR should be:
      """
      Error: No data exists for key "foo"
      """
