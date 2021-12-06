#!/usr/bin/env python3
import yaml

# debug
import sys
import pprint

#######################################################################################################################
# This script parses the repo/urls file for package names, their pip-retrieved urls, and sha256 hashes.               #
# Finally, it sorts the data and appends it in yaml format into hardening_manifest.yaml (required for IB submissions) #
#######################################################################################################################

# example returned string in repo/urls
# https://files.pythonhosted.org/packages/ee/ff/48bde5c0f013094d729fe4b0316ba2a24774b3ff1c52d924a8a4cb04078a/six-1.15.0-py2.py3-none-any.whl#sha256=8b74bedcbbbaca38ff6d7491d76f2b06b3592611af620f8426e82dddb04a5ced


def extractPackageData():
    """returns list of tuples containing (url, hash)"""

    checksum_tuples = []
    with open("repo/urls") as datafile:
        lines = datafile.readlines()
        for line in lines:
            # url is the first section of the string before the # => checksum
            # hash is the 2nd piece of the string after splitting on 'sha256='
            url, hash = line.split("#")[0], line.split("sha256=")[1]
            filename = url.split("/")[-1]
            checksum_tuples.append((url, filename, hash))
        return checksum_tuples

def writePackageData(checksum_tuples: list):
    resources = {"resources":[]}
    pp = pprint.PrettyPrinter(indent = 4)   
    pp.pprint(checksum_tuples)
    print(len(checksum_tuples))
    with open("hardening_manifest.yaml", "a") as manifest:
        for i in range(len(checksum_tuples)):
            url, filename, hash = checksum_tuples[i][0], checksum_tuples[i][1], checksum_tuples[i][2].strip()
            resources["resources"].append({'filename': filename, 'url': url, 'validation':{'type': 'sha256', 'value': hash}})

        # append the created yaml to the hardening_manifest.yaml
        yaml.dump(resources, manifest)

        
def main():
    print("extracting package data from URLs")
    checksum_tuples = extractPackageData()  
    print("writing the package data to hardening_manifest.yaml")
    writePackageData(checksum_tuples)

main()
