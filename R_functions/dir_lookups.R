year <- factor(c("1415", "1516", "1617", "1819", "1920", "2021", "2122"))

#year_dir <- set_year_dir(year)
set_year_dir <- function() {
  fs::path("/conf/sourcedev/Source_Linkage_File_Updates/")
}

year_dir_path <- function(file, ...){
  fs::path(set_year_dir(), year)
}


set_extracts_dir <- function(file, ...) {
  year_extracts_dir <- fs::path(set_year_dir(year), "Extracts", file)
}
