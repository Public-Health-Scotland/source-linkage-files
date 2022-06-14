#' Clean Up Text Variables
#'
#' @param data data containing string variables needing cleaned up
#' @param string string variable
#'
#' @return data with cleaned up string variables
#' @export
clean_up_free_text <- function(data, string, remove_punct = TRUE) {
  if (remove_punct == TRUE) {
  data <- data %>%
      dplyr::mutate(
        # deal with capitalisation of CH names
        {{ string }} := stringr::str_to_title({{ string }}),
        # deal with whitespace at start and end and witihin
        {{ string }} := stringr::str_trim({{ string }}, side = "both"),
        {{ string }} := stringr::str_squish({{ string }}),
        # deal with punctuation in the CH names
        {{ string }} := stringr::str_replace_all({{ string }}, "[[:punct:]]", " ")
        )
  } else {
    data <- data %>%
      dplyr::mutate(
        # deal with capitalisation of CH names
        {{ string }} := stringr::str_to_title({{ string }}),
        # deal with whitespace at start and end and witihin
        {{ string }} := stringr::str_trim({{ string }}, side = "both"),
        {{ string }} := stringr::str_squish({{ string }})
      )
  }

}
