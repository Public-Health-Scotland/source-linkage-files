#' Fill postcode and GP practice geographies
#'
#' @description First improve the completion if possible
#' then use the lookups to match on additional variables.
#'
#' @param data the SLF
#'
#' @return a [tibble][tibble::tibble-package] of the SLF with improved
#' Postcode and GP Practice details.
#' @export
fill_geographies <- function(data) {
  check_variables_exist(data, c(
    "chi",
    "postcode",
    "hbrescode",
    "hscp",
    "lca",
    "datazone",
    "hbpraccode",
    "hbtreatcode",
    "gpprac",
    "hbpraccode"
  ))

  data %>%
    fill_postcode_geogs() %>%
    fill_gpprac_geographies()
}

#' Make a postcode lookup for filling to most recent postcodes based on CHI
#'
#' @param data A data frame containing chi, postcode, and a date of last contact
#'
#' @return A lookup containing CHI numbers and their most recent postcodes
make_postcode_lookup <- function(data) {
  postcode_lookup <-
    data %>%
    # Get rid of records with missing CHIs
    dplyr::filter(!is_missing(.data$chi)) %>%
    # Keep one row for each CHI, postcode, and date combination.
    dplyr::distinct("chi", "postcode", "record_keydate2") %>%
    # Format postcodes to 7-character format and replace dummy with NA
    dplyr::mutate(
      postcode = phsmethods::format_postcode(postcode, format = "pc7"),
      postcode = dplyr::na_if(.data$postcode, "NK010AA")
    ) %>%
    # Arrange with the most recent date at the top for each CHI
    dplyr::arrange(.data$chi, dplyr::desc(.data$record_keydate2)) %>%
    # Take only the first of each chi
    dplyr::distinct(.data$chi, .keep_all = TRUE) %>%
    # Rename
    dplyr::rename(most_recent_postcode = postcode) %>%
    # We don't need to keep discharge date after this point
    dplyr::select(-"record_keydate2") %>%
    # Drop any CHIs with no postcode
    tidyr::drop_na()

  return(postcode_lookup)
}

#' Make a GP practice lookup for filling to most recent postcodes based on CHI
#'
#' @param data A data frame containing chi, gpprac, and a date of last contact
#'
#' @return A lookup containing CHI numbers and their most recent GP practices
make_gpprac_lookup <- function(data) {
  gpprac_lookup <-
    data %>%
    # Get just the chi, gpprac and discharge date
    dplyr::select("chi", "gpprac", "record_keydate2") %>%
    # Get rid of missing chis
    dplyr::filter(!is_missing(.data$chi)) %>%
    # Replace dummy with NA
    dplyr::mutate(gpprac = dplyr::na_if(.data$gpprac, 99999L)) %>%
    # Arrange with most recent date at the top for each CHI
    dplyr::arrange(.data$chi, desc(.data$record_keydate2)) %>%
    # Take only the first of each chi
    dplyr::distinct(.data$chi, .keep_all = TRUE) %>%
    # Rename
    dplyr::rename(most_recent_gpprac = gpprac) %>%
    # We don't need to keep discharge date after this point
    dplyr::select(-"record_keydate2") %>%
    # Drop any CHIs with no gpprac code
    tidyr::drop_na()

  return(gpprac_lookup)
}

fill_postcode_geogs <- function(data) {
  spd <- read_file(get_slf_postcode_path())

  filled_postcodes <-
    dplyr::left_join(data, make_postcode_lookup(data), by = "chi") %>%
    dplyr::select(-postcode) %>%
    # If the existing postcode is missing or not known (NK010AA) replace it.
    dplyr::mutate(postcode = dplyr::if_else(is.na(.data$postcode) || .data$postcode == "NK010AA", .data$most_recent_postcode, .data$postcode)) %>%
    # Fill geographies
    dplyr::left_join(spd, by = "postcode", suffix = c("_old", "")) %>%
    dplyr::mutate(
      # Recode Health Board codes to consistent boundaries
      dplyr::across(
        c("hbrescode", "hbpraccode", "hbtreatcode"), ~ recode_health_boards(.x)
      ),
      # Recode HSCP codes to consistent boundaries
      hscp2018 = recode_hscp(.data$hscp2018)
    ) %>%
    cascade_geographies() %>%
    dplyr::mutate(
      hbrescode = dplyr::coalesce(.data$hb2018, .data$hbrescode),
      hscp = dplyr::coalesce(.data$hscp2018, .data$hscp),
      lca = dplyr::coalesce(.data$lca, .data$lca_old)
    ) %>%
    dplyr::select(-"hb2018", -"hscp2018", -"lca_old")

  return(filled_postcodes)
}

fill_gpprac_geographies <- function(data) {
  gpprac_ref <- read_file(get_slf_gpprac_path()) %>%
    dplyr::select(c("gpprac", "cluster", "hbpraccode"))

  filled_gpprac <-
    dplyr::left_join(data, make_gpprac_lookup(data), by = "chi") %>%
    dplyr::select(-gpprac) %>%
    # If the existing gpprac is missing or not known (99999) replace it.
    dplyr::mutate(gpprac = dplyr::if_else(is.na(.data$gpprac) || .data$gpprac == 99999L, .data$most_recent_gpprac, .data$gpprac)) %>%
    dplyr::left_join(gpprac_ref, by = "gpprac", suffix = c("_old", "")) %>%
    dplyr::mutate(
      hbpraccode = dplyr::coalesce(.data$hbpraccode, .data$hbpraccode_old)
    ) %>%
    dplyr::select(-"hbpraccode_old")

  return(filled_gpprac)
}

#' Match dummy HSCP and LCA codes
#'
#' @description Match dummy HSCP and LCA codes
#'
#' @param data episode files
#'
#' @return data with matched HSCP and LCA codes
cascade_geographies <- function(data) {
  # TODO rework this function into a series of smaller functions which operate on vectors
  # e.g. cascade_hscp_lca <- function(hscp, lca) {...}
  # Would take HSCP and populate any missing LCA using it
  data <- data %>%
    dplyr::mutate(
      # If we can, 'cascade' the geographies upwards
      # i.e. if they have an LCA use this to fill in HSCP2018 and so on for hbrescode
      # Codes are correct as at August 2018
      lca = dplyr::case_when(
        !is_missing(lca) ~ lca,
        hscp2018 == "S37000001" ~ "01",
        hscp2018 == "S37000002" ~ "02",
        hscp2018 == "S37000003" ~ "03",
        hscp2018 == "S37000004" ~ "04",
        hscp2018 == "S37000025" ~ "05",
        hscp2018 == "S37000029" ~ "07",
        hscp2018 == "S37000006" ~ "08",
        hscp2018 == "S37000007" ~ "09",
        hscp2018 == "S37000008" ~ "10",
        hscp2018 == "S37000009" ~ "11",
        hscp2018 == "S37000010" ~ "12",
        hscp2018 == "S37000011" ~ "13",
        hscp2018 == "S37000012" ~ "14",
        hscp2018 == "S37000013" ~ "15",
        hscp2018 == "S37000032" ~ "16",
        hscp2018 == "S37000015" ~ "17",
        hscp2018 == "S37000016" ~ "18",
        hscp2018 == "S37000017" ~ "19",
        hscp2018 == "S37000018" ~ "20",
        hscp2018 == "S37000019" ~ "21",
        hscp2018 == "S37000020" ~ "22",
        hscp2018 == "S37000021" ~ "23",
        hscp2018 == "S37000022" ~ "24",
        hscp2018 == "S37000033" ~ "25",
        hscp2018 == "S37000024" ~ "26",
        hscp2018 == "S37000026" ~ "27",
        hscp2018 == "S37000027" ~ "28",
        hscp2018 == "S37000028" ~ "29",
        hscp2018 == "S37000030" ~ "31",
        hscp2018 == "S37000031" ~ "32"
      ),
      # Next, use LCA to fill in hscp2018 if possible
      hscp2018 = dplyr::case_when(
        !is_missing(hscp2018) ~ hscp2018,
        lca == "01" ~ "S37000001",
        lca == "02" ~ "S37000002",
        lca == "03" ~ "S37000003",
        lca == "04" ~ "S37000004",
        lca == "05" ~ "S37000025",
        lca == "06" ~ "S37000005",
        lca == "07" ~ "S37000029",
        lca == "08" ~ "S37000006",
        lca == "09" ~ "S37000007",
        lca == "10" ~ "S37000008",
        lca == "11" ~ "S37000009",
        lca == "12" ~ "S37000010",
        lca == "13" ~ "S37000011",
        lca == "14" ~ "S37000012",
        lca == "15" ~ "S37000013",
        lca == "16" ~ "S37000032",
        lca == "17" ~ "S37000015",
        lca == "18" ~ "S37000016",
        lca == "19" ~ "S37000017",
        lca == "20" ~ "S37000018",
        lca == "21" ~ "S37000019",
        lca == "22" ~ "S37000020",
        lca == "23" ~ "S37000021",
        lca == "24" ~ "S37000022",
        lca == "25" ~ "S37000033",
        lca == "26" ~ "S37000024",
        lca == "27" ~ "S37000026",
        lca == "28" ~ "S37000027",
        lca == "29" ~ "S37000028",
        lca == "30" ~ "S37000005",
        lca == "31" ~ "S37000030",
        lca == "32" ~ "S37000031"
      ),
      # Next, use LCA to fill in ca2018
      ca2018 = dplyr::case_when(
        !is_missing(ca2018) ~ ca2018,
        lca == "01" ~ "S12000033",
        lca == "02" ~ "S12000034",
        lca == "03" ~ "S12000041",
        lca == "04" ~ "S12000035",
        lca == "05" ~ "S12000026",
        lca == "06" ~ "S12000005",
        lca == "07" ~ "S12000039",
        lca == "08" ~ "S12000006",
        lca == "09" ~ "S12000042",
        lca == "10" ~ "S12000008",
        lca == "11" ~ "S12000045",
        lca == "12" ~ "S12000010",
        lca == "13" ~ "S12000011",
        lca == "14" ~ "S12000036",
        lca == "15" ~ "S12000014",
        lca == "16" ~ "S12000047",
        lca == "17" ~ "S12000046",
        lca == "18" ~ "S12000017",
        lca == "19" ~ "S12000018",
        lca == "20" ~ "S12000019",
        lca == "21" ~ "S12000020",
        lca == "22" ~ "S12000021",
        lca == "23" ~ "S12000044",
        lca == "24" ~ "S12000023",
        lca == "25" ~ "S12000048",
        lca == "26" ~ "S12000038",
        lca == "27" ~ "S12000027",
        lca == "28" ~ "S12000028",
        lca == "29" ~ "S12000029",
        lca == "30" ~ "S12000030",
        lca == "31" ~ "S12000040",
        lca == "32" ~ "S12000013"
      ),
      # Finally, use hscp2018 to fill hbrescode
      hbrescode = dplyr::case_when(
        !is_missing(hbrescode) ~ hbrescode,
        hscp2018 %in% c(
          "S37000008",
          "S37000020",
          "S37000027"
        ) ~ "S08000015",
        hscp2018 %in% c("S37000025") ~ "S08000016",
        hscp2018 %in% c("S37000006") ~ "S08000017",
        hscp2018 %in% c(
          "S37000005",
          "S37000013"
        ) ~ "S08000019",
        hscp2018 %in% c(
          "S37000001",
          "S37000002",
          "S37000019"
        ) ~ "S08000020",
        hscp2018 %in% c(
          "S37000009",
          "S37000011",
          "S37000015",
          "S37000017",
          "S37000024",
          "S37000029"
        ) ~ "S08000021",
        hscp2018 %in% c(
          "S37000004",
          "S37000016"
        ) ~ "S08000022",
        hscp2018 %in% c(
          "S37000021",
          "S37000028"
        ) ~ "S08000023",
        hscp2018 %in% c(
          "S37000010",
          "S37000012",
          "S37000018",
          "S37000030"
        ) ~ "S08000024",
        hscp2018 %in% c("S37000022") ~ "S08000025",
        hscp2018 %in% c("S37000026") ~ "S08000026",
        hscp2018 %in% c("S37000031") ~ "S08000028",
        hscp2018 %in% c("S37000032") ~ "S08000029",
        hscp2018 %in% c(
          "S37000003",
          "S37000007",
          "S37000033"
        ) ~ "S08000030"
      )
    )

  return(data)
}

#' Recode Health Board code to 2018 standard
#'
#' @param hb_variable A vector of Health Board codes
#'
#' @return A vector of Health Board codes in the 2018 standard
recode_health_boards <- function(hb_variable) {
  hb_recoded <- dplyr::case_when(
    # HB2014 to HB2018
    hb_variable == "S08000018" ~ "S08000029",
    hb_variable == "S08000027" ~ "S08000030",
    # HB2019 to HB2018
    hb_variable == "S08000031" ~ "S08000021",
    hb_variable == "S08000032" ~ "S08000023",
    TRUE ~ hb_variable
  )

  return(hb_recoded)
}

#' Recode HSCP code to 2018 standard
#'
#' @param hscp_variable A vector of HSCP codes
#'
#' @return A vector of HSCP codes in the 2018 standard
recode_hscp <- function(hscp_variable) {
  hscp_recoded <- dplyr::case_when(
    # HSCP2016 to HSCP2018
    hscp_variable == "S37000014" ~ "S37000032",
    hscp_variable == "S37000023" ~ "S37000033",
    # hscp2018 to HSCP2018
    hscp_variable == "S37000034" ~ "S37000015",
    hscp_variable == "S37000035" ~ "S37000021",
    # Recode some strange dummy codes which seem to come from A&E
    hscp_variable %in% c("S37999998", "S37999999") ~ NA_character_,
    TRUE ~ hscp_variable
  )

  return(hscp_recoded)
}
