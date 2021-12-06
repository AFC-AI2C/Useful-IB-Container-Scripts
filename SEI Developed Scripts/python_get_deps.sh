#!/bin/bash

# USAGE:
#
# ./get_deps.sh [python-version] [pip package name]
#
# NOTE: this sort of expects you are building with python 3.6/3.8 (current IB available images) - I have no idea of older version if pip will work with this.

if [ ! -d "./repo" ]
then
	mkdir repo
fi

python3 -m pip install -r requirements/requirements.txt --user

docker build --no-cache --build-arg VERSION=$1 --tag python-download-deps ./build/python
docker run -v $(pwd)/repo:/tmp -e PACKAGE=$2 python-download-deps

# parse URL's list and generate the hardening_manifest.yaml
python3 scripts/python-hm-resources.py 

# cleanup
rm -f repo/urls 

