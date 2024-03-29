#' Process the cost lookup files
#'
#' @description This takes a `file_name` which must be in the
#'  `Rmarkdown/` directory it will quietly render the `.Rmd`
#'  file with [rmarkdown::render()] and try to open the
#'  rendered html doc.
#'
#' @param file_name Rmd file to process
#'
#' @return NULL
process_costs_rmd <- function(file_name) {
  if (!stringr::str_detect(
    fs::path_ext(file_name),
    stringr::fixed("Rmd", ignore_case = TRUE)
  )) {
    cli::cli_abort(
      "{.arg file_name} must be an {.code .Rmd} not a
      {.code .{fs::path_ext(file_name)}}."
    )
  }

  input_dir <- "Rmarkdown"

  output_dir <- fs::path(
    get_slf_dir(),
    "Tests"
  )

  input_file <- get_file_path(
    directory = input_dir,
    file_name = file_name
  )

  date_today <- format(Sys.Date(), "%d_%b")

  output_file <- get_file_path(
    directory = output_dir,
    file_name = fs::path_ext_set(
      stringr::str_glue(
        "{fs::path_ext_remove(file_name)}-{latest_update()}-{date_today}"
      ),
      "html"
    ),
    check_mode = "write"
  )

  rmarkdown::render(
    input = input_file,
    output_file = output_file,
    output_format = "html_document",
    envir = new.env(),
    quiet = TRUE
  )

  if (fs::file_info(output_file)$user == Sys.getenv("USER")) {
    # Set the correct permissions
    fs::file_chmod(path = output_file, mode = "660")
  }

  utils::browseURL(output_file)

  return(NULL)
}

#' Process District Nursing cost lookup Rmd file
#'
#' @description This will read and process the
#' District Nursing cost lookup, it will return the final data
#' and write it to disk.
#'
#' @param file_path Path to the cost lookup.
#'
#' @return a [tibble][tibble::tibble-package] containing the final cost data.
#' @export
process_costs_dn_rmd <- function(file_path = get_dn_costs_path()) {
  process_costs_rmd(file_name = "costs_district_nursing.Rmd")

  dn_lookup <- read_file(file_path)

  return(dn_lookup)
}

#' Process care homes cost lookup Rmd file
#'
#' @description This will read and process the
#' care homes cost lookup, it will return the final data
#' and write it to disk.
#'
#' @inheritParams process_costs_dn_rmd
#'
#' @return a [tibble][tibble::tibble-package] containing the final cost data.
#' @export
process_costs_ch_rmd <- function(file_path = get_ch_costs_path()) {
  process_costs_rmd(file_name = "costs_care_home.Rmd")

  ch_cost_lookup <- read_file(file_path)

  return(ch_cost_lookup)
}

#' Process GP ooh cost lookup Rmd file
#'
#' @description This will read and process the
#' GP ooh cost lookup, it will return the final data
#' and write it to disk.
#'
#' @inheritParams process_costs_dn_rmd
#'
#' @return a [tibble][tibble::tibble-package] containing the final cost data.
#' @export
process_costs_gp_ooh_rmd <- function(file_path = get_gp_ooh_costs_path()) {
  process_costs_rmd(file_name = "costs_gp_ooh.Rmd")

  ooh_cost_lookup <- read_file(file_path)

  return(ooh_cost_lookup)
}

#' Process Home Care cost lookup Rmd file
#'
#' @description This will read and process the
#' Home Care cost lookup, it will return the final data
#' and write it to disk.
#'
#' @inheritParams process_costs_dn_rmd
#'
#' @return a [tibble][tibble::tibble-package] containing the final cost data.
#' @export
process_costs_hc_rmd <- function(file_path = get_hc_costs_path()) {
  process_costs_rmd(file_name = "costs_home_care.Rmd")

  hc_cost_lookup <- read_file(file_path)

  return(hc_cost_lookup)
}
