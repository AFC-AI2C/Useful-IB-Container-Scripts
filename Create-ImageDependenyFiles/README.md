# Create-ImageDependenyFiles.sh

The purpose of this script is to build a tar.gz file containing linux binaries and hardening_manifest.yaml of python packages to expediate the process of building secure containers. The resultant files are downloaded/craeted based off a specified image, and provided package arguments to acquire.

## Usage:
- Example Command:
Note: Currently, all arguments are required for the script to function properly, even if there are no packages to download.
```
./Create-ImageDependenyFiles.sh afcai2c/jlab-dl:latest jlab-cv-linux-packages.txt jlab-cv-python-packages.txt jlab-cv 'komnick' $REDHAT_PASSWORD
```

![Alt text](https://github.com/AFC-AI2C/Useful-IB-Container-Scripts/blob/main/Create-ImageDependenyFiles/screenshot.png)

## Notes:
Need to finish addeding some...
