#' Process Home Care cost lookup RMD file
#'
#' @description This will read and process the
#' Home Care cost lookup, it will return the final data
#' but also write this out as a rds.
#'
#' @return the final data as a html document.
#'
process_costs_hc_rmd <- function() {
  rmarkdown::render(
    input = "Rmarkdown/hc_costs.Rmd",
    output_file = "hc_costs.html"
  )

  hc_cost_lookup <- readr::read_rds(get_hc_costs_path())

  return(hc_cost_lookup)
}
