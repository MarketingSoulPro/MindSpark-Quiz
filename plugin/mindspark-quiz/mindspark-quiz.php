<?php
/**
 * Plugin Name: MindSpark Quiz
 * Description: A plugin for creating quizzes.
 * Version: 1.0
 * Author: MarketingSoulPro
 */

// Activation hook to run migrations
function mindspark_quiz_activate() {
    require_once plugin_dir_path(__FILE__) . 'inc/migrations.php';
    mindspark_quiz_run_migrations();
}
register_activation_hook(__FILE__, 'mindspark_quiz_activate');