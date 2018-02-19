#!/bin/sh

# A shell script that will create a local WordPress site and get
# the latest coding test for the applicant

echo "What is the trials's WordPress.com username?"
read applicant

echo "Creating site to test coding test for $applicant"

coding_tests_dir="$HOME/Documents/hiring/trials"
applicant_test_dir="$coding_tests_dir/$applicant"

if [ ! -d "$coding_tests_dir" ]; then
	echo "Bailing because coding test directory does not exist at $coding_tests_dir"
	exit 1;
fi

if [ ! -d "$applicant_test_dir" ]; then
	echo "Bailing because $applicant directory does not exist!"
	exit 1;
fi

# Ensure we have the latest from SVN
cd "$coding_tests_dir" || exit;
svn up

# Create test WordPress site
# TODO: Should probably check status code here
cd $(dirname $BASH_SOURCE)
cd ../wordpress || exit;
sh ./create_site.sh "$applicant"

applicant_test_site_dir="$HOME/Websites/$applicant"

# Now copy over the plugin to the test site
cp -R "$applicant_test_dir" "$applicant_test_site_dir/wp-content/plugins/drafts"

cd $applicant_test_sir || exit;
valet park
