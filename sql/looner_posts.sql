-- Looner microblog (phone browser looner.com). Applied live+dev 2026-07-14.
CREATE TABLE IF NOT EXISTS looner_posts (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(32) NOT NULL,
  name VARCHAR(32) NOT NULL,
  message VARCHAR(200) NOT NULL,
  ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_id (id)
);
