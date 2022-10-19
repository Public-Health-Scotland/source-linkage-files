#' Process District Nursing cost lookup RMD file
#'
#' @description This will read and process the
#' District Nursing cost lookup, it will return the final data
#' but also write this out as a rds.
#'
#' @return the final data as a html document.
#'
process_costs_dn_rmd <- function() {
  rmarkdown::render(
    input = "costs_district_nursing.Rmd",
    output_file = "costs_district_nursing.html"
  )

  dn_lookup <- readr::read_rds(get_dn_costs_path())

  return(dn_lookup)
}
