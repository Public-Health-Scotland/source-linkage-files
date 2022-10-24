#' Process GP ooh cost lookup RMD file
#'
#' @description This will read and process the
#' GP ooh cost lookup, it will return the final data
#' but also write this out as a rds.
#'
#' @return the final data as a html document.
#'
process_costs_gp_ooh_rmd <- function() {
  rmarkdown::render(
    input = "Rmarkdown/gp_ooh_costs.Rmd",
    output_file = "gp_ooh_costs.html"
  )

  ooh_cost_lookup <- readr::read_rds(get_gp_ooh_costs_path())

  return(ooh_cost_lookup)
}
