#' Create the Prescribing Extract Flags
#'
#' @param data new or old data for testing summary flags
#'
#' @return a dataframe with additional variables containing flags
#' @export
#' @importFrom dplyr mutate select
#' @family produce tests functions
create_pis_extract_flags <- function(data) {
  data %>%
    # demog flags
    create_demog_test_flags(postcode = FALSE)
}
