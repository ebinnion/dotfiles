#!/bin/sh

# A shell script that will create a new WordPress site for us.
#
# Based on post from Jeremy Herve:
# https://jeremy.hu/dev-environment-laravel-valet-wp-cli/

if [ $# -eq 0 ]
	then
		echo "What do you want your site to be called? No Spaces, just lowercase letters please."
		read site_name
	else
		site_name="$1"
fi

echo "Creating site with name: $site_name"

cd ~/Websites/ || exit

# Ensure the websites directory is parked
valet park

mkdir "$site_name"
cd "$site_name" || exit

# We will need a database for that WordPress site.
echo "CREATE DATABASE $site_name" | mysql -uroot -ppass

echo "Now let's install WordPress"
wp core download
wp config create --dbname="$site_name" --dbuser=root --dbpass='pass' --dbhost='127.0.0.1' --extra-php <<PHP
define( 'WP_DEBUG', true );

if ( WP_DEBUG ) {
		@error_reporting( E_ALL );
		@ini_set( 'log_errors', true );
		@ini_set( 'log_errors_max_len', '0' );

		define( 'WP_DEBUG_LOG', true );
		define( 'WP_DEBUG_DISPLAY', true );
		define( 'CONCATENATE_SCRIPTS', false );
		define( 'SAVEQUERIES', true );

		define( 'JETPACK_DEV_DEBUG', true );
}
PHP

wp core install \
	--url="$site_name.test" \
	--title="$site_name" \
	--admin_user=ebinnionadmin \
	--admin_password=password \
	--admin_email=ericbinnion+testadmin@gmail.com

exit 0;
