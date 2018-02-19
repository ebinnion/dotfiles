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
wp core config --dbname="$site_name" --dbuser=root --dbpass='pass' --extra-php <<PHP
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

# Create an author user to help testing with permissions
wp user create ebinnionauthor ericbinnion+testauthor@gmail.com \
	--role=author \
	--user_pass=password

echo "Users on site:"
wp user list

echo "Generate some posts"
post_content=$( curl http://loripsum.net/api/5 )

count=0
while [ $count -lt 10 ]
do
	# Admin posts
	wp --user=ebinnionadmin post create \
		--post_content="$post_content" \
		--post_title="Admin post published $count" \
		--post_status=publish

	wp --user=ebinnionadmin post create \
		--post_content="$post_content" \
		--post_title="Admin post draft $count" \
		--post_status=draft

	wp --user=ebinnionadmin post create \
		--post_content="$post_content" \
		--post_title="Admin post auto-draft $count" \
		--post_status=auto-draft

	wp --user=ebinnionadmin post create \
		--post_content="$post_content" \
		--post_title="Admin post private $count" \
		--post_status=private \
		--post_password=password

	wp --user=ebinnionadmin post create \
		--post_content="$post_content" \
		--post_title="Admin post private $count" \
		--post_status=future \
		--post_date='2118-01-01 00:00:00' # TODO: Let's generate this somehow

	wp --user=ebinnionadmin post create \
		--post_content="$post_content" \
		--post_title="Admin post trash $count" \
		--post_status=trash

	# Author posts
	wp --user=ebinnionauthor post create \
		--post_content="$post_content" \
		--post_title="Author post published $count" \
		--post_status=publish

	wp --user=ebinnionauthor post create \
		--post_content="$post_content" \
		--post_title="Author post draft $count" \
		--post_status=draft

	wp --user=ebinnionauthor post create \
		--post_content="$post_content" \
		--post_title="Author post auto-draft $count" \
		--post_status=auto-draft

	wp --user=ebinnionauthor post create \
		--post_content="$post_content" \
		--post_title="Author post pending $count" \
		--post_status=pending

	(( count++ ))
done

exit 0;
