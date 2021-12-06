#!/bin/bash

echo "downloading packages.."
# download the package requested by the user, parse for added urls, and then write to file 'urls'
Rscript /download-deps.R >& packages.log 

cat packages.log | grep "https" | awk '{print $3}' > urls.txt
