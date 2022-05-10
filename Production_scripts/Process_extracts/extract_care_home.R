#####################################################
# Care Home
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description -
#####################################################


# Load packages
library(dplyr)
library(dbplyr)
library(createslf)


## Care Home Lookup ##

# Read in data---------------------------------------

ch_lookup <- readxl::read_xlsx(get_slf_ch_path())

