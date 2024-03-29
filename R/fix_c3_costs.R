#' Fix C3 Costs - Acute Extract
#'
#' @description Apply costs fix to specialty C3 in acute processing.
#'
#' @param data Acute extract file after processing
#' @param year Financial year e.g. 1819
#'
#' @return A data frame with costs applied
fix_c3_costs <- function(data, year) {
  year <- check_year_format(year)

  if (year >= "1819") {
    # Amend cost total net
    data <- data %>%
      # Calculate costs for NHS Ayrshire & Arran
      dplyr::mutate(cost_total_net = dplyr::case_when(
        recid == "01B" & spec == "C3" & hbtreatcode == "S08000015" &
          location == "A111H" & ipdc == "D" ~ 521.38,
        recid == "01B" & spec == "C3" & hbtreatcode == "S08000015" &
          location == "A111H" & ipdc == "I" ~ 2309.63 * yearstay,
        recid == "01B" & spec == "C3" & hbtreatcode == "S08000015" &
          location == "A210H" & ipdc == "D" ~ 521.38,
        recid == "01B" & spec == "C3" & hbtreatcode == "S08000015" &
          location == "A210H" & ipdc == "I" ~ 2460.63 * yearstay,
        # Calculate costs for NHS Forth Valley
        recid == "01B" & spec == "C3" & hbtreatcode == "S08000019" &
          location == "V217H" & ipdc == "D" ~ 1492.83,
        recid == "01B" & spec == "C3" & hbtreatcode == "S08000019" &
          location == "V217H" & ipdc == "I" ~ 3179.24 * yearstay,
        TRUE ~ cost_total_net
      ))
  }

  return(data)
}
