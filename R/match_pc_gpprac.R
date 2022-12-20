#' Match postcode with GP Practice
#'
#' @description Match postcode with GP Practice
#'
#' @param data episode files
#'
#' @return data with matched postcode
#' @export
match_pc_gpprac <- function(data) {
  # Recoding hb codes to 2018 standard ----
  data_hb_pc <- data %>%
    dplyr::mutate(hbtreatcode = as.character.Date(hbtreatcode)) %>%
    dplyr::mutate(
      dplyr::across(
        c(hbrescode, hbpraccode, hbtreatcode),
        ~ dplyr::case_when(
          # HB2014 to HB2018
          .data == "S08000018" ~ "S08000029",
          .data == "S08000027" ~ "S08000030",
          # HB2019 to HB2018
          .data == "S08000031" ~ "S08000021",
          .data == "S08000032" ~ "S08000023",
          TRUE ~ .
        )
      ),
      HSCP = dplyr::case_when(
        # HSCP2016 to HSCP2018
        HSCP == "S37000014" ~ "S37000032",
        HSCP == "S37000023" ~ "S37000033",
        # HSCP2019 to HSCP2018
        HSCP == "S37000034" ~ "S37000015",
        HSCP == "S37000035" ~ "S37000021",
        TRUE ~ HSCP
      )
    ) %>%
    # Making postcodes into 7-character format ----
    dplyr::mutate(
      postcode = dplyr::case_when(
        # When postcode is format "G11AB" make it "G1  1AB"
        stringr::str_length(postcode) == 5 ~ stringr::str_c(
          stringr::str_sub(postcode, 1, stringr::str_length(postcode) - 3),
          "  ",
          stringr::str_sub(postcode, stringr::str_length(postcode) - 2, -1)
        ),
        # When postcode is format "G121AB" make it "G12 1AB"
        stringr::str_length(postcode) == 6 ~ stringr::str_c(
          stringr::str_sub(postcode, 1, stringr::str_length(postcode) - 3),
          " ",
          stringr::str_sub(postcode, stringr::str_length(postcode) - 2, -1)
        ),
        # Don't change postcodes that are already length 7
        stringr::str_length(postcode) == 7 ~ postcode,
        # Remove the spaces in any postcode of length 8
        stringr::str_length(postcode) == 8 ~ stringr::str_remove(postcode, " "),
        TRUE ~ postcode
      )
    )

  ## Rename to keep the existing geographies for now, in case the postcode can't be matched ----
  data_hb_pc_1 <- data_hb_pc %>% dplyr::rename(
    lca_old = lca,
    hscp_old = HSCP,
    datazone_old = DataZone,
    hbrescode_old = hbrescode
  )

  pc_lookup <-
    readr::read_rds(fs::path(
      get_slf_dir(),
      "Lookups/source_postcode_lookup_Sep_2022.rds"
    ))

  ## Get a data frame with the rows that can and can't be matched ----
  data_hb_pc_2 <- dplyr::bind_rows(
    # First, get all the rows that do match, and give the variable postcode_match = 1
    dplyr::inner_join(data_hb_pc_1,
      pc_lookup %>% dplyr::select(-c(
        "hb2018":dplyr::last_col()
      )),
      by = "postcode"
    ) %>%
      dplyr::mutate(postcode_match = 1),
    # For the rows that do not match, give value of postcode_match = 0
    dplyr::anti_join(data_hb_pc_1,
      pc_lookup %>% dplyr::select(-c(
        "hb2018":dplyr::last_col()
      )),
      by = "postcode"
    ) %>%
      dplyr::mutate(postcode_match = 0)
  )

  # Create all_match, the mean of postcode_match, for those chis that have
  ## some matched and some unmatched ----
  data_match_info <- data_hb_pc_2 %>%
    dtplyr::lazy_dt() %>%
    dplyr::group_by(chi) %>%
    dplyr::summarise(all_match = mean(postcode_match)) %>%
    dplyr::ungroup() %>%
    tibble::as_tibble()

  ## Fill in NA postcodes ----
  data_pc_fill_na <-
    dplyr::left_join(data_hb_pc_2, data_match_info, by = "chi") %>%
    dplyr::mutate(
      potentially_fixable =
        !is_missing(chi) &
          (all_match != 0 & all_match != 1)
    ) %>%
    dplyr::filter(potentially_fixable == TRUE) %>%
    dplyr::group_by(chi) %>%
    # Arrange by one of the keydates so the most recent postcode is at the top even if it's NA
    # Then fill the values of postcode upwards so the NA is filled in
    dplyr::arrange(desc(is.na(postcode)), desc(keydate2_dateformat), .by_group = TRUE) %>%
    tidylog::mutate(postcode = dplyr::if_else(postcode == "NK010AA", NA_character_, postcode)) %>%
    tidyr::fill(postcode, .direction = "up") %>%
    dplyr::ungroup()

  # This code fills in all of a person's postcodes with the most recent one based on ...
  ## keydate2, but I don't know if it actually needs to be done so I'm leaving it out for now ----
  data_pc_fill_na_2 <- data_pc_fill_na %>%
    dplyr::group_by(chi) %>%
    dplyr::mutate(postcode_count = dplyr::n_distinct(postcode)) %>%
    dplyr::select(chi, postcode, postcode_count, keydate2_dateformat) %>%
    dplyr::arrange(desc(keydate2_dateformat), .by_group = TRUE) %>%
    dplyr::mutate(postcode = dplyr::if_else(dplyr::row_number() != 1, NA_character_, postcode)) %>%
    tidyr::fill(postcode, .direction = "down")

  ## Join the missing postcode set and the non-missing ----
  data_pc_full <- dplyr::bind_rows(
    data_pc_fill_na,
    dplyr::left_join(data_hb_pc_2, data_match_info, by = "chi") %>%
      dplyr::mutate(
        potentially_fixable = !is_missing(chi) &
          (all_match != 0 & all_match != 1)
      ) %>%
      dplyr::filter(potentially_fixable == FALSE)
  ) %>%
    dplyr::select(-all_match, -potentially_fixable, -postcode_match)

  ## Same as before, but this time we want to keep the geography variables ----
  data_geo_keep <- dplyr::bind_rows(
    # First, get all the rows that do match, and give the variable postcode_match = 1
    dplyr::inner_join(
      data_pc_full,
      pc_lookup %>% dplyr::rename(hbrescode = hb2018),
      by = "postcode"
    ) %>%
      dplyr::mutate(postcode_match = 1),
    # For the rows that do not match, give value of postcode_match = 0
    dplyr::anti_join(
      data_pc_full,
      pc_lookup %>% dplyr::rename(hbrescode = hb2018),
      by = "postcode"
    ) %>%
      dplyr::mutate(postcode_match = 0)
  )

  ## If there's still not a match, use the variables from our original file ----
  data_with_original <- data_geo_keep %>% dplyr::mutate(
    lca = dplyr::if_else(postcode_match == 0, lca_old, lca),
    hscp2018 = dplyr::if_else(postcode_match == 0, hscp_old, hscp2018),
    datazone2011 = dplyr::if_else(postcode_match == 0, datazone_old, datazone2011),
    hbrescode = dplyr::if_else(postcode_match == 0, hbrescode_old, hbrescode)
  )

  ## Recoding the geographies ----
  data_geo_recode <- match_hscp_lca_code(data_with_original)

  # gpprac ----
  ## Doing a similar process with gpprac as we did with postcode ----
  data_gpprac <- data_geo_recode %>%
    dplyr::rename(hbpraccode_old = hbpraccode)

  ggprac_lookup <-
    readr::read_rds(fs::path(
      get_slf_dir(),
      "Lookups/source_GPprac_lookup_Sep_2022.rds"
    ))

  data_gpprac_match <- dplyr::bind_rows(
    # First, get all the rows that do match, and give the variable gpprac_match = 1
    dplyr::inner_join(data_gpprac,
      ggprac_lookup %>%
        dplyr::select(-(
          2:dplyr::last_col()
        )),
      by = "gpprac"
    ) %>% dplyr::mutate(gpprac_match = 1),
    # For the rows that do not match, give value of gpprac_match = 0
    dplyr::anti_join(data_gpprac,
      ggprac_lookup %>%
        dplyr::select(-(
          2:dplyr::last_col()
        )),
      by = "gpprac"
    ) %>% dplyr::mutate(gpprac_match = 0)
  )

  data_gpprac_match_info <- data_gpprac_match %>%
    dplyr::mutate(gpprac_match = dplyr::if_else(
      gpprac %in% c(99942, 99957, 99961, 99976, 99981, 99995, 99999),
      0,
      gpprac_match
    )) %>%
    dtplyr::lazy_dt() %>%
    dplyr::group_by(chi) %>%
    dplyr::summarise(all_match = mean(gpprac_match)) %>%
    dplyr::ungroup() %>%
    tibble::as_tibble()

  data_gpprac_2 <-
    dplyr::left_join(data_gpprac_match, data_gpprac_match_info, by = "chi") %>%
    dplyr::mutate(potentially_fixable = !is_missing(chi) &
      (all_match != 0 & all_match != 1)) %>%
    dplyr::filter(potentially_fixable == TRUE) %>%
    dplyr::group_by(chi) %>%
    # Arrange by one of the keydates so the most recent gpprac is at the top even if it's NA
    # Then fill the values of gpprac upwards so the NA is filled in
    dplyr::arrange(desc(is.na(gpprac)), desc(keydate2_dateformat), .by_group = TRUE) %>%
    tidylog::mutate(gpprac = dplyr::if_else(postcode == 9999, NA_real_, gpprac)) %>%
    tidyr::fill(postcode, .direction = "up") %>%
    dplyr::ungroup()

  data_gpprac_3 <- dplyr::bind_rows(
    data_gpprac_2,
    dplyr::left_join(data_gpprac_match, data_gpprac_match_info, by = "chi") %>%
      dplyr::mutate(
        potentially_fixable = !is_missing(chi) &
          (all_match != 0 & all_match != 1)
      ) %>%
      dplyr::filter(potentially_fixable == FALSE)
  ) %>%
    dplyr::select(-all_match, -potentially_fixable, -gpprac_match)

  data_gpprac_4 <- dplyr::bind_rows(
    # First, get all the rows that do match, and give the variable gpprac_match = 1
    dplyr::inner_join(
      data_gpprac_3,
      ggprac_lookup %>%
        dplyr::select(gpprac, hbpraccode, cluster),
      by = "gpprac"
    ) %>% dplyr::mutate(gpprac_match = 1),
    # For the rows that do not match, give value of gpprac_match = 0
    dplyr::anti_join(
      data_gpprac_3,
      ggprac_lookup %>%
        dplyr::select(gpprac, hbpraccode, cluster),
      by = "gpprac"
    ) %>% dplyr::mutate(gpprac_match = 0)
  ) %>%
    dplyr::mutate(
      hbpraccode = dplyr::if_else(gpprac_match == 0, hbpraccode_old, hbpraccode),
      gpprac = dplyr::if_else(gpprac_match == 0 &
        is_missing(hbpraccode), NA_real_, gpprac)
    )


  return(data_gpprac_4)
  # The end
}
