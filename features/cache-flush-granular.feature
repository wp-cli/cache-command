Feature: Granular cache flushing operations

  @skip-object-cache
  Scenario: Flush specific post cache
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $cache_post = function(){
        // Prime the caches for the "Hello world!" post created by the install.
        get_post( 1 );
        get_post_meta( 1 );
        if ( false === wp_cache_get( 1, 'posts' ) || false === wp_cache_get( 1, 'post_meta' ) ) {
          WP_CLI::error( 'Cache was not primed.' );
        }
      };
      $verify_cache_cleared = function(){
        $post = wp_cache_get( 1, 'posts' );
        $meta = wp_cache_get( 1, 'post_meta' );
        if ( false !== $post || false !== $meta ) {
          WP_CLI::error( 'Cache was not properly cleared.' );
        }
      };
      WP_CLI::add_hook( 'before_invoke:cache flush-post', $cache_post );
      WP_CLI::add_hook( 'after_invoke:cache flush-post', $verify_cache_cleared );
      """

    When I run `wp cache flush-post 1`
    Then STDOUT should contain:
      """
      Success: Post cache for ID 1 cleared.
      """

  @skip-object-cache
  Scenario: Flush specific term cache
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $cache_term = function(){
        // Prime the caches for the "Uncategorized" term created by the install,
        // with a stale name so that a refreshed cache entry can be told apart.
        $term       = get_term( 1 )->data;
        $term->name = 'Stale';
        wp_cache_set( 1, $term, 'terms' );
        get_term_meta( 1 );
        if ( false === wp_cache_get( 1, 'term_meta' ) ) {
          WP_CLI::error( 'Cache was not primed.' );
        }
      };
      $verify_cache_cleared = function(){
        // Cleaning a category rebuilds the term hierarchy, which can re-cache
        // the term from the database, so only check that the stale entry is gone.
        $term = wp_cache_get( 1, 'terms' );
        $meta = wp_cache_get( 1, 'term_meta' );
        if ( ( false !== $term && 'Stale' === $term->name ) || false !== $meta ) {
          WP_CLI::error( 'Cache was not properly cleared.' );
        }
      };
      WP_CLI::add_hook( 'before_invoke:cache flush-term', $cache_term );
      WP_CLI::add_hook( 'after_invoke:cache flush-term', $verify_cache_cleared );
      """

    When I run `wp cache flush-term 1`
    Then STDOUT should contain:
      """
      Success: Term cache for ID 1 cleared.
      """

  @skip-object-cache
  Scenario: Flush cache for an existing term resolves its taxonomy
    Given a WP install

    When I run `wp cache flush-term 1`
    Then STDOUT should contain:
      """
      Success: Term cache for ID 1 cleared.
      """

  @skip-object-cache
  Scenario: Flush specific comment cache
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $cache_comment = function(){
        wp_cache_set( 42, array(), 'comment' );
        wp_cache_set( 42, array(), 'comment_meta' );
      };
      $verify_cache_cleared = function(){
        $comment = wp_cache_get( 42, 'comment' );
        $meta = wp_cache_get( 42, 'comment_meta' );
        if ( false !== $comment || false !== $meta ) {
          WP_CLI::error( 'Cache was not properly cleared.' );
        }
      };
      WP_CLI::add_hook( 'before_invoke:cache flush-comment', $cache_comment );
      WP_CLI::add_hook( 'after_invoke:cache flush-comment', $verify_cache_cleared );
      """

    When I run `wp cache flush-comment 42`
    Then STDOUT should contain:
      """
      Success: Comment cache for ID 42 cleared.
      """

  @skip-object-cache
  Scenario: Flush specific user cache
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $cache_user = function(){
        // Prime the caches for the admin user created by the install.
        get_userdata( 1 );
        get_user_meta( 1 );
        if ( false === wp_cache_get( 1, 'users' ) || false === wp_cache_get( 1, 'user_meta' ) ) {
          WP_CLI::error( 'Cache was not primed.' );
        }
      };
      $verify_cache_cleared = function(){
        $user = wp_cache_get( 1, 'users' );
        $meta = wp_cache_get( 1, 'user_meta' );
        if ( false !== $user || false !== $meta ) {
          WP_CLI::error( 'Cache was not properly cleared.' );
        }
      };
      WP_CLI::add_hook( 'before_invoke:cache flush-user', $cache_user );
      WP_CLI::add_hook( 'after_invoke:cache flush-user', $verify_cache_cleared );
      """

    When I run `wp cache flush-user 1`
    Then STDOUT should contain:
      """
      Success: User cache for ID 1 cleared.
      """

  @skip-object-cache
  Scenario: Flush specific option cache
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $cache_option = function(){
        wp_cache_set( 'my_option', 'value', 'options' );
        wp_cache_set( 'alloptions', array( 'my_option' => 'value' ), 'options' );
        wp_cache_set( 'notoptions', array( 'my_option' => true ), 'options' );
      };
      $verify_cache_cleared = function(){
        $option = wp_cache_get( 'my_option', 'options' );
        $alloptions = wp_cache_get( 'alloptions', 'options' );
        $notoptions = wp_cache_get( 'notoptions', 'options' );
        if ( false !== $option || false !== $alloptions || false !== $notoptions ) {
          WP_CLI::error( 'Cache was not properly cleared.' );
        }
      };
      WP_CLI::add_hook( 'before_invoke:cache flush-option', $cache_option );
      WP_CLI::add_hook( 'after_invoke:cache flush-option', $verify_cache_cleared );
      """

    When I run `wp cache flush-option my_option`
    Then STDOUT should contain:
      """
      Success: Option cache for 'my_option' cleared.
      """

  @skip-object-cache
  Scenario: Invalid post ID fails gracefully
    Given a WP install

    When I try `wp cache flush-post abc`
    Then STDERR should contain:
      """
      Please provide a valid post ID.
      """

  @skip-object-cache
  Scenario: Invalid term ID fails gracefully
    Given a WP install

    When I try `wp cache flush-term xyz`
    Then STDERR should contain:
      """
      Please provide a valid term ID.
      """

  @skip-object-cache
  Scenario: Invalid comment ID fails gracefully
    Given a WP install

    When I try `wp cache flush-comment notanumber`
    Then STDERR should contain:
      """
      Please provide a valid comment ID.
      """

  @skip-object-cache
  Scenario: Invalid user ID fails gracefully
    Given a WP install

    When I try `wp cache flush-user nope`
    Then STDERR should contain:
      """
      Please provide a valid user ID.
      """

  @skip-object-cache
  Scenario Outline: Non-positive or non-integer post IDs fail gracefully
    Given a WP install

    When I try `wp cache flush-post <id>`
    Then STDERR should contain:
      """
      Please provide a valid post ID.
      """

    Examples:
      | id  |
      | 0   |
      | -1  |
      | 1.5 |
      | 1e3 |

  @skip-object-cache
  Scenario Outline: Non-positive term IDs fail gracefully
    Given a WP install

    When I try `wp cache flush-term <id>`
    Then STDERR should contain:
      """
      Please provide a valid term ID.
      """

    Examples:
      | id |
      | 0  |
      | -1 |

  @skip-object-cache
  Scenario Outline: Non-positive comment IDs fail gracefully
    Given a WP install

    When I try `wp cache flush-comment <id>`
    Then STDERR should contain:
      """
      Please provide a valid comment ID.
      """

    Examples:
      | id |
      | 0  |
      | -1 |

  @skip-object-cache
  Scenario Outline: Non-positive user IDs fail gracefully
    Given a WP install

    When I try `wp cache flush-user <id>`
    Then STDERR should contain:
      """
      Please provide a valid user ID.
      """

    Examples:
      | id |
      | 0  |
      | -1 |

  @require-wp-6.1 @skip-object-cache
  Scenario: Flush all post caches on WordPress 6.1+
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $cache_posts = function(){
        wp_cache_set( 'post_1', array( 'ID' => 1 ), 'posts' );
        wp_cache_set( 'post_2', array( 'ID' => 2 ), 'posts' );
        wp_cache_set( 'meta_1', array( 'key' => 'value' ), 'post_meta' );
        wp_cache_set( 1, array( 1 ), 'category_relationships' );
      };
      $verify_group_cleared = function(){
        if ( function_exists( 'wp_cache_supports' ) && wp_cache_supports( 'flush_group' ) ) {
          $post1 = wp_cache_get( 'post_1', 'posts' );
          $post2 = wp_cache_get( 'post_2', 'posts' );
          $meta = wp_cache_get( 'meta_1', 'post_meta' );
          $rel = wp_cache_get( 1, 'category_relationships' );
          if ( false !== $post1 || false !== $post2 || false !== $meta || false !== $rel ) {
            WP_CLI::error( 'Group cache was not properly cleared.' );
          }
        }
      };
      WP_CLI::add_hook( 'before_invoke:cache flush-post', $cache_posts );
      WP_CLI::add_hook( 'after_invoke:cache flush-post', $verify_group_cleared );
      """

    When I run `wp cache flush-post`
    Then STDOUT should contain:
      """
      Success: Post caches cleared.
      """

  @require-wp-6.1 @skip-object-cache
  Scenario: Flush all term caches on WordPress 6.1+
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $cache_terms = function(){
        wp_cache_set( 'term_1', array( 'term_id' => 1 ), 'terms' );
        wp_cache_set( 'term_2', array( 'term_id' => 2 ), 'terms' );
        wp_cache_set( 'meta_1', array(), 'term_meta' );
      };
      $verify_group_cleared = function(){
        if ( function_exists( 'wp_cache_supports' ) && wp_cache_supports( 'flush_group' ) ) {
          $term1 = wp_cache_get( 'term_1', 'terms' );
          $term2 = wp_cache_get( 'term_2', 'terms' );
          $meta = wp_cache_get( 'meta_1', 'term_meta' );
          if ( false !== $term1 || false !== $term2 || false !== $meta ) {
            WP_CLI::error( 'Group cache was not properly cleared.' );
          }
        }
      };
      WP_CLI::add_hook( 'before_invoke:cache flush-term', $cache_terms );
      WP_CLI::add_hook( 'after_invoke:cache flush-term', $verify_group_cleared );
      """

    When I run `wp cache flush-term`
    Then STDOUT should contain:
      """
      Success: Term caches cleared.
      """

  @require-wp-6.1 @skip-object-cache
  Scenario: Flush all comment caches on WordPress 6.1+
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $cache_comments = function(){
        wp_cache_set( 'comment_1', array(), 'comment' );
        wp_cache_set( 'comment_2', array(), 'comment' );
        wp_cache_set( 'meta_1', array(), 'comment_meta' );
      };
      $verify_group_cleared = function(){
        if ( function_exists( 'wp_cache_supports' ) && wp_cache_supports( 'flush_group' ) ) {
          $comment1 = wp_cache_get( 'comment_1', 'comment' );
          $comment2 = wp_cache_get( 'comment_2', 'comment' );
          $meta = wp_cache_get( 'meta_1', 'comment_meta' );
          if ( false !== $comment1 || false !== $comment2 || false !== $meta ) {
            WP_CLI::error( 'Group cache was not properly cleared.' );
          }
        }
      };
      WP_CLI::add_hook( 'before_invoke:cache flush-comment', $cache_comments );
      WP_CLI::add_hook( 'after_invoke:cache flush-comment', $verify_group_cleared );
      """

    When I run `wp cache flush-comment`
    Then STDOUT should contain:
      """
      Success: Comment caches cleared.
      """

  @require-wp-6.1 @skip-object-cache
  Scenario: Flush all user caches on WordPress 6.1+
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $cache_users = function(){
        wp_cache_set( 'user_1', array( 'ID' => 1 ), 'users' );
        wp_cache_set( 'user_2', array( 'ID' => 2 ), 'users' );
        wp_cache_set( 'meta_1', array(), 'user_meta' );
        wp_cache_set( 'old@example.com', 1, 'useremail' );
        wp_cache_set( 'oldlogin', 1, 'userlogins' );
        wp_cache_set( 'oldslug', 1, 'userslugs' );
      };
      $verify_group_cleared = function(){
        if ( function_exists( 'wp_cache_supports' ) && wp_cache_supports( 'flush_group' ) ) {
          $user1 = wp_cache_get( 'user_1', 'users' );
          $user2 = wp_cache_get( 'user_2', 'users' );
          $meta = wp_cache_get( 'meta_1', 'user_meta' );
          $lookups = array(
            wp_cache_get( 'old@example.com', 'useremail' ),
            wp_cache_get( 'oldlogin', 'userlogins' ),
            wp_cache_get( 'oldslug', 'userslugs' ),
          );
          if ( false !== $user1 || false !== $user2 || false !== $meta || array( false, false, false ) !== $lookups ) {
            WP_CLI::error( 'Group cache was not properly cleared.' );
          }
        }
      };
      WP_CLI::add_hook( 'before_invoke:cache flush-user', $cache_users );
      WP_CLI::add_hook( 'after_invoke:cache flush-user', $verify_group_cleared );
      """

    When I run `wp cache flush-user`
    Then STDOUT should contain:
      """
      Success: User caches cleared.
      """

  @require-wp-6.1 @skip-object-cache
  Scenario: Flush all option caches on WordPress 6.1+
    Given a WP install
    And a wp-content/mu-plugins/test-harness.php file:
      """
      <?php
      $cache_options = function(){
        wp_cache_set( 'option1', 'value1', 'options' );
        wp_cache_set( 'option2', 'value2', 'options' );
      };
      $verify_group_cleared = function(){
        if ( function_exists( 'wp_cache_supports' ) && wp_cache_supports( 'flush_group' ) ) {
          $option1 = wp_cache_get( 'option1', 'options' );
          $option2 = wp_cache_get( 'option2', 'options' );
          if ( false !== $option1 || false !== $option2 ) {
            WP_CLI::error( 'Group cache was not properly cleared.' );
          }
        }
      };
      WP_CLI::add_hook( 'before_invoke:cache flush-option', $cache_options );
      WP_CLI::add_hook( 'after_invoke:cache flush-option', $verify_group_cleared );
      """

    When I run `wp cache flush-option`
    Then STDOUT should contain:
      """
      Success: Option caches cleared.
      """

  @less-than-wp-6.1
  Scenario: Flushing all post caches requires WordPress 6.1+
    Given a WP install

    When I try `wp cache flush-post`
    Then STDERR should be:
      """
      Error: Flushing all post caches requires WordPress 6.1+ and an object cache that supports group flushing.
      """
    And the return code should be 1
