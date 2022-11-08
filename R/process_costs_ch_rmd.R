#' Process care homes cost lookup RMD file
#'
#' @description This will read and process the
#' care homes cost lookup, it will return the final data
#' but also write this out as a rds.
#'
#' @return the final data as a html document.
#'
process_costs_ch_rmd <- function() {
  rmarkdown::render(
    input = "Rmarkdown/ch_costs.Rmd",
    output_file = "ch_costs.html"
  )

  ch_cost_lookup <- readr::read_rds(get_ch_costs_path())

  return(ch_cost_lookup)
}
