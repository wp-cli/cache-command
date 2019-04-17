<?php

if ( ! class_exists( 'WP_CLI' ) ) {
	return;
}

$wp_cli_cache_autoloader = dirname( __FILE__ ) . '/vendor/autoload.php';
if ( file_exists( $wp_cli_cache_autoloader ) ) {
	require_once $wp_cli_cache_autoloader;
}

WP_CLI::add_command( 'cache', 'Cache_Command' );
WP_CLI::add_command( 'transient', 'Transient_Command' );
