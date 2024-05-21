#' Add NSU cohort to working file
#'
#' @param data The input data frame
#' @param year The year being processed
#' @param nsu_cohort The NSU data for the year
#'
#' @return A data frame containing the Non-Service Users as additional rows
#' @export
#'
#' @family episode_file
#' @seealso [get_nsu_path()]
add_nsu_cohort <- function(
    data,
    year,
    nsu_cohort = read_file(get_nsu_path(year)) %>% slfhelper::get_chi()) {
  year_param <- year

  if (!check_year_valid(year, "nsu")) {
    return(data)
  }

  # Check that the variables we need are in the data
  check_variables_exist(data,
    variables = c(
      "year",
      "chi",
      "recid",
      "smrtype",
      "postcode",
      "gpprac",
      "dob",
      "gender"
    )
  )

  matched <- dplyr::full_join(
    data,
    nsu_cohort %>%
      dplyr::mutate(
        dob = as.Date(.data[["dob"]]),
        gpprac = convert_eng_gpprac_to_dummy(.data[["gpprac"]])
      ),
    # Match on by chi
    by = "chi",
    # Name the incoming variables with "_nsu"
    suffix = c("", "_nsu"),
    # Keep the chi from both sources
    keep = TRUE
  ) %>%
    # Change the chi from the NSU cohort to a boolean
    dplyr::mutate(has_chi = !is_missing(.data[["chi_nsu"]]))

  return_df <- matched %>%
    # Get data from non service user lookup if the recid is empty
    dplyr::mutate(
      year = year_param,
      recid = dplyr::if_else(
        is_missing(.data[["recid"]]),
        "NSU",
        .data[["recid"]]
      ),
      smrtype = dplyr::if_else(
        is_missing(.data[["recid"]]),
        "Non-User",
        .data[["smrtype"]]
      ),
      postcode = dplyr::if_else(
        is_missing(.data[["recid"]]),
        .data[["postcode_nsu"]],
        .data[["postcode"]]
      ),
      gpprac = dplyr::if_else(
        is_missing(.data[["recid"]]),
        .data[["gpprac_nsu"]],
        .data[["gpprac"]]
      ),
      dob = dplyr::if_else(
        is_missing(.data[["recid"]]),
        .data[["dob_nsu"]],
        .data[["dob"]]
      ),
      gender = dplyr::if_else(
        is_missing(.data[["recid"]]),
        .data[["gender_nsu"]],
        .data[["gender"]]
      )
    ) %>%
    # If the data has come from the NSU cohort,
    # use that data for the below variables
    dplyr::mutate(
      postcode = dplyr::if_else(
        is_missing(.data[["postcode"]]) & .data[["has_chi"]],
        .data[["postcode_nsu"]],
        .data[["postcode"]]
      ),
      gpprac = dplyr::if_else(
        is.na(.data[["gpprac"]]) & .data[["has_chi"]],
        .data[["gpprac_nsu"]],
        .data[["gpprac"]]
      ),
      dob = dplyr::if_else(
        is.na(.data[["dob"]]) & .data[["has_chi"]],
        .data[["dob_nsu"]],
        .data[["dob"]]
      ),
      gender = dplyr::if_else(
        is.na(.data[["gender"]]) & .data[["has_chi"]],
        .data[["gender_nsu"]],
        .data[["gender"]]
      ),
      chi = dplyr::if_else(
        is_missing(.data[["chi"]]) & .data[["has_chi"]],
        .data[["chi_nsu"]],
        .data[["chi"]]
      )
    ) %>%
    dplyr::select(-dplyr::contains("_nsu"), -"has_chi")

  return(return_df)
}
