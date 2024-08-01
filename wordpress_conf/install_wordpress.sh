#!/bin/bash

# Update and install necessary packages
sudo yum update -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd php-redis mysql

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Configure Apache
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www

# Download and install WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/
sudo chown -R apache:apache /var/www/html/
sudo chmod -R 755 /var/www/html/

# Create WordPress configuration file
cat << EOF > /var/www/html/wp-config.php
<?php
define('DB_NAME', '${db_name}');
define('DB_USER', '${db_user}');
define('DB_PASSWORD', '${db_password}');
define('DB_HOST', '${db_host}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 */
define('AUTH_KEY', '$(openssl rand -base64 32)');
define('SECURE_AUTH_KEY', '$(openssl rand -base64 32)');
define('LOGGED_IN_KEY', '$(openssl rand -base64 32)');
define('NONCE_KEY', '$(openssl rand -base64 32)');
define('AUTH_SALT', '$(openssl rand -base64 32)');
define('SECURE_AUTH_SALT', '$(openssl rand -base64 32)');
define('LOGGED_IN_SALT', '$(openssl rand -base64 32)');
define('NONCE_SALT', '$(openssl rand -base64 32)');

/**#@-*/

/** Redis Cache Settings */
define('WP_CACHE', true);
define('WP_REDIS_HOST', '${redis_host}');
define('WP_REDIS_PORT', 6379);
define('WP_REDIS_TIMEOUT', 1);
define('WP_REDIS_READ_TIMEOUT', 1);
define('WP_REDIS_DATABASE', 0);

/**#@+
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
\$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined('ABSPATH') ) {
        define('ABSPATH', __DIR__ . '/');
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
EOF

# Restart Apache
sudo systemctl restart httpd

