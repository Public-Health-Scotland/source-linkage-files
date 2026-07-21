#' District Nursing Contacts File Path - LOCAL ONLY
#'
#' @description Get the District Nursing contacts path - LOCAL ONLY
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the local contacts lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_dn_contacts_path <- function(...) {
  dn_contacts_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("DN-Contacts-Numbers-for-Costs.csv"),
    ...
  )

  return(dn_contacts_path)
}
