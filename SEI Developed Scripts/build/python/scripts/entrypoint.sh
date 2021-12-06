#!/bin/bash

# download the package requested by the user, parse for added urls, and then write to file 'urls'
python -m pip download -vvv beautifulsoup4 django prophet flask matplot numba numpy pandas plotly requests scikit-learn scipy seaborn statsmodels tqdm urllib3 wordcloud |grep "from https" |grep "Added" | awk '{ print $4}' > urls
