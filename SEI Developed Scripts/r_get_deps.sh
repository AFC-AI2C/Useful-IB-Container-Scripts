#!/bin/bash

# USAGE:
#
# ./r_get_deps.sh [package list]
#

if [ ! -d "./repo" ]
then
	mkdir repo
fi

python3 -m pip install -r requirements/requirements.txt --user

docker build --tag download-r-deps ./build/r
docker run -v $(pwd)/repo:/tmp download-r-deps

# parse URL's list and generate the hardening_manifest.yaml
python3 scripts/r-hm-resources.py

# cleanup
rm -f repo/urls
