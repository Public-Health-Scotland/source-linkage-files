#' Clean up a free text string
#'
#' @description Take a messy string and clean it up by converting it to title
#' case, removing any superfluous whitespace and optionally removing
#' any punctuation. The use case is to make text style uniform to aid with
#' matching.
#'
#' @param string string variable
#' @param case_to the case to convert the string to
#' @param remove_punct Should any punctuation be removed?
#' (default `TRUE`)
#'
#' @return The cleaned string
#' @export
#' @examples
#' clean_up_free_text("hiwSDS SD. h")
clean_up_free_text <- function(string, case_to = c("upper", "lower", "sentence", "title", "none"),
                               remove_punct = TRUE) {
  if (missing(case_to)) case_to <- "title"

  case_to <- match.arg(case_to)

  cleaned_string <-
    # Deal with whitespace at start and end and within
    stringr::str_squish(stringr::str_trim(string, side = "both"))

  # Remove any punctuation (optionally)
  if (remove_punct) {
    # deal with punctuation in the CH names
    cleaned_string <- stringr::str_replace_all(cleaned_string, "[[:punct:]]", " ")
  }

  # Make the case uniform
  cleaned_string <- dplyr::case_when(
    case_to == "lower" ~ stringr::str_to_lower(cleaned_string),
    case_to == "upper" ~ stringr::str_to_upper(cleaned_string),
    case_to == "sentence" ~ stringr::str_to_sentence(cleaned_string),
    case_to == "title" ~ stringr::str_to_title(cleaned_string),
    case_to == "none" ~ cleaned_string
  )

  return(cleaned_string)
}
