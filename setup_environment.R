source("packages.R")

fs::dir_walk("R_functions", recurse = TRUE, type = "file", fun = source)
