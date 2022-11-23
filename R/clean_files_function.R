#' Clean up files not needed before or after an update
#'
#' @description Clean up .csv or .gz files not needed before or after an update. Need confirmation to do cleaning
#'
#' @param clean_slf_dir TRUE or FALSE, deciding whether to clean files in IT_extracts
#' @param clean_years The input value can be 'all' ~ to clean files in all year folders
#' specific year or years ~ to clean files in specific year(s) folder(s)
#' NULL ~ do not clean files in any year folder
#'
#' @export
#' @examples
#' clean_files_function(clean_slf_dir = TRUE, clean_years = "all")
#' clean_files_function(clean_slf_dir = TRUE, clean_years = c(1213,1415))
#' clean_files_function(clean_slf_dir = TRUE)
#' clean_files_function(clean_slf_dir = FALSE, clean_years = c(1213,1415))
clean_files_function <- function(clean_slf_dir = TRUE,
                                 clean_years = NULL) {
  # delete files in IT_extracts folder
  if (clean_slf_dir) {
    it_file_list <- list.files(
      fs::path(get_slf_dir(), "IT_extracts"),
      full.names = TRUE,
      recursive = TRUE,
      pattern = '.csv$|.gz$'
    )
    it_all_list <- list.files(
      fs::path(get_slf_dir(), "IT_extracts"),
      full.names = TRUE,
      recursive = TRUE
    )

    print(it_file_list)
    if (askYesNo("Would you like to delete the files listed above",
                 default = FALSE)) {
      # calculate the size of files deleted in IT_extracts
      filesize_it <- round(sum(file.size(it_file_list))/1073741824, 2)
      # sapply(it_file_list, unlink)
    }
  } else{
    print('NOT clean up files in IT_extract')
  }

  # delete files in year folder(s)
  if (is.null(clean_years)) {
    print('NOT clean up files in any year folder')
  } else{
    if (tolower(clean_years) == 'all') {
      year <- paste0(11:as.integer(format(Sys.Date(), "%y")),
                     12:(as.integer(format(
                       Sys.Date(), "%y"
                     )) + 1))
    } else{
      year <- as.character(clean_years)
    }
    year_file_list = list.files(
      get_year_dir(year),
      recursive = TRUE,
      pattern = '.csv$|.gz$',
      full.names = TRUE
    )
    year_all_list = list.files(
      get_year_dir(year),
      recursive = TRUE,
      full.names = TRUE
    )

    print(year_file_list)
    if (askYesNo("Would you like to delete the files listed above",
                 default = FALSE)) {
      # calculate file size deleted in year folders
      filesize_year <- round(sum(file.size(year_file_list))/1073741824, 2)
      # sapply(year_file_list, unlink)
    }
  }

  print("End.")
  if(exists('filesize_it')){
    print(
      glue::glue(
        "Deleted {length(it_file_list)}/{length(it_all_list)} found files in hscdiip saving {filesize_it} GiB"
      )
    )
  }
  if(exists('filesize_year')){
    print(
      glue::glue(
        "Deleted {length(year_file_list)}/{length(year_all_list)} found files in sourcedev saving {filesize_year} GB"
      )
    )
  }
}
