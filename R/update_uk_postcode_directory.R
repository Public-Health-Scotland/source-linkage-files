#' Update UK postcode directory from ONS API
#' The ONS NHSPD directory is update quarterly.
#'
update_uk_postcode_directory <- function() {
  # Define URL for the latest "complete" NHSPD directory
  # This always points to the newest quarterly release.
  nhspd_url <- "https://files.digital.nhs.uk/assets/ods/current/gridall.zip"

  # Download to a temporary file
  temp_zip <- tempfile(fileext = ".zip")
  utils::download.file(nhspd_url, destfile = temp_zip, mode = "wb")
  # copy it to the SLFExtract Temp folder, which will be deleted in the end
  target_dir <- fs::path(get_slf_dir(), "/Temp/")
  if (!dir.exists(target_dir)) {
    dir.create(target_dir, recursive = TRUE)
  }
  final_zip_path <- file.path(target_dir, "gridall.zip")
  file.copy(from = temp_zip, to = final_zip_path, overwrite = TRUE)
  # delete temp file
  unlink(temp_zip)

  # read only the second column (PCDS) as character
  # as it is postcode 7 digit format
  pcd <- readr::read_csv(
    unz(final_zip_path, "gridall.csv"),
    col_names = FALSE, # no header in the file
    col_select = 2,
    show_col_types = FALSE
  ) %>%
    dplyr::rename("pcd" = "X2") %>%
    dplyr::mutate(pcd = phsmethods::format_postcode(.data$pcd,
      format = "pc7",
      quiet = TRUE
    ))

  write_file(pcd,
    get_uk_postcode_path(check_mode = "write"),
    group_id = 3206
  ) # hscdiip owner

  unlink(target_dir, recursive = TRUE)

  return(pcd %>% dplyr::pull())
}
