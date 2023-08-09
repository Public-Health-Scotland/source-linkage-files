#' process_tests_individual_file
#'
#' @description check whether individual files have duplicated rows for the same chi
#'
#' @return NULL if no duplicated chi, OR rows with duplicated chi.
process_tests_individual_file <- function(individual_file, anon_chi_in = FALSE) {
  chi_col <- dplyr::if_else(anon_chi_in, "anon_chi", "chi")
  duplicated_chi <- duplicated(individual_file[[chi_col]])
  dup_num <- sum(duplicated_chi)
  if (dup_num < 1L) {
    print("There is no duplicated CHI")
    return(NULL)
  } else {
    print("There are duplicated CHIs")
    return(individual_file %>%
      dplyr::filter(!!sym(chi_col)) %in% duplicated_chi)
  }
}
