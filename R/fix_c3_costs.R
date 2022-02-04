#' Fix c3 costs
#'
#' @param data Acute extract file after processing
#'
#' @return
#' @export
#'
fix_c3_costs <- function(data) {
  data <- data %>%
    # Calculate costs for NHS Ayrshire & Arran
    mutate(cost_total_net = case_when(
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
        location == "V217H" & ipdc == "I" ~ 3179.24 * yearstay
    ))

  if (year >= "1819") {
    return(data)
  } else {
    stop("do not run c3 costs fix, year < 1819")
  }
}
