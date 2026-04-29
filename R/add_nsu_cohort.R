#' Add NSU cohort to working file
#'
#' @param data The input data frame
#' @param year The year being processed
#' @param BYOC_MODE Whether run in a docker on Denodo
#'
#' @return A data frame containing the Non-Service Users as additional rows
#' @export
#'
#' @family episode_file
#' @seealso [get_nsu_path()]
add_nsu_cohort <- function(
  data,
  year,
  BYOC_MODE
) {
  year_param <- year

  if (!check_year_valid(year, "nsu")) {
    return(data)
  }

  nsu_cohort <- get_nsu_data(year = year, BYOC_MODE = BYOC_MODE)

  # Check that the variables we need are in the data
  check_variables_exist(data,
    variables = c(
      "year",
      "anon_chi",
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
    # Match on by anon_chi
    by = "anon_chi",
    # Name the incoming variables with "_nsu"
    suffix = c("", "_nsu"),
    # Keep the anon_chi from both sources
    keep = TRUE
  ) %>%
    # Change the anon_chi from the NSU cohort to a boolean
    dplyr::mutate(has_chi = !is_missing(.data[["anon_chi_nsu"]]))

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
      anon_chi = dplyr::if_else(
        is_missing(.data[["anon_chi"]]) & .data[["has_chi"]],
        .data[["anon_chi_nsu"]],
        .data[["anon_chi"]]
      )
    ) %>%
    dplyr::select(-dplyr::contains("_nsu"), -"has_chi")

  cli::cli_alert_info("Add NSU cohort function finished at {Sys.time()}")

  return(return_df)
}


#' get nsu data from Denodo or sourcedev/nsu
#'
#' @param year financial year
#' @param BYOC_MODE
#'
#' @returns
#' @export
#'
#' @examples
get_nsu_data <- function(year, BYOC_MODE) {
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  if (isTRUE(BYOC_MODE)) {
    denodo_connect <- get_denodo_connection(BYOC_MODE = BYOC_MODE)

    on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE),
      add = TRUE
    )

    nsu_data <- dplyr::tbl(
      denodo_connect,
      dbplyr::in_schema("sdl", "sdl_nsu_source") # TODO: finalise this sdl view
    ) %>%
      dplyr::filter(costs_financial_year == c_year) %>%
      dplyr::select(
        "year",
        "anon_chi",
        "recid",
        "smrtype",
        "postcode",
        "gpprac",
        "dob",
        "gender"
      ) %>%
      dplyr::collect()
  } else {
    nsu_data <- read_file(get_nsu_path(year))
  }

  return(nsu_data)
}
