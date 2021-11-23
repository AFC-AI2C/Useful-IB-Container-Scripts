# Build-DockerImageTree.sh

This script will build multiple images in parent, child, grandchild, etc order. It iterates through each provided project's hardening_manifest.yaml file and parses out URLs to be downloaded. To reduce bandwidth consumption, if files are detected within the project directory, they are not downloaded. If a test_commands.txt file is provided within the project directory, they will be executed against a container to provide a basic functionality assessment.

## Usage:
./Build-DockerImageTree.sh image
./Build-DockerImageTree.sh parent_image child_image grandchild_image ..etc
    -h   --help       Shows help
    -v   --verbose    Verbose mode

## Notes:
The FROM image names within the Dockerfiles should be the same as its directory name
The version specified below is the same throughout the Dockerfiles
This script should be ran from the partent dir common to the those that have Dockerfiles

hardening_manifest.yaml needs to be in the same dir at the Dockerfile
- this file is parsed to download any dependencies

test_commands.txt needs to be in the same dir as the Dockerfile
- this file contains one command per line to run against an image
- sample test commands:
    wget www.google.com
    netstat
    python3.6 -c 'import plotly'

![Alt text](https://github.com/AFC-AI2C/Useful-IB-Container-Scripts/screenshot.png)

## Examples:
### Script Execution
Single Image Build
./Build-DockerImageTree.sh jlab-dl

Multi-Image Build
./Build-DockerImageTree.sh python38-ai jlab-eda jlab-dl jlab-cv

### Hardening Manifest (Mandated by DevSecOps Pipeline)
hardening_manifest.yaml
...
- filename: fastprogress-1.0.0-py3-none-any.whl
  url: https://files.pythonhosted.org/packages/eb/1f/c61b92d806fbd06ad75d08440efe7f2bd1006ba0b15d086debed49d93cdc/fastprogress-1.0.0-py3-none-any.whl
  validation:
    type: sha256
    value: 474cd6a6e5b1c29a02383d709bf71f502477d0849bddc6ba5aa80b683f4ad16f
- filename: alembic-1.6.4-py2.py3-none-any.whl
  url: https://files.pythonhosted.org/packages/eb/bd/c3486fd57a3eec5162a2e32e8f05880c990f0d92b03d268342d2e8fe7032/alembic-1.6.4-py2.py3-none-any.whl
  validation:
    type: sha256
    value: dd0fd7109f82cd1d7ea64b26f287534a1ad1bc5deab79807926d5f3f5b3b517c
...

###
test_commands.txt
...
=== TESTING RPM BINARIES ===
git clone https://www.github.com/high101bro/Docker.git
netstat
vim --version
=== TESTING PYTHON LIBRARIES ===
python3.8 -c 'import plotly'
python3.8 -c 'from bs4 import BeautifulSoup'
=== TESTING R LIBRARY METHODS & FUNCTIONS ===
R -e "library('broom')"
R -e "plot(c(1,2,3),c(1,2,3))"
R -e "library(recipes);library(tidyverse);library(tidyquant);library(timetk);FB_tbl <- FANG %>%filter(symbol == 'FB') %>% select(symbol, date, adjusted) ;rec_obj <- recipe(adjusted ~ ., data = FB_tbl) %>% step_fourier(date, period = c(252/4, 252), K = 2);  rec_obj"
...
