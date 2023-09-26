#' Read NRS Deaths extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_nrs_deaths <- function(
    year,
    file_path = get_boxi_extract_path(year = year, type = "deaths")) {
  extract_nrs_deaths <- read_file(file_path,
    col_types = readr::cols_only(
      "Death Location Code" = readr::col_character(),
      "Geo Council Area Code" = readr::col_character(),
      "Geo Data Zone 2011" = readr::col_character(),
      "Geo Postcode [C]" = readr::col_character(),
      "Geo HSCP of Residence Code - current" = readr::col_character(),
      "NHS Board of Occurrence Code - current" = readr::col_character(),
      "NHS Board of Residence Code - current" = readr::col_character(),
      "Pat Date Of Birth [C]" = readr::col_date(format = "%Y/%m/%d %T"),
      "Date of Death(99)" = readr::col_date(format = "%Y/%m/%d %T"),
      "Pat Gender Code" = readr::col_double(),
      "Pat UPI" = readr::col_character(),
      "Place Death Occurred Code" = readr::col_character(),
      "Post Mortem Code" = readr::col_character(),
      "Prim Cause of Death Code (6 char)" = readr::col_character(),
      "Sec Cause of Death 0 Code (6 char)" = readr::col_character(),
      "Sec Cause of Death 1 Code (6 char)" = readr::col_character(),
      "Sec Cause of Death 2 Code (6 char)" = readr::col_character(),
      "Sec Cause of Death 3 Code (6 char)" = readr::col_character(),
      "Sec Cause of Death 4 Code (6 char)" = readr::col_character(),
      "Sec Cause of Death 5 Code (6 char)" = readr::col_character(),
      "Sec Cause of Death 6 Code (6 char)" = readr::col_character(),
      "Sec Cause of Death 7 Code (6 char)" = readr::col_character(),
      "Sec Cause of Death 8 Code (6 char)" = readr::col_character(),
      "Sec Cause of Death 9 Code (6 char)" = readr::col_character(),
      "Unique Record Identifier" = readr::col_character(),
      "GP practice code(99)" = readr::col_character()
    )
  ) %>%
    dplyr::rename(
      death_location_code = "Death Location Code",
      lca = "Geo Council Area Code",
      datazone2011 = "Geo Data Zone 2011",
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
