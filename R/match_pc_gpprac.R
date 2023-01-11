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
    # HSCP2019 to HSCP2018
    hscp_variable == "S37000034" ~ "S37000015",
    hscp_variable == "S37000035" ~ "S37000021",
    TRUE ~ hscp_variable
  )
  return(hscp_recoded)
}

#' Rename existing geographies from temporary file to preserve them
#' during transformations
#'
#' @param data A data frame
#' @param vars A vector of variable names to rename. Default is that "lca",
#' "HSCP", "DataZone" and "hbrescode" will be renamed
#'
#' @return A data frame with the variables from vars appended with "_old"
rename_existing_geographies <- function(data,
                                        vars = c("lca", "HSCP", "DataZone", "hbrescode")) {
  check_variables_exist(data, vars)

  return_data <- data %>%
    dplyr::rename_with(
      ~ paste0(.x, "_old"),
      .cols = vars
    )
  return(return_data)
}

#' Use the SLF postcode lookup to determine which rows have a known postcode and
#' which do not, or which have a matching GP practice and which do not
#'
#' @param data A data frame with a postcode variable
#' @param lookup The SLF postcode lookup
#' @param type Either "pc" for postcode or "gp" for GP
#'
#' @seealso [get_slf_postcode_path()]
#'
#' @return A data frame with an integer variable postcode_match, where 1 denotes
#' a match in the lookup and 0 denotes no match
flag_matching_data <- function(data, lookup, type = c("pc", "gp")) {
  if (type == "pc") {
    return_data <- dplyr::bind_rows(
      # First, get all the rows that do match,
      # and give the variable postcode_match = 1
      dplyr::inner_join(data, pc_lookup, by = "postcode") %>%
        dplyr::mutate(postcode_match = 1L),
      # For the rows that do not match, give value of postcode_match = 0
      dplyr::anti_join(data, pc_lookup, by = "postcode") %>%
        dplyr::mutate(postcode_match = 0L)
    )
  } else if (type == "gp") {
    return_data <- dplyr::bind_rows(
      # First, get all the rows that do match, and give the variable gpprac_match = 1
      dplyr::inner_join(data, lookup, by = "gpprac") %>%
        dplyr::mutate(gpprac_match = 1L),
      # For the rows that do not match, give value of gpprac_match = 0
      dplyr::anti_join(data, lookup, by = "gpprac") %>%
        dplyr::mutate(gpprac_match = 0L)
    )
  }

  return(return_data)
}

#' Use the mean to find situations where postcodes do not match over
#' chi groups
#'
#' @param data A data frame
#' @param match_variable Can be postcode_match or gpprac_match
#'
#' @return A data frame with variable all_match, which is 0 or 1 if all
#' postcodes match and a real number between 0 and 1 when they don't
find_matching_data_by_chi <- function(data, match_variable) {

  # Create all_match, the mean of the match variable, for those chis that have
  # some matched and some unmatched
  return_data <- data %>%
    dplyr::group_by(chi) %>%
    dplyr::summarise(all_match = mean({{match_variable}})) %>%
    dplyr::ungroup()

  return(return_data)
}

#' Use situations where some records for a chi have a postcode to fill
#' those that are missing
#'
#' @param data A data frame
#' @param matching_data A data frame processed through [find_matching_data_by_chi()]
#' @param type Either pc for pastcodes or gp for GP practices
#'
#' @return A data frame with some missing data filled based on type
fill_data_from_chi <- function(data, matching_data, type = c("pc", "gp")) {
  if (type == "pc") {
    return_data <-
      dplyr::left_join(data,
        matching_data,
        by = "chi"
      ) %>%
      # If the chi isn't missing and all_match isn't exactly 0 or 1,
      # we can potentially fill the postcodes for that chi
      dplyr::filter(!is_missing(chi) & !is.integer(all_match)) %>%
      dplyr::group_by(chi) %>%
      # Arrange by one of the keydates so the most recent postcode is at the top even if it's NA
      # Then fill the values of postcode upwards so the NA is filled in
      dplyr::arrange(
        dplyr::desc(is.na(postcode)),
        dplyr::desc(keydate2_dateformat),
        .by_group = TRUE
      ) %>%
      # "NK010AA" is a known dummy postcode, so we replace this with NA
      dplyr::mutate(postcode = dplyr::if_else(postcode == "NK010AA",
        NA_character_,
        postcode
      )) %>%
      # Now we can fill the postcodes for these chis
      tidyr::fill(postcode, .direction = "up") %>%
      dplyr::ungroup()
  } else if (type == "gp") {
    return_data <- dplyr::left_join(data_gpprac_match, data_for_matching, by = "chi") %>%
      dplyr::filter(!is_missing(chi) & !is.integer(all_match)) %>%
      dplyr::group_by(chi) %>%
      # Arrange by one of the keydates so the most recent gpprac is at the top even if it's NA
      # Then fill the values of gpprac upwards so the NA is filled in
      dplyr::arrange(
        dplyr::desc(is.na(gpprac)),
        dplyr::desc(keydate2_dateformat),
        .by_group = TRUE
      ) %>%
      dplyr::mutate(gpprac = dplyr::if_else(gpprac == 99999L, NA_real_, gpprac)) %>%
      tidyr::fill(postcode, .direction = "up") %>%
      dplyr::ungroup()
  }

  return(return_data)
}

#' Use the postcode from the most recent contact with an
#' individual to fill missing data
#'
#' @param data A data frame
#' @param var_to_fill The variable we're looking to fill
#' @type Either pc for pastcodes or gp for GP practices
#'
#' @return A data frame with some missing data filled
fill_data_from_keydate <- function(data, var_to_fill, type = c("pc", "gp")) {

  if (type == "pc") {
    na_type <- NA_character_
  } else if (type == "gp") {
    na_type <- NA_integer_
  }

  return_data <- data %>%
    dplyr::group_by(chi) %>%
    # Determine whether a chi has multiple postcodes
    dplyr::mutate(count = dplyr::n_distinct({{ var_to_fill }})) %>%
    dplyr::select("chi", "var_to_fill", "count", "keydate2_dateformat") %>%
    # Put the most recent contact at the top of each chi group
    dplyr::arrange(dplyr::desc(keydate2_dateformat), .by_group = TRUE) %>%
    # Recode any postcodes that are not the most recent with NA
    dplyr::mutate(var_to_fill = dplyr::if_else(dplyr::row_number() != 1,
      na_type,
      {{ var_to_fill }}
    )) %>%
    # Fill all the new NAs with the most recent postcode
    tidyr::fill({{ var_to_fill }}, .direction = "down")

  return(return_data)
}

#' Read the SLF postcode lookup and remove unnecessary variables
#'
#' @param lookup Can be either "pc" for Postcode or "gp" for GP Practice
#' @param trim When TRUE then trims the selected lookup to have limited geographies
#'
#' @return The lookup of the selected type
#' @seealso [get_slf_postcode_path()] and [get_slf_gpprac_path()]
read_and_trim_lookup <- function(lookup = c("pc", "gp"), trim = TRUE) {

  if (lookup == "pc") {
    if (trim == TRUE) {
      lookup <- readr::read_rds(get_slf_postcode_path()) %>%
        dplyr::select(-c("hb2018":dplyr::last_col()))
    } else {
      lookup <- readr::read_rds(get_slf_postcode_path()) %>%
        dplyr::rename(hbrescode = "hb2018")
    }
  }

  if (lookup == "gp") {
    if (trim == TRUE) {
      lookup <- readr::read_rds(get_slf_gpprac_path()) %>%
        dplyr::select(-(2:dplyr::last_col()))
    } else {
      lookup <- readr::read_rds(get_slf_gpprac_path()) %>%
        dplyr::select("gpprac", "hbpraccode", "cluster")
    }
  }

  return(lookup)
}

#' Use the SLF postcode lookup to ensure missing postcodes are filled
#'
#' @param data An episode file
#'
#' @return Data with any potentially fixable postcodes filled in
#' @export
match_postcodes_and_fill_missing <- function(data) {

  data_recoded <- data %>%
    dplyr::mutate(
      hbtreatcode = as.character.Date(hbtreatcode),
      # Recoding hb codes to 2018 standard
      dplyr::across(
        c("hbrescode", "hbpraccode", "hbtreatcode"), ~ recode_health_boards(.)),
      # Recoding hscp codes to 2018 standard
      HSCP = recode_hscp(hscp_variable = HSCP),
      # Making postcodes into 7-character format
      postcode = phsmethods::format_postcode(postcode, format = "pc7")
    ) %>%
    rename_existing_geographies()

  data_postcode_flagged <- data_recoded %>%
    flag_matching_data(lookup = read_and_trim_pc_lookup(lookup = "pc", trim = TRUE),
                       type = "pc")

  data_for_matching <- data_postcode_flagged %>%
    find_matching_data_by_chi(match_variable = postcode_match)

  data_postcode_filled <- data_postcode_flagged %>%
    fill_data_from_chi(matching_data = data_for_matching, type = "pc") %>%
    fill_data_from_keydate(var_to_fill = postcode, type = "pc") %>%
    # Bind together our filled data frame with the subset
    # where the postcodes were not potentially fixable
    dplyr::bind_rows(.,
      dplyr::left_join(data_postcode_flagged,
                       data_for_matching,
                       by = "chi") %>%
      dplyr::filter(!(!is_missing(chi) & !is.integer(all_match)))) %>%
    # Remove unnecessary variables
    dplyr::select(-"all_match", -"postcode_match")
}

match_gp_practice <- function(data) {

  # Same as before, but this time we want to keep the geography variables
  data_gpprac <- data %>%
    flag_matching_postcodes(read_and_trim_pc_lookup(lookup = "pc", trim = FALSE)) %>%
    # If there's still not a match, use the variables from our original file
    dplyr::mutate(
      lca = dplyr::if_else(postcode_match == 0L, lca_old, lca),
      hscp2018 = dplyr::if_else(postcode_match == 0L, hscp_old, hscp2018),
      datazone2011 = dplyr::if_else(postcode_match == 0L, datazone_old, datazone2011),
      hbrescode = dplyr::if_else(postcode_match == 0L, hbrescode_old, hbrescode)
    ) %>%
    # Recoding the geographies
    match_hscp_lca_code() %>%
    # Doing a similar process with gpprac as we did with postcode ----
    dplyr::rename(hbpraccode_old = hbpraccode)

  data_gpprac_flagged <- data_gpprac %>%
    flag_matching_data(lookup = read_and_trim_lookup(lookup = "gp", trim = TRUE),
                       type = "gp")

  data_for_matching <- data_gpprac_flagged %>%
    # Replace known dummy practice codes with zero
    dplyr::mutate(gpprac_match = dplyr::if_else(
      gpprac %in% c(99942L, 99957L, 99961L, 99976L, 99981L, 99995L, 99999L),
      0L,
      gpprac_match)) %>%
    find_matching_data_by_chi(match_variable = gpprac_match)

  data_gpprac_filled <- data_gpprac_flagged %>%
    fill_data_from_chi(matching_data = data_for_matching,
                      type = "gp")

  data_gpprac_3 <- dplyr::bind_rows(
    data_gpprac_2,
    dplyr::left_join(data_gpprac_match, data_gpprac_match_info, by = "chi") %>%
      dplyr::mutate(
        potentially_fixable = !is_missing(chi) &
          (all_match != 0 & all_match != 1)
      ) %>%
      dplyr::filter(!potentially_fixable)
  ) %>%
    dplyr::select(-"all_match", -"potentially_fixable", -"gpprac_match")

  data_gpprac_4 <- dplyr::bind_rows(
    # First, get all the rows that do match, and give the variable gpprac_match = 1
    dplyr::inner_join(
      data_gpprac_3,
      ggprac_lookup %>%
        dplyr::select("gpprac", "hbpraccode", "cluster"),
      by = "gpprac"
    ) %>% dplyr::mutate(gpprac_match = 1),
    # For the rows that do not match, give value of gpprac_match = 0
    dplyr::anti_join(
      data_gpprac_3,
      ggprac_lookup %>%
        dplyr::select("gpprac", "hbpraccode", "cluster"),
      by = "gpprac"
    ) %>% dplyr::mutate(gpprac_match = 0)
  ) %>%
    dplyr::mutate(
      hbpraccode = dplyr::if_else(gpprac_match == 0, hbpraccode_old, hbpraccode),
      gpprac = dplyr::if_else(gpprac_match == 0 &
        is_missing(hbpraccode), NA_real_, gpprac)
    )

  return(data_gpprac_4)
}
