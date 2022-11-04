#' Read gp ooh cost lookup
#'
#' @return csv data file for gp ooh costs
#'
read_costs_gp_ooh <- function() {
  # Copy existing file-----------------------------------

  ## Make a copy of the existing file
  fs::file_copy(get_gp_ooh_costs_path(),
    get_gp_ooh_costs_path(update = latest_update()),
    overwrite = TRUE
  )

  # Read in data---------------------------------------

  # Costs spreadsheet
  gp_ooh_data <- readxl::read_xlsx(paste0(
    get_slf_dir(),
    "/Costs/OOH_Costs.xlsx"
  ))

  return(gp_ooh_data)
}
