-- MindSpark DB Schema (MySQL compatible) — Custom tables for performance and scale
-- Use WP DB prefix replacement in deploy scripts (e.g., {wpdb->prefix}ms_age_groups)

-- Age groups
CREATE TABLE IF NOT EXISTS ms_age_groups (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  min_age TINYINT UNSIGNED DEFAULT NULL,
  max_age TINYINT UNSIGNED DEFAULT NULL,
  tagline VARCHAR(255) DEFAULT NULL,
  icon_svg TEXT,
  meta JSON DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY ux_ms_age_groups_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Topics
CREATE TABLE IF NOT EXISTS ms_topics (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  age_group_id INT UNSIGNED NOT NULL,
  title VARCHAR(191) NOT NULL,
  slug VARCHAR(191) NOT NULL,
  description TEXT,
  icon_svg TEXT,
  total_levels SMALLINT UNSIGNED DEFAULT 100,
  active TINYINT(1) DEFAULT 1,
  meta JSON DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (age_group_id) REFERENCES ms_age_groups(id) ON DELETE CASCADE,
  KEY ix_ms_topics_age_group (age_group_id),
  UNIQUE KEY ux_ms_topics_slug_age (slug, age_group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Levels
CREATE TABLE IF NOT EXISTS ms_levels (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  topic_id INT UNSIGNED NOT NULL,
  level_number SMALLINT UNSIGNED NOT NULL,
  question_count SMALLINT UNSIGNED DEFAULT 0,
  settings JSON DEFAULT NULL, -- e.g., { "time_limit": 0, "attempts_allowed": 0 }
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (topic_id) REFERENCES ms_topics(id) ON DELETE CASCADE,
  UNIQUE KEY ux_ms_levels_topic_level (topic_id, level_number),
  KEY ix_ms_levels_topic (topic_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Questions
CREATE TABLE IF NOT EXISTS ms_questions (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  level_id INT UNSIGNED NOT NULL,
  question_type ENUM('single','multiple','ordering','match','fill') NOT NULL DEFAULT 'single',
  content JSON NOT NULL,     -- { "text": "...", "media": { "images": [], "audio": null }, "alt": "" }
  options JSON NOT NULL,     -- array of option objects { id, content, media }
  correct JSON NOT NULL,     -- canonical answers (no secrets in client) - hashed or minimal
  explanation TEXT DEFAULT NULL,
  meta JSON DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (level_id) REFERENCES ms_levels(id) ON DELETE CASCADE,
  KEY ix_ms_questions_level (level_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User progress (aggregated best score)
CREATE TABLE IF NOT EXISTS ms_user_progress (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED DEFAULT NULL, -- null for guest; map on claim
  age_group_id INT UNSIGNED NOT NULL,
  topic_id INT UNSIGNED NOT NULL,
  level_id INT UNSIGNED NOT NULL,
  best_score TINYINT UNSIGNED DEFAULT 0,
  completed TINYINT(1) DEFAULT 0,
  attempts_count SMALLINT UNSIGNED DEFAULT 0,
  unlocked_at TIMESTAMP NULL DEFAULT NULL,
  last_attempt_at TIMESTAMP NULL DEFAULT NULL,
  meta JSON DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (age_group_id) REFERENCES ms_age_groups(id) ON DELETE CASCADE,
  FOREIGN KEY (topic_id) REFERENCES ms_topics(id) ON DELETE CASCADE,
  FOREIGN KEY (level_id) REFERENCES ms_levels(id) ON DELETE CASCADE,
  INDEX ix_ms_user_progress_user (user_id),
  INDEX ix_ms_user_progress_topic (topic_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Attempts (history)
CREATE TABLE IF NOT EXISTS ms_user_attempts (
  attempt_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED DEFAULT NULL,
  level_id INT UNSIGNED NOT NULL,
  score TINYINT UNSIGNED NOT NULL,
  answers JSON NOT NULL,
  time_taken INT UNSIGNED DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX ix_ms_user_attempts_user (user_id),
  INDEX ix_ms_user_attempts_level (level_id),
  FOREIGN KEY (level_id) REFERENCES ms_levels(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Badges (optional)
CREATE TABLE IF NOT EXISTS ms_badges (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  key_name VARCHAR(100) NOT NULL,
  title VARCHAR(191) NOT NULL,
  description TEXT,
  icon_svg TEXT,
  meta JSON DEFAULT NULL,
  UNIQUE KEY ux_ms_badges_key (key_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User badges junction
CREATE TABLE IF NOT EXISTS ms_user_badges (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  badge_id INT UNSIGNED NOT NULL,
  awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (badge_id) REFERENCES ms_badges(id),
  INDEX ix_ms_user_badges_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indexing notes:
-- - Frequently queried endpoints: topics by age_group, levels by topic, progress by user -> ensure these indexes exist.
-- - Consider partitioning attempts table if scale grows large.

-- End of schema