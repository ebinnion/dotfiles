#!/bin/sh

# A shell script that will create a local WordPress site and get
# the latest coding test for the applicant

echo "What is the applicant's WordPress.com username?"
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

cd "$applicant_test_site_dir" || exit;

# Create an author user to help testing with permissions
wp user create ebinnionauthor ericbinnion+testauthor@gmail.com \
	--role=author \
	--user_pass=password

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
