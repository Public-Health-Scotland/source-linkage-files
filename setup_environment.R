source("packages.R")

fs::dir_walk("R_functions", recurse = TRUE, type = "file", fun = source)

boxi_date_format <- "%Y/%m/%d %T"
