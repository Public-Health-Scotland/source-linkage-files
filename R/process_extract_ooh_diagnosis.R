#' Process th GP OOH Diagnosis extract
#'
#' @description This will read and process the
#' GP OOH Diagnosis extract, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
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
      readcode = stringr::str_replace_all(readcode, "\\?", "\\.") %>%
        # Pad with dots up to 5 charaters
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
      description = dplyr::if_else(is.na(full_match_1) & !is.na(true_description),
        true_description, description
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
      readcode = dplyr::if_else(is.na(full_match_2),
        dplyr::case_when(
          readcode == "Xa1m." ~ "S349",
          readcode == "Xa1mz" ~ "S349",
          readcode == "HO6.." ~ "H06..",
          readcode == "zV6.." ~ "ZV6..",
          TRUE ~ readcode
        ), readcode
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
    dplyr::count(full_match_1, full_match_2, full_match_final)

  # Check any readcodes which are still not matching the lookup
  readcodes_not_matched <- diagnosis_readcodes %>%
    dplyr::filter(is.na(full_match_final)) %>%
    dplyr::count(readcode, description, sort = TRUE)

  readcodes_not_matched

  # Give an error if any new 'bad' readcodes come up.
  unrecognised_but_ok_codes <- c("@1JX.", "@1JXz", "@43jS", "@65PW", "@8CA.", "@8CAK", "@A795")

  new_bad_codes <- readcodes_not_matched %>%
    dplyr::filter(!(readcode %in% unrecognised_but_ok_codes))

  if (nrow(new_bad_codes) != 0L) {
    cli::cli_abort(c("New unrecognised readcodes",
      "i" = "There {?is/are} {nrow(new_bad_codes)} new unrecognised readcode{?s} in the data.",
      " " = "Check the {cli::qty(nrow(new_bad_codes))} code{?s} then either fix, or add {?it/them} to the {.var unrecognised_but_ok_codes} vector",
      "",
      ">" = "New bad {cli::qty(nrow(new_bad_codes))} code{?s}: {new_bad_codes$readcode}"
    ))
  }

  rm(
    readcode_lookup,
    readcodes_not_matched,
    unrecognised_but_ok_codes,
    new_bad_codes
  )

  ## Data Cleaning------------------------------------------------------------

  diagnosis_clean <- diagnosis_readcodes %>%
    dplyr::select("ooh_case_id", "readcode", "description") %>%
    dplyr::mutate(
      readcode_level = stringr::str_locate(readcode, "\\.")[, "start"] %>%
        tidyr::replace_na(6L)
    ) %>%
    dplyr::group_by(ooh_case_id) %>%
    # Sort so that the 'more specific' readcodes are preferred
    dplyr::arrange(dplyr::desc(readcode_level)) %>%
    dplyr::mutate(diag_n = dplyr::row_number()) %>%
    dplyr::ungroup() %>%
    dplyr::select(-"readcode_level") %>%
    dplyr::rename(diag = "readcode") %>%
    # restructure data
    tidyr::pivot_wider(
      names_from = diag_n,
      values_from = c(diag, description),
      names_glue = "{.value}_{diag_n}"
    ) %>%
    dplyr::select(
      "ooh_case_id",
      # Use any of in case we have fewer than 6 diagnoses
      tidyselect::any_of(c(
        "diag_1",
        "diag_2",
        "diag_3",
        "diag_4",
        "diag_5",
        "diag_6"
      ))
    )

  rm(diagnosis_extract, diagnosis_readcodes)

  return(diagnosis_clean)
}
