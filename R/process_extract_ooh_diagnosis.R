#' Process the GP OOH Diagnosis extract
#'
#' @description This will read and process the
#' GP OOH Diagnosis extract, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
process_extract_ooh_diagnosis <- function(data, year) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)


  # Diagnosis Data ---------------------------------

  # Read code lookup
  readcode_lookup <- readr::read_rds(get_readcode_lookup_path()) %>%
    dplyr::rename(
      readcode = "ReadCode",
      description = "Description"
    )

  ## Deal with Read Codes

  diagnosis_readcodes <- data %>%
    dplyr::mutate(
      # Replace question marks with dot
      readcode = stringr::str_replace_all(.data$readcode, "\\?", "\\.") %>%
        # Pad with dots up to 5 characters
        stringr::str_pad(5L, "right", ".")
    ) %>%
    # Join diagnosis to readcode lookup
    # Identify diagnosis descriptions which match the readcode lookup
    dplyr::left_join(
      readcode_lookup %>%
        dplyr::mutate(full_match_1 = 1L),
      by = c("readcode", "description")
    ) %>%
    # match on true description from readcode lookup
    dplyr::left_join(
      readcode_lookup %>%
        dplyr::rename(true_description = "description"),
      by = "readcode"
    ) %>%
    # Replace  the description with the true description from the Readcode Lookup.
    dplyr::mutate(
      description = dplyr::if_else(
        is.na(.data$full_match_1) & !is.na(.data$true_description),
        .data$true_description,
        .data$description
      )
    ) %>%
    # Join to readcode lookup again to check
    dplyr::left_join(
      readcode_lookup %>%
        dplyr::mutate(full_match_2 = 1L),
      by = c("readcode", "description")
    ) %>%
    # Check the output for any bad Read codes and try and fix by adding exceptions
    dplyr::mutate(
      readcode = dplyr::if_else(is.na(.data$full_match_2),
        dplyr::case_when(
          .data$readcode == "Xa1m." ~ "S349",
          .data$readcode == "Xa1mz" ~ "S349",
          .data$readcode == "HO6.." ~ "H06..",
          .data$readcode == "zV6.." ~ "ZV6..",
          TRUE ~ .data$readcode
        ), .data$readcode
      )
    ) %>%
    # Join to readcode lookup again to check
    dplyr::left_join(
      readcode_lookup %>%
        dplyr::mutate(full_match_final = 1L),
      by = c("readcode", "description")
    )

  # See how the code above performed
  diagnosis_readcodes %>%
    dplyr::count(
      .data$full_match_1,
      .data$full_match_2,
      .data$full_match_final
    )

  # Check any readcodes which are still not matching the lookup
  readcodes_not_matched <- diagnosis_readcodes %>%
    dplyr::filter(is.na(.data$full_match_final)) %>%
    dplyr::count(.data$readcode, .data$description, sort = TRUE)

  readcodes_not_matched

  # Give an error if any new 'bad' readcodes come up.
  unrecognised_but_ok_codes <- c(
    "@1JX.",
    "@1JXz",
    "@43jS",
    "@65PW",
    "@8CA.",
    "@8CAK",
    "@A795"
  )

  new_bad_codes <- readcodes_not_matched %>%
    dplyr::filter(!(.data$readcode %in% unrecognised_but_ok_codes))

  if (nrow(new_bad_codes) != 0L) {
    cli::cli_abort(
      c("New unrecognised readcodes",
        "i" = "There {?is/are} {nrow(new_bad_codes)} new unrecognised readcode{?s} in the data.",
        " " = "Check the {cli::qty(nrow(new_bad_codes))} code{?s} then either fix, or add {?it/them} to the {.var unrecognised_but_ok_codes} vector",
        "",
        ">" = "New bad {cli::qty(nrow(new_bad_codes))} code{?s}: {new_bad_codes$readcode}"
      )
    )
  }


  ## Data Cleaning------------------------------------------------------------

  diagnosis_clean <- diagnosis_readcodes %>%
    dplyr::select("ooh_case_id", "readcode", "description") %>%
    dplyr::mutate(
      readcode_level = stringr::str_locate(.data$readcode, "\\.")[, "start"] %>%
        tidyr::replace_na(6L)
    ) %>%
    dplyr::group_by(.data$ooh_case_id) %>%
    # Sort so that the 'more specific' readcodes are preferred
    dplyr::arrange(dplyr::desc(.data$readcode_level)) %>%
    dplyr::mutate(diag_n = dplyr::row_number()) %>%
    dplyr::ungroup() %>%
    dplyr::select(-"readcode_level") %>%
    dplyr::rename(diag = "readcode") %>%
    # restructure data
    tidyr::pivot_wider(
      names_from = .data$diag_n,
      values_from = c(.data$diag, .data$description),
      names_glue = "{.value}{diag_n}"
    ) %>%
    dplyr::select(
      "ooh_case_id",
      # Use any of in case we have fewer than 6 diagnoses
      tidyselect::any_of(c(
        "diag1",
        "diag2",
        "diag3",
        "diag4",
        "diag5",
        "diag6"
      ))
    )

  return(diagnosis_clean)
}
