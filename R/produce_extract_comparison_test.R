#' Extract Comparison Test and Plots
#'
#'  Runs matching and plots for comparing `slf_new` and `slf_existing`
#'
#' @param slf_new new slf data frame
#' @param slf_existing existing slf data frame
#'
#' @return data frame of comparison of the two files
#' @return plots of `difference` and `pct_change`
#' @export
#' @family produce tests functions
#'
#' @examples
#' extract_comparison_test(slf_new = slf_new, slf_existing = slf_existing)
extract_comparison_test <- function(slf_new, slf_existing) {

  ## match ##

  comparison <-
    slf_new %>%
    full_join(slf_existing, by = c("measure")) %>%
    # rename
    rename(
      new_value = "value.x",
      existing_value = "value.y"
    ) %>%
    mutate(
      new_value = as.numeric(new_value),
      existing_value = as.numeric(existing_value)
    )


  ## comparison ##

  comparison <-
    comparison %>%
    mutate(difference = new_value - existing_value) %>%
    mutate(pct_change = if_else(existing_value != 0, difference / existing_value * 100, 0)) %>%
    mutate(issue = abs(pct_change) > 5)
}
