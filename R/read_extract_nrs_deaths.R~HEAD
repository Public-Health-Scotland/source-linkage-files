#' Read NRS Deaths extract
#'
#' @param year Year of BOXI extract
#'
#' @return csv data file for Acute
#' @export
#'
read_extract_nrs_deaths <- function(year) {
  extract_nrs_deaths_path <- get_boxi_extract_path(year = year, type = "Deaths")

  # Read BOXI extract
  extract_nrs_deaths <- readr::read_csv(extract_nrs_deaths_path,
    col_types = cols_only(
      "Death Location Code" = col_character(),
      "Geo Council Area Code" = col_character(),
      "Geo Data Zone 2011" = col_character(),
      "Geo Postcode [C]" = col_character(),
      "Geo HSCP of Residence Code - current" = col_character(),
      "NHS Board of Occurrence Code - current" = col_character(),
      "NHS Board of Residence Code - current" = col_character(),
      "Pat Date Of Birth [C]" = col_date(format = "%Y/%m/%d %T"),
      "Date of Death(99)" = col_date(format = "%Y/%m/%d %T"),
      "Pat Gender Code" = col_double(),
      "Pat UPI" = col_character(),
      "Place Death Occurred Code" = col_character(),
      "Post Mortem Code" = col_character(),
      "Prim Cause of Death Code (6 char)" = col_character(),
      "Sec Cause of Death 0 Code (6 char)" = col_character(),
      "Sec Cause of Death 1 Code (6 char)" = col_character(),
      "Sec Cause of Death 2 Code (6 char)" = col_character(),
      "Sec Cause of Death 3 Code (6 char)" = col_character(),
      "Sec Cause of Death 4 Code (6 char)" = col_character(),
      "Sec Cause of Death 5 Code (6 char)" = col_character(),
      "Sec Cause of Death 6 Code (6 char)" = col_character(),
      "Sec Cause of Death 7 Code (6 char)" = col_character(),
      "Sec Cause of Death 8 Code (6 char)" = col_character(),
      "Sec Cause of Death 9 Code (6 char)" = col_character(),
      "Unique Record Identifier" = col_character(),
      "GP practice code(99)" = col_character()
    )
  ) %>%
    # rename variables
    dplyr::rename(
      death_location_code = "Death Location Code",
      lca = "Geo Council Area Code",
      datazone = "Geo Data Zone 2011",
      postcode = "Geo Postcode [C]",
      hscp = "Geo HSCP of Residence Code - current",
      death_board_occurrence = "NHS Board of Occurrence Code - current",
      hbrescode = "NHS Board of Residence Code - current",
      dob = "Pat Date Of Birth [C]",
      record_keydate1 = "Date of Death(99)",
      gender = "Pat Gender Code",
      chi = "Pat UPI",
      place_death_occurred = "Place Death Occurred Code",
      post_mortem = "Post Mortem Code",
      deathdiag1 = "Prim Cause of Death Code (6 char)",
      deathdiag2 = "Sec Cause of Death 0 Code (6 char)",
      deathdiag3 = "Sec Cause of Death 1 Code (6 char)",
      deathdiag4 = "Sec Cause of Death 2 Code (6 char)",
      deathdiag5 = "Sec Cause of Death 3 Code (6 char)",
      deathdiag6 = "Sec Cause of Death 4 Code (6 char)",
      deathdiag7 = "Sec Cause of Death 5 Code (6 char)",
      deathdiag8 = "Sec Cause of Death 6 Code (6 char)",
      deathdiag9 = "Sec Cause of Death 7 Code (6 char)",
      deathdiag10 = "Sec Cause of Death 8 Code (6 char)",
      deathdiag11 = "Sec Cause of Death 9 Code (6 char)",
      uri = "Unique Record Identifier",
      gpprac = "GP practice code(99)"
    )

  return(extract_nrs_deaths)
}
