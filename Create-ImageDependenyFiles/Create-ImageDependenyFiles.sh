#!/bin/bash

# USAGE:
#
# Builds the hardening manifest, and downloads all packages, defaults to pull from the python-packages.txt file
# ./Build-HardenginManifest.sh afcai2c/jlab-dl:latest jlab-nlp-linux-packages.txt jlab-nlp-python-packages.txt jlab-nlp \"redhat_account\" 'redhat_password'"
# $0 = The script itself
# $1 = Dockerimage to use as a bast to download packages
# $2 = Path to linux packages file, use na if not need
# $3 = Path to python packages file, use na if not needed
# $4 = Name to be used during the tarball creation of rpms, ex: NameProvided-rpm.tar.gz
# $5 = Redhat Username
# $6 = RedHat Password
# 
# Example contents of python-packages.txt or user_created_packages_files.txt
# tensorflow
# plotly
# matplotlib
# numpy
# ..etc
#
# Currently, doesn't support downloading specific versions and only pulls the latests
#

# Terminal Colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

# Checks if any arguments are provided
if [ $# -eq 0 ]; then
	echo "${red}[!] ${green}Error: ${reset}No Arguments Provided"
	echo "${red}[!] ${green}Example Command Syntax:${reset}${reset}
    ./Build-HardenginManifest.sh afcai2c/jlab-dl:latest jlab-nlp-linux-packages.txt jlab-nlp-python-packages.txt jlab-nlp \"redhat_account\" 'redhat_password'"
	echo "${red}[!] ${green}Arugment Description:${reset}${reset}
    ${yellow}\$0 ${reset}= The script itself
    ${yellow}\$1 ${reset}= Dockerimage to use as a bast to download packages
    ${yellow}\$2 ${reset}= Path to linux packages file, use na if not need
    ${yellow}\$3 ${reset}= Path to python packages file, use na if not needed
    ${yellow}\$4 ${reset}= Name to be used during the tarball creation of rpms, ex: NameProvided-rpm.tar.gz
    ${yellow}\$5 ${reset}= Redhat Username
    ${yellow}\$6 ${reset}= RedHat Password"
	exit
fi

rm ./hardening_manifest.yaml 2> /dev/null
rm -rf ./repo 2> /dev/null
mkdir ./repo 2> /dev/null

echo '-----------------------------'
# packages required for the script to function
python3 -m pip install -r requirements/requirements.txt --user  2> /dev/null

# bulids a temporary image and tags it, another Dockerfile is used to add future features in the 
# docker build --no-cache --build-arg BASE_DOCKER_IMAGE=$1 --tag python-download-deps ./build/
#docker build --no-cache --build-arg BASE_DOCKER_IMAGE=$1 --build-arg REDHAT_USERNAME=$3 --build-arg REDHAT_PASSWORD=$4 --tag python-download-deps ./build/
echo -e "${red}[!] ${green}Building Docker Image: ${reset}python-download-deps:latest"
docker build --build-arg BASE_DOCKER_IMAGE=$1 --build-arg REDHAT_USERNAME=$5 --build-arg REDHAT_PASSWORD=$6 --tag python-download-deps ./build/

# URL to manage and remove past RedHat EPEL subscriptions
# https://access.redhat.com/management/systems


# Removes previous containers built from the image name of "python-download-deps:latest"
CONTAINER_ID=$(docker ps -a | grep python-download-deps:latest | tr -s ' ' | cut -d ' ' -f1)
ID_COUNT=$(echo $CONTAINER_ID | wc | tr -s ' ' | cut -d ' ' -f 3)

if [ "$ID_COUNT" > 0 ]; then
	for id in $CONTAINER_ID; do
		echo -e "${red}[!] ${green}Removing Previous python-download-deps:latest Containers: ${reset}$id"
		docker rm -f $id 1> /dev/null
	done
fi

# Runs the image in the background and keeps it alive with a pseudo-terminal
echo -e -n "${red}[!] ${green}Creating python-download-deps:latest Container: ${reset}"
docker run -dt -h DOCKER_BUILDER -v $(pwd)/repo:/tmp -u root --entrypoint bash python-download-deps:latest 1> /dev/null
CONTAINER_ID=$(docker ps -a | grep python-download-deps:latest | tr -s ' ' | cut -d ' ' -f1)
echo -e "$CONTAINER_ID"


##################
# Linux Packages #
##################

# Updates the Linux Package Repositories
echo -e -n "${red}[!] ${green}Updating Linux Package Repositories: ${reset}"
docker exec -u root $CONTAINER_ID dnf update -y > /dev/null 2>&1
echo -e "Completed"


FILE=./linux-packages.txt
if [ $2 ]; then
	PACKAGES=$2
	echo "${red}[!] ${green}Using Provided Linux Package List: ${reset}$PACKAGES"
elif [ -f "$FILE" ]; then
    PACKAGES=./linux-packages.txt
else
	echo "${red}[!] ${reset}You need to create a linux-package.txt file or path to alternate file with packages."
fi


# Iterates through the linux-packages.txt file, downloads the files, and tarballs them
mkdir -p ./repo/rpms
for package in $(cat < $PACKAGES); do
	echo "${red}[!] ${green}Downloading Linux Packages For: ${reset}$package"
	docker exec -u root $CONTAINER_ID dnf install -y --downloadonly --downloaddir=/tmp/rpms/ $package > /dev/null 2>&1
	URL_COUNT=$(ls ./repo/rpms | wc -l) 
	echo "${red}[!] ${green}Total Linux Packages So Far: ${reset}$URL_COUNT"
done


DIR=./repo/
if [ -d "$DIR" ]
then
	if [ "$(ls -A $DIR)" ]; then
    	# echo "Take action $DIR is not Empty"
		# Convert the packages into a repo and tarball it
		docker exec -u root $CONTAINER_ID createrepo /tmp/rpms/
		# datetime=`date +%m-%d-%Y`

		TARBALL_NAME=$4
		docker exec -u root $CONTAINER_ID tar zcf /tmp/$TARBALL_NAME-rpms.tar.gz /tmp/rpms

		eval "docker cp $CONTAINER_ID:/tmp/$TARBALL_NAME-rpms.tar.gz ./repo/"
	else
		echo "${red}[!] ${green}The $DIR directory is Empty.${reset}"
	fi
else
	echo "${red}[!] ${green}The $DIR directory was not found.${reset}"
fi

# echo "${red}[!] ${green}Unregistering Red Hat EPEL Repository${reset}"
# docker exec -u root $CONTAINER_ID subscription-manager unregister


###################
# Python Packages #
###################
FILE=./python-packages.txt
if [ $3 ]; then
	PACKAGES=$3
elif [ -f "$FILE" ]; then
    PACKAGES=./python-packages.txt
else
	echo "${red}[!] ${reset}You need to create a python-package.txt file or path to alternate file with packages."
fi

# Iterates through the python-packages.txt file and extracts the python package urls
for package in $(cat < $PACKAGES); do
	echo "${red}[!] ${green}Downloading Python3.8 Dependencies For: ${reset}$package"
	download_package="docker exec -u root $CONTAINER_ID python -m pip download -vvv $package"
	eval "$download_package" | grep "from https" | grep "Added" | awk '{ print $4}' | tee -a ./repo/urls 1> /dev/null 2>&1
	URL_COUNT=$(cat ./repo/urls | wc -l)
	echo "${red}[!] ${green}Total URLs So Far: ${reset}$URL_COUNT"
done

if [ -n "$PACKAGES" ]; then
	# Removes duplicate urls
	echo -e "${red}[!] ${green}Removing Duplicate URLs"
	sort ./repo/urls | uniq > ./repo/urls-temp
	mv ./repo/urls-temp ./repo/urls
	echo "${red}[!] ${green}Total URLs: ${reset}$(cat ./repo/urls | wc -l)"

	# parse URL's list and generate the hardening_manifest.yaml
	echo -e "${red}[!] ${green}Parsing URLs and Generating hardening_manifest.yaml${reset}"
	python3 scripts/python-hm-resources.py > /dev/null 2>&1

	# Prompt user to view hardening_manifest.yaml file
	echo ""
	echo -e "${red}[!] ${yellow}View the contents of the hardening_manifest? ${reset} y/n"
	while true; do
		read -p "(y|n)" yn
		case $yn in
			[Yy]* ) cat ./hardening_manifest.yaml ; break;;
			[Nn]* ) continue;;
			* ) echo "Invalid Response";;
		esac
	done

	# cleanup
	rm -f repo/urls 
fi 2> /dev/null
