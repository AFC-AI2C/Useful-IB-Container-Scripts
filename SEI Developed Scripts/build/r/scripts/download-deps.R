getDependencies <- function(packs){
 dependencyNames <- unlist(
   tools::package_dependencies(packages = packs, db = available.packages(), 
                               which = c("Depends", "Imports"),
                               recursive = TRUE))
 packageNames <- union(packs, dependencyNames)
 packageNames
}
packages <- getDependencies(c('httr', 'nnet', 'kknn', 'randomForest', 'xgboost', 'tidyverse', 'plotly', 'shiny', 'shinydashboard', 'devtools', 'DT', 'kernlab', 'parsnip', 'tidymodels', 'C50', 'mlbench', 'htmlwidgets', 'rmarkdown', 'lubridate', 'leaflet', 'sparklyr', 'magrittr', 'openxlsx', 'packrat', 'roxygen2', 'knitr', 'readr', 'readxl', 'stringr', 'broom', 'feather', 'forcats', 'testhat', 'plumber', 'RCurl', 'rvest', 'nlme', 'foreign', 'lattice', 'xpm', 'Matrix', 'flexdashboard', 'tidytext', 'plotROC', 'RJDBC', 'rgdal', 'highcharter', 'timetk', 'scales', 'reticulate', 'shinyWidgets', 'flextable', 'knitr', 'ggiraph', 'ECharts2Shiny', 'kableExtra', 'cli', 'gt'))
setwd(".")
pkgInfo <- download.packages(pkgs = packages, destdir = getwd())
