#!/bin/bash
set -euo pipefail

# Variables
readonly APACHE_LOG_DIR="/var/log/httpd"
readonly WP_CLI="/usr/local/bin/wp"
readonly WP_CLI_URL="https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"

# Log functions
log_info() {
    printf "[INFO] %s\n" "$*" 1>&2
}

log_error() {
    printf "[ERROR] %s\n" "$*" 1>&2
}

# Function to handle script exit
cleanup() {
    local result=$?
    log_info "Cleaning up before exit with status ${result}"
    exit "${result}"
}
trap cleanup EXIT ERR

# Install necessary packages
install_packages() {
    log_info "Updating the system and installing necessary packages"
    sudo yum update -y
    sudo yum install -y httpd php php-mysqlnd mysql curl
}

# Install WP-CLI
install_wp_cli() {
    log_info "Installing WP-CLI"
    curl -o wp-cli.phar "${WP_CLI_URL}"
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar "${WP_CLI}"
}

# Download WordPress
download_wordpress() {
    log_info "Downloading WordPress"
    sudo rm -rf /var/www/html/*
    sudo "${WP_CLI}" core download --allow-root --path="/var/www/html"
}

# Create wp-config.php
create_wp_config() {
    log_info "Creating wp-config.php"
    sudo "${WP_CLI}" config create --dbname="${db_name}" --dbuser="${db_user}" --dbpass="${db_password}" --dbhost="${db_host}" --allow-root --path="/var/www/html"
}

# Install WordPress
install_wordpress() {
    log_info "Installing WordPress"
    sudo "${WP_CLI}" core install --url="${site_url}" --title="${site_title}" --admin_user="${admin_user}" --admin_password="${admin_password}" --admin_email="${admin_email}" --allow-root --path="/var/www/html"
}

# Set permissions
set_permissions() {
    log_info "Setting permissions for WordPress files"
    sudo chown -R apache:apache /var/www/html
    sudo chmod -R 755 /var/www/html
}

# Create Apache Virtual Host configuration
create_apache_vhost() {
    log_info "Creating Apache Virtual Host configuration"
    sudo bash -c "cat <<'EOF' > /etc/httpd/conf.d/${site_url}.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName ${site_url}
    ServerAlias www.${site_url}
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <FilesMatch \.php$>
        SetHandler \"proxy:unix:/var/run/php-fpm/php-fpm.sock|fcgi://localhost/\"
    </FilesMatch>
</VirtualHost>
EOF"
}

# Enable the new site and disable the default site
enable_site() {
    log_info "Enabling the new site and disabling the default site"
    sudo systemctl enable httpd
    sudo systemctl start httpd
}

# Enable necessary Apache modules and restart Apache
restart_apache() {
    log_info "Enabling necessary Apache modules and restarting Apache"
    sudo systemctl restart httpd
}

# Main script execution
main() {
    install_packages
    install_wp_cli
    download_wordpress
    create_wp_config
    install_wordpress
    set_permissions
    create_apache_vhost
    enable_site
    restart_apache
}

main "$@"

