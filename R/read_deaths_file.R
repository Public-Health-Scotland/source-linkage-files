#' Function for reading in deaths file
#'
#' @param type Return a file
#' @param update Latest update or previous update
#'
#' @return The deaths file
#' @export
read_deaths_file <- function(type = "file", update = latest_update()) {

  file_name = "all_deaths_"

  deaths_file_path <- fs::path(
    get_slf_dir(),
    "Deaths",
    paste0(file_name, update)
  )

  deaths_file_path <- fs::path_ext_set(
    deaths_file_path,
    "zsav"
  )

  deaths_file <- haven::read_sav(deaths_file_path)
  return(deaths_file)
}
