test <- haven::read_sav("/conf/sourcedev/Source_Linkage_File_Updates/1920/temp-source-episode-file-7-1920.zsav",
  n_max = 1000000
)

# Recoding hb codes to 2018 standard ----
test2 <- test %>% tidylog::mutate(dplyr::across(
  c(hbrescode, hbpraccode, hbtreatcode),
  ~ dplyr::case_when(
    # HB2014 to HB2018
    . == "S08000018" ~ "S08000029",
    . == "S08000027" ~ "S08000030",
    # HB2019 to HB2018
    . == "S08000031" ~ "S08000021",
    . == "S08000032" ~ "S08000023",
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
)

# Making postcodes into 7-character format ----
test3 <- test2 %>% dplyr::mutate(
  postcode = dplyr::case_when(
    # When postcode is format "G11AB" make it "G1  1AB"
    stringr::str_length(postcode) == 5 ~ stringr::str_c(
      stringr::str_sub(postcode, 1, stringr::str_length(postcode) - 3), "  ",
      stringr::str_sub(postcode, stringr::str_length(postcode) - 2, -1)
    ),
    # When postcode is format "G121AB" make it "G12 1AB"
    stringr::str_length(postcode) == 6 ~ stringr::str_c(
      stringr::str_sub(postcode, 1, stringr::str_length(postcode) - 3), " ",
      stringr::str_sub(postcode, stringr::str_length(postcode) - 2, -1)
    ),
    # Don't change postcodes that are already length 7
    stringr::str_length(postcode) == 7 ~ postcode,
    # Remove the spaces in any postcode of length 8
    stringr::str_length(postcode) == 8 ~ stringr::str_remove(postcode, " "),
    TRUE ~ postcode
  )
)

# Rename to keep the existing geographies for now, in case the postcode can't be matched ----
test4 <- test3 %>% dplyr::rename(
  lca_old = lca,
  hscp_old = HSCP,
  datazone_old = DataZone,
  hbrescode_old = hbrescode
)

# Get a data frame with the rows that can and can't be matched ----
test5 <- dplyr::bind_rows(
  # First, get all the rows that do match, and give the variable postcode_match = 1
  dplyr::inner_join(
    test4,
    readr::read_rds(fs::path(get_slf_dir(), "Lookups/source_postcode_lookup_Sep_2022.rds")) %>%
      dplyr::select(-(hb2018:dplyr::last_col())),
    by = "postcode"
  ) %>%
    dplyr::mutate(postcode_match = 1),
  # For the rows that do not match, give value of postcode_match = 0
  dplyr::anti_join(
    test4,
    readr::read_rds(fs::path(get_slf_dir(), "Lookups/source_postcode_lookup_Sep_2022.rds")) %>%
      dplyr::select(-(hb2018:dplyr::last_col())),
    by = "postcode"
  ) %>%
    dplyr::mutate(postcode_match = 0)
)

# Create all_match, the mean of postcode_match, for those chis that have ----
# some matched and some unmatched ----
test6 <- test5 %>%
  dtplyr::lazy_dt() %>%
  dplyr::group_by(chi) %>%
  dplyr::summarise(all_match = mean(postcode_match)) %>%
  dplyr::ungroup() %>%
  tibble::as_tibble()

# Fill in NA postcodes ----
test7 <- dplyr::left_join(test5, test6, by = "chi") %>%
  dplyr::mutate(potentially_fixable = !is_missing(chi) & (all_match != 0 & all_match != 1)) %>%
  dplyr::filter(potentially_fixable == TRUE) %>%
  dplyr::group_by(chi) %>%
  # Arrange by one of the keydates so the most recent postcode is at the top even if it's NA
  # Then fill the values of postcode upwards so the NA is filled in
  dplyr::arrange(desc(is.na(postcode)), desc(keydate2_dateformat), .by_group = TRUE) %>%
  tidylog::mutate(postcode = dplyr::if_else(postcode == "NK010AA", NA_character_, postcode)) %>%
  tidyr::fill(postcode, .direction = "up") %>%
  dplyr::ungroup()

# This code fills in all of a person's postcodes with the most recent one based on ----
# keydate2, but I don't know if it actually needs to be done so I'm leaving it out for now ----
test7.5 <- test7 %>%
  dplyr::group_by(chi) %>%
  dplyr::mutate(postcode_count = dplyr::n_distinct(postcode)) %>%
  dplyr::select(chi, postcode, postcode_count, keydate2_dateformat) %>%
  dplyr::arrange(desc(keydate2_dateformat), .by_group = TRUE) %>%
  dplyr::mutate(postcode = dplyr::if_else(dplyr::row_number() != 1, NA_character_, postcode)) %>%
  tidyr::fill(postcode, .direction = "down")

# Join the missing postcode set and the non-missing ----
test8 <- dplyr::bind_rows(
  test7,
  dplyr::left_join(test5, test6, by = "chi") %>%
    dplyr::mutate(potentially_fixable = !is_missing(chi) & (all_match != 0 & all_match != 1)) %>%
    dplyr::filter(potentially_fixable == FALSE)
) %>%
  dplyr::select(-all_match, -potentially_fixable, -postcode_match)

# Same as before, but this time we want to keep the geography variables ----
test9 <- dplyr::bind_rows(
  # First, get all the rows that do match, and give the variable postcode_match = 1
  dplyr::inner_join(
    test8,
    readr::read_rds(fs::path(get_slf_dir(), "Lookups/source_postcode_lookup_Sep_2022.rds")) %>%
      dplyr::rename(hbrescode = hb2018),
    by = "postcode"
  ) %>%
    dplyr::mutate(postcode_match = 1),
  # For the rows that do not match, give value of postcode_match = 0
  dplyr::anti_join(
    test8,
    readr::read_rds(fs::path(get_slf_dir(), "Lookups/source_postcode_lookup_Sep_2022.rds")) %>%
      dplyr::rename(hbrescode = hb2018),
    by = "postcode"
  ) %>%
    dplyr::mutate(postcode_match = 0)
)

# If there's still not a match, use the variables from our original file ----
test10 <- test9 %>% dplyr::mutate(
  lca = dplyr::if_else(postcode_match == 0, lca_old, lca),
  hscp2018 = dplyr::if_else(postcode_match == 0, hscp_old, hscp2018),
  datazone2011 = dplyr::if_else(postcode_match == 0, datazone_old, datazone2011),
  hbrescode = dplyr::if_else(postcode_match == 0, hbrescode_old, hbrescode)
)

# Recoding the geographies ----
test11 <- test10 %>%
  # Recode some strange dummy codes which seem to come from A&E
  tidylog::mutate(
    hscp2018 = dplyr::case_when(
      hscp2018 %in% c("S37999998", "S37999999") ~ "",
      TRUE ~ hscp2018
    ),
    # If we can, 'cascade' the geographies upwards
    # i.e. if they have an LCA use this to fill in HSCP2018 and so on for hbrescode
    # Codes are correct as at August 2018
    lca = dplyr::case_when(
      is_missing(lca) & hscp2018 == "S37000001" ~ "01",
      is_missing(lca) & hscp2018 == "S37000002" ~ "02",
      is_missing(lca) & hscp2018 == "S37000003" ~ "03",
      is_missing(lca) & hscp2018 == "S37000004" ~ "04",
      is_missing(lca) & hscp2018 == "S37000025" ~ "05",
      is_missing(lca) & hscp2018 == "S37000029" ~ "07",
      is_missing(lca) & hscp2018 == "S37000006" ~ "08",
      is_missing(lca) & hscp2018 == "S37000007" ~ "09",
      is_missing(lca) & hscp2018 == "S37000008" ~ "10",
      is_missing(lca) & hscp2018 == "S37000009" ~ "11",
      is_missing(lca) & hscp2018 == "S37000010" ~ "12",
      is_missing(lca) & hscp2018 == "S37000011" ~ "13",
      is_missing(lca) & hscp2018 == "S37000012" ~ "14",
      is_missing(lca) & hscp2018 == "S37000013" ~ "15",
      is_missing(lca) & hscp2018 == "S37000032" ~ "16",
      is_missing(lca) & hscp2018 == "S37000015" ~ "17",
      is_missing(lca) & hscp2018 == "S37000016" ~ "18",
      is_missing(lca) & hscp2018 == "S37000017" ~ "19",
      is_missing(lca) & hscp2018 == "S37000018" ~ "20",
      is_missing(lca) & hscp2018 == "S37000019" ~ "21",
      is_missing(lca) & hscp2018 == "S37000020" ~ "22",
      is_missing(lca) & hscp2018 == "S37000021" ~ "23",
      is_missing(lca) & hscp2018 == "S37000022" ~ "24",
      is_missing(lca) & hscp2018 == "S37000033" ~ "25",
      is_missing(lca) & hscp2018 == "S37000024" ~ "26",
      is_missing(lca) & hscp2018 == "S37000026" ~ "27",
      is_missing(lca) & hscp2018 == "S37000027" ~ "28",
      is_missing(lca) & hscp2018 == "S37000028" ~ "29",
      is_missing(lca) & hscp2018 == "S37000030" ~ "31",
      is_missing(lca) & hscp2018 == "S37000031" ~ "32",
      TRUE ~ lca
    ),
    # Next, use LCA to fill in hscp2018 if possible
    hscp2018 = dplyr::case_when(
      is_missing(hscp2018) & lca == "01" ~ "S37000001",
      is_missing(hscp2018) & lca == "02" ~ "S37000002",
      is_missing(hscp2018) & lca == "03" ~ "S37000003",
      is_missing(hscp2018) & lca == "04" ~ "S37000004",
      is_missing(hscp2018) & lca == "05" ~ "S37000025",
      is_missing(hscp2018) & lca == "06" ~ "S37000005",
      is_missing(hscp2018) & lca == "07" ~ "S37000029",
      is_missing(hscp2018) & lca == "08" ~ "S37000006",
      is_missing(hscp2018) & lca == "09" ~ "S37000007",
      is_missing(hscp2018) & lca == "10" ~ "S37000008",
      is_missing(hscp2018) & lca == "11" ~ "S37000009",
      is_missing(hscp2018) & lca == "12" ~ "S37000010",
      is_missing(hscp2018) & lca == "13" ~ "S37000011",
      is_missing(hscp2018) & lca == "14" ~ "S37000012",
      is_missing(hscp2018) & lca == "15" ~ "S37000013",
      is_missing(hscp2018) & lca == "16" ~ "S37000032",
      is_missing(hscp2018) & lca == "17" ~ "S37000015",
      is_missing(hscp2018) & lca == "18" ~ "S37000016",
      is_missing(hscp2018) & lca == "19" ~ "S37000017",
      is_missing(hscp2018) & lca == "20" ~ "S37000018",
      is_missing(hscp2018) & lca == "21" ~ "S37000019",
      is_missing(hscp2018) & lca == "22" ~ "S37000020",
      is_missing(hscp2018) & lca == "23" ~ "S37000021",
      is_missing(hscp2018) & lca == "24" ~ "S37000022",
      is_missing(hscp2018) & lca == "25" ~ "S37000033",
      is_missing(hscp2018) & lca == "26" ~ "S37000024",
      is_missing(hscp2018) & lca == "27" ~ "S37000026",
      is_missing(hscp2018) & lca == "28" ~ "S37000027",
      is_missing(hscp2018) & lca == "29" ~ "S37000028",
      is_missing(hscp2018) & lca == "30" ~ "S37000005",
      is_missing(hscp2018) & lca == "31" ~ "S37000030",
      is_missing(hscp2018) & lca == "32" ~ "S37000031",
      TRUE ~ hscp2018
    ),
    # Next, use LCA to fill in ca2018
    ca2018 = dplyr::case_when(
      is_missing(ca2018) & lca == "01" ~ "S12000033",
      is_missing(ca2018) & lca == "02" ~ "S12000034",
      is_missing(ca2018) & lca == "03" ~ "S12000041",
      is_missing(ca2018) & lca == "04" ~ "S12000035",
      is_missing(ca2018) & lca == "05" ~ "S12000026",
      is_missing(ca2018) & lca == "06" ~ "S12000005",
      is_missing(ca2018) & lca == "07" ~ "S12000039",
      is_missing(ca2018) & lca == "08" ~ "S12000006",
      is_missing(ca2018) & lca == "09" ~ "S12000042",
      is_missing(ca2018) & lca == "10" ~ "S12000008",
      is_missing(ca2018) & lca == "11" ~ "S12000045",
      is_missing(ca2018) & lca == "12" ~ "S12000010",
      is_missing(ca2018) & lca == "13" ~ "S12000011",
      is_missing(ca2018) & lca == "14" ~ "S12000036",
      is_missing(ca2018) & lca == "15" ~ "S12000014",
      is_missing(ca2018) & lca == "16" ~ "S12000047",
      is_missing(ca2018) & lca == "17" ~ "S12000046",
      is_missing(ca2018) & lca == "18" ~ "S12000017",
      is_missing(ca2018) & lca == "19" ~ "S12000018",
      is_missing(ca2018) & lca == "20" ~ "S12000019",
      is_missing(ca2018) & lca == "21" ~ "S12000020",
      is_missing(ca2018) & lca == "22" ~ "S12000021",
      is_missing(ca2018) & lca == "23" ~ "S12000044",
      is_missing(ca2018) & lca == "24" ~ "S12000023",
      is_missing(ca2018) & lca == "25" ~ "S12000048",
      is_missing(ca2018) & lca == "26" ~ "S12000038",
      is_missing(ca2018) & lca == "27" ~ "S12000027",
      is_missing(ca2018) & lca == "28" ~ "S12000028",
      is_missing(ca2018) & lca == "29" ~ "S12000029",
      is_missing(ca2018) & lca == "30" ~ "S12000030",
      is_missing(ca2018) & lca == "31" ~ "S12000040",
      is_missing(ca2018) & lca == "32" ~ "S12000013",
      TRUE ~ ca2018
    ),
    # Finally, use hscp2018 to fill hbrescode
    hbrescode = dplyr::case_when(
      is_missing(hbrescode) & hscp2019 %in% c("S37000008", "S37000020", "S37000027") ~ "S08000015",
      is_missing(hbrescode) & hscp2019 %in% c("S37000025") ~ "S08000016",
      is_missing(hbrescode) & hscp2019 %in% c("S37000006") ~ "S08000017",
      is_missing(hbrescode) & hscp2019 %in% c("S37000005", "S37000013") ~ "S08000019",
      is_missing(hbrescode) & hscp2019 %in% c("S37000001", "S37000002", "S37000019") ~ "S08000020",
      is_missing(hbrescode) & hscp2019 %in% c(
        "S37000009", "S37000011", "S37000015",
        "S37000017", "S37000024", "S37000029"
      ) ~ "S08000021",
      is_missing(hbrescode) & hscp2019 %in% c("S37000004", "S37000016") ~ "S08000022",
      is_missing(hbrescode) & hscp2019 %in% c("S37000021", "S37000028") ~ "S08000023",
      is_missing(hbrescode) & hscp2019 %in% c(
        "S37000010", "S37000012", "S37000018",
        "S37000030"
      ) ~ "S08000024",
      is_missing(hbrescode) & hscp2019 %in% c("S37000022") ~ "S08000025",
      is_missing(hbrescode) & hscp2019 %in% c("S37000026") ~ "S08000026",
      is_missing(hbrescode) & hscp2019 %in% c("S37000031") ~ "S08000028",
      is_missing(hbrescode) & hscp2019 %in% c("S37000032") ~ "S08000029",
      is_missing(hbrescode) & hscp2019 %in% c("S37000003", "S37000007", "S37000033") ~ "S08000030",
      TRUE ~ hbrescode
    )
  )

# Doing a similar process with gpprac as we did with postcode ----
test12 <- test11 %>%
  dplyr::rename(hbpraccode_old = hbpraccode)

test13 <- dplyr::bind_rows(
    # First, get all the rows that do match, and give the variable gpprac_match = 1
    dplyr::inner_join(
      test12,
      readr::read_rds(fs::path(get_slf_dir(), "Lookups/source_GPprac_lookup_Sep_2022.rds")) %>%
        dplyr::select(-(2:dplyr::last_col())),
      by = "gpprac"
    ) %>% dplyr::mutate(gpprac_match = 1),
    # For the rows that do not match, give value of gpprac_match = 0
    dplyr::anti_join(
      test12,
      readr::read_rds(fs::path(get_slf_dir(), "Lookups/source_GPprac_lookup_Sep_2022.rds")) %>%
        dplyr::select(-(2:dplyr::last_col())),
      by = "gpprac"
    ) %>% dplyr::mutate(gpprac_match = 0)
  )

test14 <- test13 %>%
  dplyr::mutate(gpprac_match = dplyr::if_else(
    gpprac %in% c(99942, 99957, 99961, 99976, 99981, 99995, 99999), 0, gpprac_match
  )) %>%
  dtplyr::lazy_dt() %>%
  dplyr::group_by(chi) %>%
  dplyr::summarise(all_match = mean(gpprac_match)) %>%
  dplyr::ungroup() %>%
  tibble::as_tibble()

test15 <- dplyr::left_join(test13, test14, by = "chi") %>%
  dplyr::mutate(potentially_fixable = !is_missing(chi) & (all_match != 0 & all_match != 1)) %>%
  dplyr::filter(potentially_fixable == TRUE) %>%
  dplyr::group_by(chi) %>%
  # Arrange by one of the keydates so the most recent gpprac is at the top even if it's NA
  # Then fill the values of gpprac upwards so the NA is filled in
  dplyr::arrange(desc(is.na(gpprac)), desc(keydate2_dateformat), .by_group = TRUE) %>%
  tidylog::mutate(gpprac = dplyr::if_else(postcode == 9999, NA_real_, gpprac)) %>%
  tidyr::fill(postcode, .direction = "up") %>%
  dplyr::ungroup()

test16 <- dplyr::bind_rows(
  test15,
  dplyr::left_join(test13, test14, by = "chi") %>%
    dplyr::mutate(potentially_fixable = !is_missing(chi) & (all_match != 0 & all_match != 1)) %>%
    dplyr::filter(potentially_fixable == FALSE)
) %>%
  dplyr::select(-all_match, -potentially_fixable, -gpprac_match)

test17 <- dplyr::bind_rows(
  # First, get all the rows that do match, and give the variable gpprac_match = 1
  dplyr::inner_join(
    test16,
    readr::read_rds(fs::path(get_slf_dir(), "Lookups/source_GPprac_lookup_Sep_2022.rds")) %>%
      dplyr::select(gpprac, hbpraccode, cluster),
    by = "gpprac"
  ) %>% dplyr::mutate(gpprac_match = 1),
  # For the rows that do not match, give value of gpprac_match = 0
  dplyr::anti_join(
    test16,
    readr::read_rds(fs::path(get_slf_dir(), "Lookups/source_GPprac_lookup_Sep_2022.rds")) %>%
      dplyr::select(gpprac, hbpraccode, cluster),
    by = "gpprac"
  ) %>% dplyr::mutate(gpprac_match = 0)
) %>%
  dplyr::mutate(hbpraccode = dplyr::if_else(gpprac_match == 0, hbpraccode_old, hbpraccode),
                gpprac = dplyr::if_else(gpprac_match == 0 & is_missing(hppraccode), NA_real_, gpprac))

# Here is a section in SPSS for adding value labels, maybe we could do this with factors?

# The end


