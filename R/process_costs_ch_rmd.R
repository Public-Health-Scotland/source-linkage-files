#' Process care homes cost lookup RMD file
#'
#' @description This will read and process the
#' care homes cost lookup, it will return the final data
#' but also write this out as a rds.
#'
#' @param file_path Path to cost lookup.
#'
#' @return the final data as a html document.
#'
process_costs_ch_rmd <- function(file_path = get_ch_costs_path()) {
  rmarkdown::render(
    input = "Rmarkdown/ch_costs.Rmd",
    output_file = "ch_costs.html"
  )

  ch_cost_lookup <- readr::read_rds(file_path)

  return(ch_cost_lookup)
}
