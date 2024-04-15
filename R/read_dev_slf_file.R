#' Read development SLF files (using SLFhelper)
#'
#' @param year Year of the file to be read, you can specify multiple years
#'  which will then be returned as one file. See SLFhelper for more info.
#' @param type Type of file to be read. Supply either Episode or Individual file.
#' @param col_select Supply the columns you would like to select.
#'
#' @return a tibble with development SLF file
#' @export
#'
read_dev_slf_file <- function(year, type = c("episode", "individual"), col_select = NULL) {
  if (type == "episode") {
    slf_file <- slfhelper::read_slf_episode(year,
      col_select = col_select,
      dev = TRUE
    )
  } else {
    slf_file <- slfhelper::read_slf_individual(year,
      col_select = col_select,
      dev = TRUE
    )
  }
}
