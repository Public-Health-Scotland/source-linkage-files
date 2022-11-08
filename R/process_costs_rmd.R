#' Process the cost lookup files
#'
#' @description This takes a `file_name` and optionally `directory`
#' it will quietly render the `.Rmd` file with [rmarkdown::render()]
#' and try to open the rendered html doc.
#'
#' @param file_name Rmd file to process
#' @param directory directory where the file is, this will also be
#' used for the output. The default is `Rmarkdown/`
#'
#' @return NULL
process_costs_rmd <- function(file_name, directory = "Rmarkdown") {
  if (!stringr::str_detect(
    fs::path_ext(file_name),
    stringr::fixed("Rmd", ignore_case = TRUE)
  )) {
    cli::cli_abort("{.arg file_name} must be an {.code .Rmd} not a {.code .{fs::path_ext(file_name)}}.")
  }

  input_file <- get_file_path(
    directory = directory,
    file_name = file_name
  )

  rmarkdown::render(
    input = input_file,
    output_format = "html_document",
    envir = new.env(),
    quiet = TRUE
  )

  browseURL(fs::path_ext_set(input_file, "html"))

  return(NULL)
}

#' Process District Nursing cost lookup Rmd file
#'
#' @description This will read and process the
#' District Nursing cost lookup, it will return the final data
#' but also write this out as a rds.
#'
#' @return a [tibble][tibble::tibble-package] containing the final cost data.
#' @export
process_costs_dn_rmd <- function() {

  process_costs_rmd(file_name = "costs_district_nursing.Rmd")

  dn_lookup <- readr::read_rds(get_dn_costs_path())

  return(dn_lookup)
}

#' Process care homes cost lookup Rmd file
#'
#' @description This will read and process the
#' care homes cost lookup, it will return the final data
#' but also write this out as a rds.
#'
#' @return a [tibble][tibble::tibble-package] containing the final cost data.
#' @export
process_costs_ch_rmd <- function() {

  process_costs_rmd(file_name = "costs_care_home.Rmd")

  ch_cost_lookup <- readr::read_rds(get_ch_costs_path())

  return(ch_cost_lookup)
}

#' Process GP ooh cost lookup Rmd file
#'
#' @description This will read and process the
#' GP ooh cost lookup, it will return the final data
#' but also write this out as a rds.
#'
#' @return a [tibble][tibble::tibble-package] containing the final cost data.
#' @export
process_costs_gp_ooh_rmd <- function() {

  process_costs_rmd(file_name = "costs_gp_ooh.Rmd")

  ooh_cost_lookup <- readr::read_rds(get_gp_ooh_costs_path())

  return(ooh_cost_lookup)
}

#' Process Home Care cost lookup Rmd file
#'
#' @description This will read and process the
#' Home Care cost lookup, it will return the final data
#' but also write this out as a rds.
#'
#' @return a [tibble][tibble::tibble-package] containing the final cost data.
#' @export
process_costs_hc_rmd <- function() {

  process_costs_rmd(file_name = "costs_home_care.Rmd")

  hc_cost_lookup <- readr::read_rds(get_hc_costs_path())

  return(hc_cost_lookup)
}
