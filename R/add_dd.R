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
    # add row number to restore the order later
    dplyr::mutate(row_no = dplyr::row_number())

  # Capture the Mental Health delays with no end dates.
  data_chi_1 <- data_chi %>%
    dplyr::select(
      chi,
      recid,
      keydate1_dateformat,
      keydate2_dateformat,
      CIJ_start_date,
      CIJ_end_date,
      temp_cij_marker,
      row_no
    ) %>%
    dplyr::filter(
      chi == lag(chi) & recid == "DD" &
        lag(recid) == "04B" &
        is.na(keydate2_dateformat) &
        is.na(lag(keydate2_dateformat)) &
        keydate1_dateformat >= lag(CIJ_start_date) - lubridate::days(1)
    ) %>%
    dplyr::mutate(
      Flag_8 = dplyr::if_else(keydate1_dateformat >= lag(CIJ_start_date), 2, 1),
      temp_cij_marker = lag(temp_cij_marker),
      CIJ_start_date = lag(CIJ_start_date),
      CIJ_end_date = lag(CIJ_end_date)
    )

  data_chi <- data_chi %>%
    dplyr::left_join(data_chi_1, suffix = c("", "_redundancy")) %>%
    dplyr::select(-ends_with("_redundancy"))
  # As I imagine, this will possibly leave some NA in columns including
  # CIJ_start_date, CIJ_end_date

  # Use Min and Max CIJ dates to fill in temp_cij_marker -
  # where possible - DD episodes with no CIJ.
  ## difficult parts. hard to vectorize it.
  # data_chi_1 <- data_chi %>%
  #   dplyr::if_else(
  #     chi == lag(chi) & is.na(temp_cij_marker),
  #     Flag_1 = 0,
  #
  #   )

  # ## non-vectorized version. for loop
  # for(ii in 2:max(data_chi$row_no)){
  #   if(chi[ii] == chi[ii - 1] & is.na(temp_cij_marker[ii])){
  #
  #   }
  # }






  # Eventually, bind non_chi back
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
