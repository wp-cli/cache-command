Feature: Pluck command available for the transient cache

  Scenario: Nested values from transient can be retrieved at any depth.
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """php
      <?php
      $set_foo = function(){
        set_transient( 'my_key', ['foo' => 'bar'] );
        set_transient( 'my_key_2', ['foo' => ['bar' => 'baz']] );
      };

      WP_CLI::add_hook( 'before_invoke:transient pluck', $set_foo );
      """

    When I run `wp transient pluck my_key foo`
    Then STDOUT should be:
      """
      bar
      """

    When I run `wp transient pluck my_key_2 foo bar`
    Then STDOUT should be:
      """
      baz
      """

  Scenario: Nested values from site transient can be retrieved at any depth.
    Given a WP multisite install
    And I run `wp site create --slug=foo`
    And a wp-content/mu-plugins/test-harness.php file:
      """php
      <?php
      $set_foo = function(){
        set_site_transient( 'my_key', ['foo' => 'bar'] );
      };

      WP_CLI::add_hook( 'before_invoke:transient pluck', $set_foo );
      """

    When I run `wp transient pluck my_key foo --network`
    Then STDOUT should be:
    """
    bar
    """

    When I try `wp transient pluck my_key foo`
    Then STDERR should be:
    """
    Warning: Transient with key "my_key" is not set.
    """
