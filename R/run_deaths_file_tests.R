#' All deaths file tests
#'
#' @param data new or old data for testing summary flags
#'
#' @return a dataframe with a count of each flag
#' @export
deaths_file_tests <- function(data){

  data %>%
    #create test flags
    dplyr::mutate(n_chi = 1,
                  n_death_date_nrs = if_else(is.na(death_date_NRS), 0, 1),
                  n_death_date_chi = if_else(is.na(death_date_CHI), 0, 1),
                  n_death_date = if_else(is.na(death_date), 0, 1)
                  ) %>%
    #remove variables that won't be summed
    dplyr::select(-c(chi:death_date)) %>%
    #use function to sum new test flags
    sum_flags()
}
