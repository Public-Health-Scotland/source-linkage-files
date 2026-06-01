#' Lookups Directory Path
#'
#' @description Get the path to the lookups directory
#'
#' @return the Lookups directory path as a [fs::path]
#' @export
#'
#' @family lookup file paths
#' @family directories
get_lookups_dir <- function() {
  fs::path("/", "conf", "linkage", "output", "lookups", "Unicode")
}


#' Locality File Path
#'
#' @description Get the path to the centrally held HSCP Localities file.
#'
#' @inheritParams get_file_path
#'
#' @return An [fs::path()] to the HSCP Localities file
#' @export
#'
#' @family lookup file paths
get_locality_path <- function(file_name = NULL, ext = "rds") {
  locality_dir <-
    fs::path(get_lookups_dir(), "Geography", "HSCP Locality")

  locality_path <- get_file_path(
    directory = locality_dir,
    file_name = file_name,
    ext = ext,
    file_name_regexp = stringr::str_glue("HSCP Localities_DZ11_Lookup_\\d+?\\.{ext}")
  )

  return(locality_path)
}


#' Locality data
#'
#' @description Return the data for centrally held HSCP Localities file.
#'
#' @param denodo_connect Connection to denodo
#' @param file_path Path to local HSCP Localities file
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_locality_data <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                              file_path = get_locality_path(),
                              BYOC_MODE) {

  if (isTRUE(BYOC_MODE)) {

    log_slf_event(stage = "read", status = "start", type = "HSCP Localities Lookup", year = "all") # TODO: Check whether to add hscp_locality to log_slf_event mapping list

    on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

    locality_data <- dplyr::tbl(
      denodo_connect,
      dbplyr::in_schema("sdl", "sdl_hscp_locality_source") # TODO: Check table name
      ) %>%
      dplyr::select(
        locality = "hscp_locality",
        tidyselect::matches("datazone\\d{4}$")
        ) %>% # TODO: Check whether we need to select columns
      collect()

    log_slf_event(stage = "read", status = "complete", type = "HSCP Localities Lookup", year = "all") # TODO: Check whether to add hscp_locality to log_slf_event mapping list

  } else { # TODO: Check logic - are we reading the local file when BYOC_MODE = FALSE or are we still reading from Denodo?

    locality_data <- read_file(file_path) %>%
      dplyr::select(
        locality = "hscp_locality",
        tidyselect::matches("datazone\\d{4}$")
        ) # TODO: Check whether we need to select columns

  }

  return(locality_data)
}


#' Scottish Postcode Directory File Path
#'
#' @description Get the path to the centrally held Scottish Postcode Directory
#' (SPD) file.
#'
#' @inheritParams get_file_path
#'
#' @return An [fs::path()] to the Scottish Postcode Directory
#' @export
#'
#' @family lookup file paths
get_spd_path <- function(file_name = NULL, ext = "parquet") {
  spd_dir <-
    fs::path(
      get_lookups_dir(),
      "Geography",
      "Scottish Postcode Directory"
    )

  spd_path <- get_file_path(
    directory = spd_dir,
    file_name = file_name,
    ext = ext,
    file_name_regexp = stringr::str_glue("Scottish_Postcode_Directory_.+?\\.{ext}")
  )

  return(spd_path)
}


#' SIMD File Path
#'
#' @description Get the path to the centrally held Scottish Index of Multiple
#' Deprivation (SIMD) file.
#'
#' @inheritParams get_file_path
#'
#' @return An [fs::path()] to the SIMD file
#' @export
#'
#' @family lookup file paths
get_simd_path <- function(file_name = NULL, ext = "parquet") {
  simd_dir <-
    fs::path(get_lookups_dir(), "Deprivation")

  simd_path <- get_file_path(
    directory = simd_dir,
    file_name = file_name,
    ext = ext,
    file_name_regexp = stringr::str_glue(
      "postcode_\\d\\d\\d\\d_\\d_simd\\d\\d\\d\\d.*?\\.{ext}"
    )
  )

  return(simd_path)
}


#' SIMD data
#'
#' @description Return the data for centrally held Scottish Index of Multiple
#' Deprivation (SIMD) file.
#'
#' @param denodo_connect Connection to denodo
#' @param file_path Path to local SIMD file
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_simd_data <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                          file_path = get_simd_path(),
                          BYOC_MODE) {

  if (isTRUE(BYOC_MODE)) {

    log_slf_event(stage = "read", status = "start", type = "SIMD Lookup", year = "all") # TODO: Check whether to add simd to log_slf_event mapping list

    on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

    simd_data <- dplyr::tbl(
      denodo_connect,
      dbplyr::in_schema("sdl", "sdl_simd_source") # TODO: Check table name
    ) %>%
      dplyr::select(
        "pc7",
        "simd2020v2_rank",
        "simd2020v2_sc_decile",
        "simd2020v2_sc_quintile",
        "simd2020v2_hb2019_decile",
        "simd2020v2_hb2019_quintile",
        "simd2020v2_hscp2019_decile",
        "simd2020v2_hscp2019_quintile"
        ) %>% # TODO: Check whether we need to select columns. When a new version of the SIMD is released, the column names within the file will change.
      collect()

    log_slf_event(stage = "read", status = "complete", type = "SIMD Lookup", year = "all") # TODO: Check whether to add simd to log_slf_event mapping list

  } else { # TODO: Check logic - are we reading the local file when BYOC_MODE = FALSE or are we still reading from Denodo?

    simd_data <- read_file(file_path) %>%
      dplyr::select(
        "pc7",
        "simd2020v2_rank",
        "simd2020v2_sc_decile",
        "simd2020v2_sc_quintile",
        "simd2020v2_hb2019_decile",
        "simd2020v2_hb2019_quintile",
        "simd2020v2_hscp2019_decile",
        "simd2020v2_hscp2019_quintile"
        ) # TODO: Check whether we need to select columns. When a new version of the SIMD is released, the column names within the file will change.

    }

  return(simd_data)
}


#' Populations File Path for different types
#'
#' @description Get the path to the populations estimates
#'
#' @inheritParams get_file_path
#' @param type population type datazone, or hscp, or ca, or hb, or interzone
#'
#' @return An [fs::path()] to the populations estimates file
#' @export
#'
#' @family lookup file paths
get_pop_path <- function(file_name = NULL,
                         ext = "rds",
                         type = c(
                           "datazone",
                           "hscp",
                           "ca",
                           "hb",
                           "intzone"
                         )) {
  pop_dir <-
    fs::path(get_lookups_dir(), "Populations", "Estimates")

  file_name_re <- dplyr::case_match(
    type,
    "datazone" ~ stringr::str_glue("DataZone2011_pop_est_2011_\\d+?\\.{ext}"),
    "hscp" ~ stringr::str_glue("HSCP2019_pop_est_1981_\\d+?\\.{ext}"),
    "ca" ~ stringr::str_glue("CA2019_pop_est_1981_\\d+?\\.{ext}"),
    "hb" ~ stringr::str_glue("HB2019_pop_est_1981_\\d+?\\.{ext}"),
    "intzone" ~ stringr::str_glue("IntZone_pop_est_2011_\\d+?\\.{ext}")
  )

  pop_path <- get_file_path(
    directory = pop_dir,
    file_name = file_name,
    ext = ext,
    file_name_regexp = file_name_re
  )

  return(pop_path)
}


#' DataZone population data
#'
#' @description Return the data for DataZone population estimates.
#'
#' @param denodo_connect Connection to denodo
#' @param file_path Path to local DataZone population file
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_datazone_pop_data <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                  file_path = get_pop_path(type = "datazone"),
                                  BYOC_MODE) {

  if (isTRUE(BYOC_MODE)) {

    log_slf_event(stage = "read", status = "start", type = "DataZone Population Lookup", year = "all") # TODO: Check whether to add datazone_pop to log_slf_event mapping list

    on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

    datazone_pop_data <- dplyr::tbl(
      denodo_connect,
      dbplyr::in_schema("sdl", "sdl_datazone_population_source") # TODO: Check table name
      ) %>%
      dplyr::select(
        "year",
        "datazone2011",
        "sex",
        dplyr::starts_with("age")
        ) %>% # TODO: Check whether we need to select columns
      collect()

    log_slf_event(stage = "read", status = "complete", type = "DataZone Population Lookup", year = "all") # TODO: Check whether to add datazone_pop to log_slf_event mapping list

  } else { # TODO: Check logic - are we reading the local file when BYOC_MODE = FALSE or are we still reading from Denodo?

    datazone_pop_data <- read_file(file_path) %>%
      dplyr::select(
        "year",
        "datazone2011",
        "sex",
        dplyr::starts_with("age")
        ) # TODO: Check whether we need to select columns

  }

  return(datazone_pop_data)
}


#' GP Practice Reference File Path (gpprac)
#'
#' @description Get the path for the centrally held reference file `gpprac`
#'
#' @inheritParams get_file_path
#'
#' @return  An [fs::path()] to the file
#' @export
#'
#' @family lookup file paths
get_gpprac_ref_path <- function(ext = "csv") {
  gpprac_dir <- fs::path(get_lookups_dir(), "National Reference Files")

  gpprac_path <- get_file_path(
    directory = gpprac_dir,
    file_name = "gpprac",
    ext = ext
  )

  return(gpprac_path)
}
