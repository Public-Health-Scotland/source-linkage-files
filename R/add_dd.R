#' Add Delay Discharge to working file
#'
#' @param data The input data frame
#' @param year The year being processed
#'
#' @return A data frame linking delay discharge cohorts
#' @export
#'
#' @family episode file
add_dd <- function(data, year) {
  year_param <- year

  data = data %>%
    dplyr::arrange(chi, cij_marker) %>%
    dplyr::mutate(
      cij_start_date_lower = cij_start_date - lubridate::days(1),
      cij_end_date_upper = cij_end_date + lubridate::days(1)
    )

  ## handling DD ----
  dd_data = read_file(get_source_extract_path(year_param, "DD"))
  by_dd = dplyr::join_by(
    chi,
    x$keydate1_dateformat >= y$cij_start_date_lower,
    x$keydate2_dateformat <= y$cij_end_date_upper
  )
  data = dd_data %>%
    dplyr::inner_join(data,
                      by_dd,
                      suffix = c("_dd", "")) %>%
    dplyr::arrange(cij_start_date, cij_end_date, cij_marker, postcode) %>%
    # remove duplicate columns
    dplyr::distinct(
      cij_start_date,
      cij_end_date,
      cij_marker,
      keydate1_dateformat_dd,
      keydate2_dateformat_dd,
      .keep_all = TRUE
    ) %>%
    # determine DD quality
    dplyr::mutate(dd_type = dplyr::if_else(
      is.na(cij_marker),
      "no-cij",
      dplyr::case_when(
        # "1"	"Accurate Match - (1)"
        # "1P"	"Accurate Match (allowing +-1 day) - (1P)"
        # "1A"	"Accurate Match (has an assumed  end date) - (1A)"
        # "1AP"	"Accurate Match (allowing +-1 day and has an assumed end date) - (1AP)"
        # "2"	"Starts in CIJ - (2)"
        # "2D"	"Starts in CIJ (ends one day after) - (2D)"
        # "2DP"	"Starts in CIJ (allowing +-1 day and ends one day after) - (2DP)"
        # "2A"	"Starts in CIJ (Accurate Match after correcting assumed end date) - (2A)"
        # "2AP"	"Starts in CIJ (Accurate Match (allowing +-1 day) after correcting assumed end date) - (2AP)"
        # "3"	"Ends in CIJ - (3)"
        # "3D"	"Ends in CIJ (starts one day before) - (3D)"
        # "3DP"	"Ends in CIJ (allowing +-1 day and starts one day before) - (3DP)"
        # "4"	"Matches unended MH record - (4)"
        # "4P" "Matches unended MH record (allowing -1 day) - (4P)"
        # "-" "No Match (We don't keep these)".

        # "1"	"Accurate Match - (1)"
        keydate1_dateformat_dd >= cij_start_date &
          keydate2_dateformat_dd <= cij_end_date &
          !amended_dates ~ "1",

        # "1P"	"Accurate Match (allowing +-1 day) - (1P)"
        keydate1_dateformat_dd >= cij_start_date_lower &
          keydate2_dateformat_dd <= cij_end_date_upper &
          !amended_dates ~ "1P",

        # "1A"	"Accurate Match (has an assumed end date) - (1A)"
        keydate1_dateformat_dd >= cij_start_date &
          keydate2_dateformat_dd <= cij_end_date &
          amended_dates ~ "1P",

        # "1AP"	"Accurate Match (allowing +-1 day and has an assumed end date) - (1AP)"
        keydate1_dateformat_dd >= cij_start_date_lower &
          keydate2_dateformat_dd <= cij_end_date_upper &
          amended_dates ~ "1AP",

        # "2"	"Starts in CIJ - (2)"
        keydate1_dateformat_dd >= cij_start_date &
          keydate1_dateformat_dd <= cij_end_date &
          keydate2_dateformat_dd >= cij_end_date &
          !amended_dates ~ "2",

        # "2D"	"Starts in CIJ (ends one day after) - (2D)"
        keydate1_dateformat_dd >= cij_start_date &
          keydate1_dateformat_dd <= cij_end_date &
          keydate2_dateformat_dd >= cij_end_date_upper &
          !amended_dates ~ "2D",

        # "2DP"	"Starts in CIJ (allowing +-1 day and ends one day after) - (2DP)"
        keydate1_dateformat_dd >= cij_start_date_lower &
          keydate1_dateformat_dd <= cij_end_date_upper &
          keydate2_dateformat_dd >= cij_end_date_upper &
          !amended_dates ~ "2DP",

        # "2A"	"Starts in CIJ (Accurate Match after correcting assumed end date) - (2A)"
        keydate1_dateformat_dd >= cij_start_date &
          keydate1_dateformat_dd <= cij_end_date &
          keydate2_dateformat_dd >= cij_end_date &
          amended_dates ~ "2A",

        # "2AP"	"Starts in CIJ (Accurate Match (allowing +-1 day) after correcting assumed end date) - (2AP)"
        keydate1_dateformat_dd >= cij_start_date_lower &
          keydate1_dateformat_dd <= cij_end_date_upper &
          keydate2_dateformat_dd >= cij_end_date_upper &
          amended_dates ~ "2AP",

        # "3"	"Ends in CIJ - (3)"
        keydate1_dateformat_dd <= cij_start_date &
          keydate2_dateformat_dd >= cij_start_date &
          keydate2_dateformat_dd >= cij_end_date &
          !amended_dates ~ "3",

        # "3D"	"Ends in CIJ (starts one day before) - (3D)"
        keydate1_dateformat_dd <= cij_start_date_lower &
          keydate2_dateformat_dd >= cij_start_date &
          keydate2_dateformat_dd >= cij_end_date &
          !amended_dates ~ "3D",

        # "3DP"	"Ends in CIJ (allowing +-1 day and starts one day before) - (3DP)"
        keydate1_dateformat_dd <= cij_start_date_lower &
          keydate2_dateformat_dd >= cij_start_date_lower &
          keydate2_dateformat_dd >= cij_end_date_upper &
          !amended_dates ~ "3DP",

        # "4"	"Matches unended MH record - (4)"
        recid == "04B" &
          keydate1_dateformat_dd >= cij_start_date &
          amended_dates ~ "4",

        # "4P"	"Matches unended MH record (allowing -1 day) - (4P)"
        recid == "04B" &
          keydate1_dateformat_dd >= cij_start_date_lower &
          amended_dates ~ "4P",

        # "-" "No Match (We don't keep these)"
        .default = "-"
      )
    )) %>%
    dplyr::filter(dd_type != "-") %>%
    dplyr::mutate(smrtype_dd = dplyr::case_when(
      dd_type %in% c(
        "1",
        "1P",
        "1A",
        "1AP",
        "2",
        "2D",
        "2DP",
        "2A",
        "2AP",
        "3",
        "3D",
        "3DP",
        "4",
        "4P"
      ) ~ "DD-CIJ",
      dd_type %in% c("no-cij") ~ "DD-No CIJ"
    )) %>%
    # tidy up and rename columns to match the format of episode files
    dplyr::select(
      chi,
      recid = recid_dd,
      keydate1_dateformat = keydate1_dateformat_dd,
      keydate2_dateformat = keydate2_dateformat_dd,
      smrtype = smrtype_dd,
      cij_marker,
      cij_start_date,
      cij_end_date,
      postcode = postcode_dd
    ) %>%
    # combind DD with episode data
    dplyr::bind_rows(data %>% dplyr::select(-c(
      "cij_start_date_lower", "cij_end_date_upper"
    )))

  return(data)
}
