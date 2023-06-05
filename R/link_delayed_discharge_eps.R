#' Link  Delayed Discharge to WIP episode file
#'
#' @param data The input data frame
#' @param year The year being processed
#'
#' @return A data frame with the delayed discharge cohort added and linked
#' using the `cij_marker`
#'
#' @export
#'
#' @family episode file
link_delayed_discharge_eps <- function(data, year) {
  year_param <- year

  data <- data %>%
    dplyr::mutate(
      # remember to revoke the cij_end_date with dummy_cij_end
      cij_start_date_lower = .data$cij_start_date - lubridate::days(1L),
      cij_end_date_upper = .data$cij_end_date + lubridate::days(1L),
      cij_end_month = last_date_month(.data$cij_end_date),
      is_dummy_cij_start = is.na(.data$cij_start_date) & !is.na(.data$cij_end_date),
      dummy_cij_start = dplyr::if_else(
        .data$is_dummy_cij_start,
        lubridate::as_date("1900-01-01"),
        .data$cij_start_date_lower
      ),
      is_dummy_cij_end = !is.na(.data$cij_start_date) & is.na(.data$cij_end_date),
      dummy_cij_end = dplyr::if_else(
        .data$is_dummy_cij_end,
        lubridate::today(),
        .data$cij_end_month
      )
    )

  ## handling DD ----
  # no flag for last reported
  dd_data <-
    read_file(get_source_extract_path(year_param, "DD")) %>%
    dplyr::rename(
      # TODO Change the name of the variables in the DD extract rather than here.
      record_keydate1 = "keydate1_dateformat",
      record_keydate2 = "keydate2_dateformat"
    ) %>%
    dplyr::mutate(
      # remember to revoke the keydate2 and amended_dates with dummy_keydate2
      is_dummy_keydate2 = is.na(.data$record_keydate2),
      dummy_keydate2 = dplyr::if_else(.data$is_dummy_keydate2,
        lubridate::today(),
        .data$record_keydate2
      ),
      dummy_id = dplyr::row_number()
    )

  by_dd <- dplyr::join_by(
    chi,
    x$record_keydate1 >= y$dummy_cij_start,
    x$dummy_keydate2 <= y$dummy_cij_end
  )
  data <- dd_data %>%
    dplyr::inner_join(data,
      by = by_dd,
      suffix = c("_dd", "")
    ) %>%
    dplyr::arrange(
      .data$cij_start_date,
      .data$cij_end_date,
      .data$cij_marker,
      .data$postcode
    ) %>%
    # remove duplicate rows, but still got some duplicate mismatches
    dplyr::distinct(
      .data$chi,
      .data$cij_start_date,
      .data$cij_end_date,
      .data$cij_marker,
      .data$record_keydate1_dd,
      .data$record_keydate2_dd,
      .keep_all = TRUE
    ) %>%
    # determine DD quality
    dplyr::mutate(
      dd_type = dplyr::if_else(
        is.na(.data$cij_marker),
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

          # If we use record_keydate2_dd,
          # we implicitly mean is_dummy_keydate2 needs to be FALSE.
          # Given that in DD files,
          # we only keep the records with missing keydate2 for 04B, mental health,
          # and drop the records with missing keydate2 for other recid,
          # it should be ok to only use dummy_keydate2 for "4"(s).

          # "1"	"Accurate Match - (1)"
          record_keydate1_dd >= cij_start_date &
            record_keydate2_dd <= cij_end_date &
            !amended_dates ~ "1",

          # "1P"	"Accurate Match (allowing +-1 day) - (1P)"
          record_keydate1_dd >= cij_start_date_lower &
            record_keydate2_dd <= cij_end_date_upper &
            !amended_dates ~ "1P",

          # "1A"	"Accurate Match (has an assumed end date) - (1A)"
          record_keydate1_dd >= cij_start_date &
            record_keydate2_dd <= cij_end_date &
            amended_dates ~ "1A",

          # "1AP"	"Accurate Match (allowing +-1 day and has an assumed end date) - (1AP)"
          record_keydate1_dd >= cij_start_date_lower &
            record_keydate2_dd <= cij_end_date_upper &
            amended_dates ~ "1AP",

          # "1APE"	the CIJ ends during the month but the delay has an end date of the end of the month
          record_keydate1_dd >= cij_start_date_lower &
            record_keydate2_dd == cij_end_month &
            amended_dates ~ "1APE",

          # "2"	"Starts in CIJ - (2)"
          record_keydate1_dd >= cij_start_date &
            record_keydate1_dd <= cij_end_date &
            record_keydate2_dd > cij_end_date &
            !amended_dates ~ "2",

          # "2D"	"Starts in CIJ (ends one day after) - (2D)"
          record_keydate1_dd >= cij_start_date &
            record_keydate1_dd <= cij_end_date &
            record_keydate2_dd > cij_end_date_upper &
            !amended_dates ~ "2D",

          # "2DP"	"Starts in CIJ (allowing +-1 day and ends one day after) - (2DP)"
          record_keydate1_dd >= cij_start_date_lower &
            record_keydate1_dd <= cij_end_date_upper &
            record_keydate2_dd > cij_end_date_upper &
            !amended_dates ~ "2DP",

          # "2A"	"Starts in CIJ (Accurate Match after correcting assumed end date) - (2A)"
          record_keydate1_dd >= cij_start_date &
            record_keydate1_dd <= cij_end_date &
            record_keydate2_dd > cij_end_date &
            amended_dates ~ "2A",

          # "2AP"	"Starts in CIJ (Accurate Match (allowing +-1 day) after correcting assumed end date) - (2AP)"
          record_keydate1_dd >= cij_start_date_lower &
            record_keydate1_dd <= cij_end_date_upper &
            record_keydate2_dd > cij_end_date_upper &
            # record_keydate2_dd == cij_end_month &
            amended_dates ~ "2AP",

          # "3"	"Ends in CIJ - (3)"
          record_keydate1_dd <= cij_start_date &
            record_keydate2_dd >= cij_start_date &
            record_keydate2_dd <= cij_end_date &
            !amended_dates ~ "3",

          # "3D"	"Ends in CIJ (starts one day before) - (3D)"
          record_keydate1_dd <= cij_start_date_lower &
            record_keydate2_dd >= cij_start_date &
            record_keydate2_dd <= cij_end_date &
            !amended_dates ~ "3D",

          # "3DP"	"Ends in CIJ (allowing +-1 day and starts one day before) - (3DP)"
          record_keydate1_dd <= cij_start_date_lower &
            record_keydate2_dd >= cij_start_date_lower &
            record_keydate2_dd <= cij_end_date_upper &
            !amended_dates ~ "3DP",

          # "3ADPE"
          record_keydate1_dd <= cij_start_date_lower &
            record_keydate2_dd >= cij_start_date_lower &
            record_keydate2_dd <= cij_end_month &
            amended_dates ~ "3ADPE",

          # "4"	"Matches unended MH record - (4)"
          recid == "04B" &
            record_keydate1_dd >= cij_start_date &
            is_dummy_cij_end ~ "4",

          # "4P"	"Matches unended MH record (allowing -1 day) - (4P)"
          recid == "04B" &
            record_keydate1_dd >= cij_start_date_lower &
            is_dummy_cij_end ~ "4P",

          # "-" "No Match (We don't keep these)"
          .default = "-"
        )
      ),
      dd_type = factor(
        .data$dd_type,
        levels = c(
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
          "1APE",
          "3ADPE",
          "4",
          "4P",
          "-"
        )
      ),

      # For "1APE", assign 1APE cij_end_date to record_keydate2_dd
      record_keydate2_dd = dplyr::if_else(
        .data$dd_type == "1APE" | .data$dd_type == "3ADPE",
        .data$cij_end_date,
        .data$record_keydate2_dd
      ),
      datediff_end = abs(.data$cij_end_date - .data$record_keydate2_dd),
      datediff_start = .data$cij_start_date - .data$record_keydate1_dd
    ) %>%
    dplyr::filter(.data$dd_type != "-") %>%
    dplyr::mutate(smrtype = dplyr::case_match(
      as.character(.data$dd_type),
      c(
        "1",
        "1P",
        "1A",
        "1AP",
        "1APE",
        "2",
        "2D",
        "2DP",
        "2A",
        "2AP",
        "3",
        "3D",
        "3DP",
        "3ADPE",
        "4",
        "4P"
      ) ~ "DD-CIJ",
      "no-cij" ~ "DD-No CIJ"
    )) %>%
    # remove duplicated rows when many to many inner join
    # keep the records that closest to the cij record
    dplyr::arrange(
      .data$chi,
      .data$original_admission_date,
      .data$record_keydate1_dd,
      .data$record_keydate2_dd,
      .data$dummy_id,
      .data$dd_type,
      .data$datediff_end,
      dplyr::desc(.data$datediff_start)
    ) %>%
    dplyr::distinct(
      .data$postcode,
      .data$record_keydate1_dd,
      .data$record_keydate2_dd,
      .keep_all = TRUE
    ) %>%
    # tidy up and rename columns to match the format of episode files
    dplyr::select(
      "year" = "year_dd",
      "recid" = "recid_dd",
      "record_keydate1" = "record_keydate1_dd",
      "record_keydate2" = "record_keydate2_dd",
      "smrtype",
      "chi",
      "gender",
      "dob",
      "age",
      "gpprac",
      "postcode" = "postcode_dd",
      "lca" = "dd_responsible_lca",
      "hbtreatcode" = "hbtreatcode_dd",
      "original_admission_date",
      "amended_dates",
      "delay_end_reason",
      "primary_delay_reason",
      "secondary_delay_reason",
      "cij_marker",
      "cij_start_date",
      "cij_end_date",
      "cij_pattype_code",
      "cij_ipdc",
      "cij_admtype",
      "cij_adm_spec",
      "cij_dis_spec",
      "location",
      "spec" = "spec_dd",
      "dd_type"
    ) %>%
    # combine DD with episode data
    dplyr::bind_rows( # restore cij_end_date
      data %>%
        dplyr::select(
          -c(
            "cij_start_date_lower",
            "cij_end_date_upper",
            "cij_end_month",
            "is_dummy_cij_start",
            "dummy_cij_start",
            "is_dummy_cij_end",
            "dummy_cij_end"
          )
        )
    )

  return(data)
}
