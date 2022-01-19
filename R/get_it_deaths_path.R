#' Function for reading in deaths file
#'
#' @param update Latest update or previous update
#'
#' @return The deaths file
#' @export
get_it_deaths_path <- function (update = latest_update()) {

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

  return(deaths_file_path)
}
