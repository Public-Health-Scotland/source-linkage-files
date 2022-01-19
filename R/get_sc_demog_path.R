#' Function for reading in SC Demographic lookup
#'
#' @param update Latest update or previous update
#'
#' @return The demographics file
#' @export
get_sc_demog_lookup_path <- function(update = latest_update()) {

  file_name = "sc_demographics_lookup_"

  sc_demog_lookup_path <- fs::path(
    get_slf_dir(),
    "Social_care",
    paste0(file_name, update)
  )

  sc_demog_lookup_path <- fs::path_ext_set(
    sc_demog_lookup_path,
    "zsav"
  )

  return(sc_demog_lookup_path)
}
