#!/bin/sh

# A shell script to delete a test site.
#
# Based on post from Jeremy Herve:
# https://jeremy.hu/dev-environment-laravel-valet-wp-cli/

if [ $# -eq 0 ]
	then
		echo "Which site do you want to delete?"
		read site_name
	else
		site_name="$1"
fi

echo "Deleting site with name: $site_name"

cd ~/Websites/ || exit
cd "$site_name"
valet forget
cd ../ || exit
rm -rf "$site_name"

# Delete the matching database table.
echo "DROP DATABASE IF EXISTS $site_name" | mysql -uroot -ppass

exit 0;
