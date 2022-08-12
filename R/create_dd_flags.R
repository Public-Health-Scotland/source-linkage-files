#' Create flags for delayed discharges data
#'
#' @param data the dd linked file
#' @param year Financial year e.g. 1819
#'
#' @return a dataframe with flag (TRUE or FALSE) for each criteria for filtering
#' delayed discharges episodes.
#' @export
#'
create_dd_flags <- function(data, year) {
  # Assign spec to object
  mh_spec <- c("CC", "G1", "G2", "G21", "G22", "G3", "G4", "G5", "G6", "G61", "G62", "G63")

  # Flag records with no end date
  data <- data %>%
    dplyr::mutate(
      no_end_date = dplyr::if_else(is.na(keydate2_dateformat) & (!(spec %in% mh_spec)),
        TRUE,
        FALSE
      ),
      # Flag records with correct date
      correct_dates = dplyr::if_else(is_date_in_fyyear(year, keydate1_dateformat) |
        is_date_in_fyyear(year, keydate2_dateformat) |
        is.na(keydate2_dateformat) & .data$spec %in% mh_spec,
      TRUE,
      FALSE
      )
    )

  return(data)
}
