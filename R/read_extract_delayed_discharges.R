#' Read Delayed Discharges extract
#'
#' @param file_path Path to DD extract
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
read_extract_delayed_discharges <- function(file_path = get_dd_path()) {
  extract_delayed_discharges <- readr::read_rds(file_path) %>%
    janitor::clean_names() %>%
    dplyr::select(-.data[["cennum"]])

  return(extract_delayed_discharges)
}
