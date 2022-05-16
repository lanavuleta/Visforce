#install.packages("devtools")
#library(devtools)
#devtools::install_github("CentreForHydrology/CRHMr")
library(CRHMr)
library(stringr)
library(lubridate)
library(purrr)
library(plyr)
library(dplyr)
library(here)
library(R.utils)
library(tidyr)

source("functions.R")

dirs <- list.dirs(here("data/raw_data/VB_model outputs_April2022/"))[-1]

# See functions.R to understand how this function works
map(dirs, make_csv)







