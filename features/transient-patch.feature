Feature: Patch command available for the transient cache

  Scenario: Nested values from transient can be inserted at any depth.
    Given a WP install
    And I run `wp eval "set_transient( 'my_key', ['foo' => 'bar'] );"`
    And I run `wp eval "set_transient( 'my_key_2', ['foo' => ['bar' => 'baz']] );"`

    When I run `wp transient patch insert my_key fuz baz`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I run `wp transient get my_key --format=json`
    Then STDOUT should be:
      """
      {"foo":"bar","fuz":"baz"}
      """

    When I run `wp transient patch insert my_key foo bar`
    Then STDOUT should be:
      """
      Success: Value passed for transient 'my_key' is unchanged.
      """

    When I run `wp transient get my_key --format=json`
    Then STDOUT should be:
      """
      {"foo":"bar","fuz":"baz"}
      """

    When I run `wp transient patch insert my_key_2 foo fuz biz`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I run `wp transient get my_key_2 --format=json`
    Then STDOUT should be:
      """
      {"foo":{"bar":"baz","fuz":"biz"}}
      """

    When I run `wp transient patch insert my_key_2 foo bar baz`
    Then STDOUT should be:
      """
      Success: Value passed for transient 'my_key_2' is unchanged.
      """

    When I run `wp transient get my_key_2 --format=json`
    Then STDOUT should be:
      """
      {"foo":{"bar":"baz","fuz":"biz"}}
      """

  Scenario: Nested values from transient can be updated at any depth.
    Given a WP install
    And I run `wp eval "set_transient( 'my_key', ['foo' => 'bar'] );"`
    And I run `wp eval "set_transient( 'my_key_2', ['foo' => ['bar' => 'baz']] );"`

    When I run `wp transient patch update my_key foo baz`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I run `wp transient get my_key --format=json`
    Then STDOUT should be:
      """
      {"foo":"baz"}
      """

    When I run `wp transient patch update my_key foo baz`
    Then STDOUT should be:
      """
      Success: Value passed for transient 'my_key' is unchanged.
      """

    When I run `wp transient get my_key --format=json`
    Then STDOUT should be:
      """
      {"foo":"baz"}
      """

    When I run `wp transient patch update my_key_2 foo bar biz`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I run `wp transient get my_key_2 --format=json`
    Then STDOUT should be:
      """
      {"foo":{"bar":"biz"}}
      """

    When I run `wp transient patch update my_key_2 foo bar biz`
    Then STDOUT should be:
      """
      Success: Value passed for transient 'my_key_2' is unchanged.
      """

    When I run `wp transient get my_key_2 --format=json`
    Then STDOUT should be:
      """
      {"foo":{"bar":"biz"}}
      """

  Scenario: Nested values from transient can be deleted at any depth.
    Given a WP install
    And I run `wp eval "set_transient( 'my_key', ['foo' => 'bar'] );"`
    And I run `wp eval "set_transient( 'my_key_2', ['foo' => ['bar' => 'baz']] );"`

    When I run `wp transient patch delete my_key foo`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key'.
      """

    When I run `wp transient get my_key --format=json`
    Then STDOUT should be:
      """
      []
      """

    When I run `wp transient patch delete my_key_2 foo bar`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I run `wp transient get my_key_2 --format=json`
    Then STDOUT should be:
      """
      {"foo":[]}
      """

    When I run `wp transient patch delete my_key_2 foo`
    Then STDOUT should be:
      """
      Success: Updated transient 'my_key_2'.
      """

    When I run `wp transient get my_key_2 --format=json`
    Then STDOUT should be:
      """
      []
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
