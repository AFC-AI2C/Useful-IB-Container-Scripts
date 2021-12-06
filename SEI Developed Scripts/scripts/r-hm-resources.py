import hashlib
import os.path
from os import path
import yaml


# compute sha256sum of a file if located in packages/
def hashme(filepath):
    sha256_hash = hashlib.sha256()
    try:
        with open(filepath,"rb") as f:
            # Read and update hash string value in blocks of 4K
            for byte_block in iter(lambda: f.read(4096),b""):
                sha256_hash.update(byte_block)
            return sha256_hash.hexdigest()
    except Exception as e: print(e)

# returns the filename
def get_filename(url: str):
    url_parse = url.split("/")
    # remove trailing ' and remove any newline chars
    return url_parse[len(url_parse) - 1]

#########################################################################################
# 1) read in urls                                                                       #
# 2) for each url, extract filename, calculate sha256sum, append to hm.resources block  #
#########################################################################################
def main():

    # initialize the yaml dictionary
    resources = {'resources':[]}

    # urls.txt contains the urls provided from the r-download script
    with open("repo/urls.txt") as u:
        for url in u:
            url = url.replace("'", "").strip()
            filename = get_filename(url)

            # get sha256sum if file is in repo/
            if path.exists(f"repo/{filename}"):
                sha256sum = hashme(f"repo/{filename}")
                # at this point we have sha256sum, url, and filename -> time to the resource object
                resources["resources"].append({'filename': filename, 'url': url, 'validation':{'type': 'sha256', 'value': sha256sum}})
            else:
                print(f"file not found: repo/{filename}")
        
        # write the resource object as yaml to file
        with open("hardening-manifest.yaml", "w") as hm:
            yaml.dump(resources, hm)
        
            

    

main()

    


