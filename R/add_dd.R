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

  data_chi <- data %>%
    # Keep records that have a chi, and a cij_marker.
    dplyr::filter(is.na(chi)) %>%
    dplyr::filter(recid %in% c("01B", "02B", "04B", "GLS")) %>%
    # create a copy of the CIJ maker
    dplyr::mutate(
      temp_cij_maker = cij_maker
    ) %>%
    dplyr::full_join(
      # Not sure which function to use here. Will change it later
      haven::read_sav("/conf/hscdiip/SLF_Extracts/Delayed_Discharges/Jul16_Sep22DD_LinkageFile.zsav"),
      by = "chi"
    ) %>%
    # Create an order variable to make DD records appear after others.
    # but might it be better if recid has levels?
    dplyr::mutate(
      order = dplyr::case_when(
        recid %in% c("00B", "01B", "02B", "04B", "GLS") ~ 1L,
        recid == "DD" ~ 2L,
        TRUE ~ NA
      )
    ) %>%
    # Remove any DD records which don't match a chi in the file.
    dplyr::arrange(chi) %>%
    dplyr::filter(!(recid == "DD" & chi != dplyr::lag(chi))) %>%
    # sort so that DD is roughly where we expect it to fit
    dplyr::arrange(chi, keydate1_dateformat) %>%

    # Capture the Mental Health delays with no end dates.
    dplyr::mutate(
      Flag_8 = dplyr::if_else((
        chi = dplyr::lag(chi) & recid == "DD" & lag(recid) == "04B" &
          is.na(keydate2_dateformat) &
          is.na(lag(keydate2_dateformat)) &
          keydate1_dateformat > (lag(CIJ_start_date) - lubridate::days(1))),
      dplyr::if_else(keydate1_dateformat > (lag(CIJ_start_date)), 2, 1),
      NA
    ),
    temp_cij_maker = dplyr::if_else((
      chi = dplyr::lag(chi) & recid == "DD" & lag(recid) == "04B" &
        is.na(keydate2_dateformat) &
        is.na(lag(keydate2_dateformat)) &
        keydate1_dateformat > (lag(CIJ_start_date) - lubridate::days(1))),
      dplyr::lag(temp_cij_maker),
      NA
    ),
    CIJ_start_date = dplyr::if_else((
      chi = dplyr::lag(chi) & recid == "DD" & lag(recid) == "04B" &
        is.na(keydate2_dateformat) &
        is.na(lag(keydate2_dateformat)) &
        keydate1_dateformat > (lag(CIJ_start_date) - lubridate::days(1))),
      dplyr::lag(CIJ_start_date),
      NA
    ),
    CIJ_end_date = dplyr::if_else((
      chi = dplyr::lag(chi) & recid == "DD" & lag(recid) == "04B" &
        is.na(keydate2_dateformat) &
        is.na(lag(keydate2_dateformat)) &
        keydate1_dateformat > (lag(CIJ_start_date) - lubridate::days(1))),
      dplyr::lag(CIJ_end_date),
      NA
    )) %>%

    # Use Min and Max CIJ dates to fill in temp_cij_marker -
    # where possible - DD episodes with no CIJ.





    data_return <- row_bind(
      data_chi,
      data %>%
        dplyr::filter(is.na(chi)) %>%
        dplyr::filter(!(recid %in% c("01B", "02B", "04B", "GLS"))),
      data %>%
        dplyr::filter(!is.na(chi))
    )

  return()
}
