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
  fs::path("/conf/linkage/output/lookups/Unicode")
}


#' Locality File Path
#'
#' @description Get the path to the centrally held HSCP Localities file.
#'
#' @param file_name (optional) the file name of the Localities files, if not
#' supplied it will try to return the latest file automatically (using
#' [find_latest_file()])
#' @param ext The extension (type of the file) - optional
#'
#' @return An [fs::path()] to the Scottish Postcode Directory
#' @export
#'
#' @family lookup file paths
read_locality_file <- function(file_name = NULL, ext = "rds") {
  locality_dir <-
    fs::path(get_lookups_dir(), "Geography", "HSCP Locality")

  locality_path <- get_file_path(
    directory = locality_dir,
    file_name = file_name,
    ext = ext,
    file_name_regexp = glue::glue("HSCP Localities_DZ11_Lookup_\\d+?\\.{ext}")
  )

  return(locality_path)
}


#' Scottish Postcode Directory File Path
#'
#' @description Get the path to the centrally held Scottish Postcode Directory
#' (SPD) file.
#'
#' @param file_name (optional) the file name of the SPD, if not supplied it will
#' try to return the latest file automatically (using [find_latest_file()])
#' @param ext The extension (type of the file) - optional
#'
#' @return An [fs::path()] to the Scottish Postcode Directory
#' @export
#'
#' @family lookup file paths
read_spd_file <- function(file_name = NULL, ext = "rds") {
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
    file_name_regexp = glue::glue("Scottish_Postcode_Directory_.+?\\.{ext}")
  )

  return(spd_path)
}


#' SIMD File Path
#'
#' @description Read the Scottish Index for Multiple Deprivation (SIMD) file
#'
#' @param file - the file name of the simd file
#'
#' @return The data read using `readr::read_rds`
#' @export
#'
#' @family lookup file paths
read_simd_file <- function(file) {
  simd_path <- fs::path(get_lookups_dir(), "Deprivation", file)

  # If given a sav extension (or other), swap it for rds
  simd_path <- fs::path_ext_set(simd_path, "rds")

  # Check if the file exists and we can read it
  if (!fs::file_access(simd_path, "read")) {
    rlang::abort(message = "Couldn't read the simd file")
  }

  return(simd_path)
}


#' Datazone Populations File Path
#'
#' @description Read the Datazone populations file
#'
#' @param file - the file name of the datazone populations file
#'
#' @return The data read using `readr::read_rds`
#' @export
#'
#' @family lookup file paths
read_datazone_pop_file <- function(file) {
  datazone_pop_path <-
    fs::path(get_lookups_dir(), "Populations", "Estimates", file)

  # If given a sav extension (or other), swap it for rds
  datazone_pop_path <- fs::path_ext_set(datazone_pop_path, "rds")

  # Check if the file exists and we can read it
  if (!fs::file_access(datazone_pop_path, "read")) {
    rlang::abort(message = "Couldn't read the datazone population file")
  }

  return(datazone_pop_path)
}



#' GP Practice File Path
#'
#' @description Read the GP practice lookup file
#'
#' @param file - the file name of the GP practice file
#'
#' @return The data read using `readr::read_rds`
#' @export
#'
#' @family lookup file paths
read_gpprac_file <- function(file) {
  gpprac_path <-
    fs::path(get_lookups_dir(), "National Reference Files", file)

  # Check if the file exists and we can read it
  if (!fs::file_access(gpprac_path, "read")) {
    rlang::abort(message = "Couldn't read the gppractice lookup file")
  }

  return(gpprac_path)
}
