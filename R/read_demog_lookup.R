#' Function for reading in SC Demographic lookup
#'
#' @param type Return a file
#' @param update Latest update or previous update
#'
#' @return The demographics file
#' @export
read_demog_lookup <- function(type = "file", update = latest_update()) {

  file_name = "sc_demographics_lookup_"

  demog_lookup_path <- fs::path(
    get_slf_dir(),
    "Social_care",
    paste0(file_name, update)
  )

  demog_lookup_path <- fs::path_ext_set(
    demog_lookup_path,
    "zsav"
  )

  demog_lookup_file <- haven::read_sav(demog_lookup_path)
  return(demog_lookup_file)
}
