#!/bin/bash

function check_all_rubies()
{
	version_message=`ruby --version`
	if [ $? -ne 0 ]; then
		echo "You need to have ruby 1.8.7 or later installed on your system."
		echo ""
		echo "Please install ruby 1.8.7 or later and try again."

		exit -1
	else
		version=`echo $version_message | cut -d ' ' -f 2`
		major=`echo $version | cut -d '.' -f 1`
		minor=`echo $version | cut -d '.' -f 2`

		if [[ $major -lt 1 || ($major -eq 1 && $minor -lt 8) ]]; then
			echo "You need to have ruby 1.8.7 or later installed on your system. The ruby version you have is not supported."
			echo ""
			echo "Please upgrade to ruby 1.8.7 or later and try again."

			exit -1
		fi
	fi

	version_message=`gem --version`
	if [ $? -ne 0 ]; then
		echo "You need to have rubygems installed on your machine."
		echo ""
		echo "Please install rubygems and try again."

		exit -1
	fi
}

#calabash-ios
function check_and_update_gems()
{
	gem list | grep bundler
	if [ $? -ne 0 ]; then
		gem install bundler
	fi

	gem list | grep cucumber
	if [ $? -ne 0 ]; then
		gem install cucumber
	fi

	gem list | grep calabash-cucumber
	if [ $? -ne 0 ]; then
		gem install calabash-cucumber
	fi
}
check_all_rubies
check_and_update_gems
bundle install

if [ ! -f conf/db.conf ]
then
	touch conf/db.conf
	echo "host : $sqlhost" >> conf/db.conf
	echo "username : $sqluser" >> conf/db.conf
	echo "password : $sqlpass" >> conf/db.conf
	echo "database : $sqldb" >> conf/db.conf
fi


#add beacon log 
mkdir -p tmp
touch tmp/beacon.log
#add mailcatch



