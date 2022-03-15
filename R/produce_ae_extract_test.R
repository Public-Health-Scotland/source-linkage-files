#' Produce the A & E Extract Test
#'
#' @param data new or old data for summarising flags
#'
#' @return a dataframe with additional variables containing flags
#' @export
#' @importFrom dplyr mutate select
#' @family produce tests functions
#' @seealso \code{\link{create_ae_extract_flags}} and
produce_ae_extract_test <- function(data, postcode = TRUE) {
  if (postcode == TRUE) {
    data %>%
      summarise(
        n_chi = sum(valid_chi, na.rm = TRUE),
        unique_chi = sum(unique_chi, na.rm = TRUE),
        n_missing_chi = sum(n_missing_chi, na.rm = TRUE),
        n_male = sum(n_males, na.rm = TRUE),
        n_female = sum(n_females, na.rm = TRUE),
        mean_age = mean(age, na.rm = TRUE),
        n_postcode = sum(n_postcode, na.rm = TRUE),
        n_missing_postcode = sum(n_missing_postcode, na.rm = TRUE),
        missing_dob = sum(missing_dob, na.rm = TRUE),
        total_cost = sum(cost_total_net, na.rm = TRUE),
        mean_cost = mean(cost_total_net, na.rm = TRUE),
        max_cost = max(cost_total_net, na.rm = TRUE),
        min_cost = min(cost_total_net, na.rm = TRUE),
        earliest_start1 = min(record_keydate1),
        earliest_start2 = min(record_keydate2),
        latest_start1 = max(record_keydate1),
        latest_start2 = max(record_keydate2),

        # total costs
        total_cost_apr = sum(apr_cost, na.rm = TRUE),
        total_cost_may = sum(may_cost, na.rm = TRUE),
        total_cost_jun = sum(jun_cost, na.rm = TRUE),
        total_cost_jul = sum(jul_cost, na.rm = TRUE),
        total_cost_aug = sum(aug_cost, na.rm = TRUE),
        total_cost_sep = sum(sep_cost, na.rm = TRUE),
        total_cost_oct = sum(oct_cost, na.rm = TRUE),
        total_cost_nov = sum(nov_cost, na.rm = TRUE),
        total_cost_dec = sum(dec_cost, na.rm = TRUE),
        total_cost_jan = sum(jan_cost, na.rm = TRUE),
        total_cost_feb = sum(feb_cost, na.rm = TRUE),
        total_cost_mar = sum(mar_cost, na.rm = TRUE),

        # mean costs
        mean_cost_apr = mean(apr_cost, na.rm = TRUE),
        mean_cost_may = mean(may_cost, na.rm = TRUE),
        mean_cost_jun = mean(jun_cost, na.rm = TRUE),
        mean_cost_jul = mean(jul_cost, na.rm = TRUE),
        mean_cost_aug = mean(aug_cost, na.rm = TRUE),
        mean_cost_sep = mean(sep_cost, na.rm = TRUE),
        mean_cost_oct = mean(oct_cost, na.rm = TRUE),
        mean_cost_nov = mean(nov_cost, na.rm = TRUE),
        mean_cost_dec = mean(dec_cost, na.rm = TRUE),
        mean_cost_jan = mean(jan_cost, na.rm = TRUE),
        mean_cost_feb = mean(feb_cost, na.rm = TRUE),
        mean_cost_mar = mean(mar_cost, na.rm = TRUE),

        # hb
        NHS_Ayrshire_and_Arran = sum(NHS_Ayrshire_and_Arran),
        NHS_Borders = sum(NHS_Borders),
        NHS_Dumfries_and_Galloway = sum(NHS_Dumfries_and_Galloway),
        NHS_Forth_Valley = sum(NHS_Forth_Valley),
        NHS_Grampian = sum(NHS_Grampian),
        NHS_Highland = sum(NHS_Highland),
        NHS_Lothian = sum(NHS_Lothian),
        NHS_Orkney = sum(NHS_Orkney),
        NHS_Shetland = sum(NHS_Shetland),
        NHS_Western_Isles = sum(NHS_Western_Isles),
        NHS_Fife = sum(NHS_Fife),
        NHS_Tayside = sum(NHS_Tayside),
        NHS_Greater_Glasgow_and_Clyde = sum(NHS_Greater_Glasgow_and_Clyde),
        NHS_Lanarkshire = sum(NHS_Lanarkshire),
        # costs #
        NHS_Ayrshire_and_Arran_cost = sum(NHS_Ayrshire_and_Arran_cost),
        NHS_Borders_cost = sum(NHS_Borders_cost),
        NHS_Dumfries_and_Galloway_cost = sum(NHS_Dumfries_and_Galloway_cost),
        NHS_Forth_Valley_cost = sum(NHS_Forth_Valley_cost),
        NHS_Grampian_cost = sum(NHS_Grampian_cost),
        NHS_Highland_cost = sum(NHS_Highland_cost),
        NHS_Lothian_cost = sum(NHS_Lothian_cost),
        NHS_Orkney_cost = sum(NHS_Orkney_cost),
        NHS_Shetland_cost = sum(NHS_Shetland_cost),
        NHS_Western_Isles_cost = sum(NHS_Western_Isles_cost),
        NHS_Fife_cost = sum(NHS_Fife_cost),
        NHS_Tayside_cost = sum(NHS_Tayside_cost),
        NHS_Greater_Glasgow_and_Clyde_cost = sum(NHS_Greater_Glasgow_and_Clyde_cost),
        NHS_Lanarkshire_cost = sum(NHS_Lanarkshire_cost)
      ) %>%
      mutate_all(as.character) %>%
      tidyr::pivot_longer(
        cols = everything(),
        names_to = "measure",
        values_to = "value",
        values_ptypes = list(value = as.character())
      )
  } else {
    data %>%
      summarise(
        n_chi = sum(valid_chi, na.rm = TRUE),
        unique_chi = sum(unique_chi, na.rm = TRUE),
        n_missing_chi = sum(n_missing_chi, na.rm = TRUE),
        n_male = sum(n_males, na.rm = TRUE),
        n_female = sum(n_females, na.rm = TRUE),
        mean_age = mean(age, na.rm = TRUE),
        missing_dob = sum(missing_dob, na.rm = TRUE),
        total_cost = sum(cost_total_net, na.rm = TRUE),
        mean_cost = mean(cost_total_net, na.rm = TRUE),
        max_cost = max(cost_total_net, na.rm = TRUE),
        min_cost = min(cost_total_net, na.rm = TRUE),
        #earliest_start1 = min(record_keydate1),
        #earliest_start2 = min(record_keydate2),
        #latest_start1 = max(record_keydate1),
        #latest_start2 = max(record_keydate2),

        # total costs
        total_cost_apr = sum(apr_cost, na.rm = TRUE),
        total_cost_may = sum(may_cost, na.rm = TRUE),
        total_cost_jun = sum(jun_cost, na.rm = TRUE),
        total_cost_jul = sum(jul_cost, na.rm = TRUE),
        total_cost_aug = sum(aug_cost, na.rm = TRUE),
        total_cost_sep = sum(sep_cost, na.rm = TRUE),
        total_cost_oct = sum(oct_cost, na.rm = TRUE),
        total_cost_nov = sum(nov_cost, na.rm = TRUE),
        total_cost_dec = sum(dec_cost, na.rm = TRUE),
        total_cost_jan = sum(jan_cost, na.rm = TRUE),
        total_cost_feb = sum(feb_cost, na.rm = TRUE),
        total_cost_mar = sum(mar_cost, na.rm = TRUE),

        # mean costs
        mean_cost_apr = mean(apr_cost, na.rm = TRUE),
        mean_cost_may = mean(may_cost, na.rm = TRUE),
        mean_cost_jun = mean(jun_cost, na.rm = TRUE),
        mean_cost_jul = mean(jul_cost, na.rm = TRUE),
        mean_cost_aug = mean(aug_cost, na.rm = TRUE),
        mean_cost_sep = mean(sep_cost, na.rm = TRUE),
        mean_cost_oct = mean(oct_cost, na.rm = TRUE),
        mean_cost_nov = mean(nov_cost, na.rm = TRUE),
        mean_cost_dec = mean(dec_cost, na.rm = TRUE),
        mean_cost_jan = mean(jan_cost, na.rm = TRUE),
        mean_cost_feb = mean(feb_cost, na.rm = TRUE),
        mean_cost_mar = mean(mar_cost, na.rm = TRUE),

        # hb
        NHS_Ayrshire_and_Arran = sum(NHS_Ayrshire_and_Arran),
        NHS_Borders = sum(NHS_Borders),
        NHS_Dumfries_and_Galloway = sum(NHS_Dumfries_and_Galloway),
        NHS_Forth_Valley = sum(NHS_Forth_Valley),
        NHS_Grampian = sum(NHS_Grampian),
        NHS_Highland = sum(NHS_Highland),
        NHS_Lothian = sum(NHS_Lothian),
        NHS_Orkney = sum(NHS_Orkney),
        NHS_Shetland = sum(NHS_Shetland),
        NHS_Western_Isles = sum(NHS_Western_Isles),
        NHS_Fife = sum(NHS_Fife),
        NHS_Tayside = sum(NHS_Tayside),
        NHS_Greater_Glasgow_and_Clyde = sum(NHS_Greater_Glasgow_and_Clyde),
        NHS_Lanarkshire = sum(NHS_Lanarkshire),
        # costs #
        NHS_Ayrshire_and_Arran_cost = sum(NHS_Ayrshire_and_Arran_cost),
        NHS_Borders_cost = sum(NHS_Borders_cost),
        NHS_Dumfries_and_Galloway_cost = sum(NHS_Dumfries_and_Galloway_cost),
        NHS_Forth_Valley_cost = sum(NHS_Forth_Valley_cost),
        NHS_Grampian_cost = sum(NHS_Grampian_cost),
        NHS_Highland_cost = sum(NHS_Highland_cost),
        NHS_Lothian_cost = sum(NHS_Lothian_cost),
        NHS_Orkney_cost = sum(NHS_Orkney_cost),
        NHS_Shetland_cost = sum(NHS_Shetland_cost),
        NHS_Western_Isles_cost = sum(NHS_Western_Isles_cost),
        NHS_Fife_cost = sum(NHS_Fife_cost),
        NHS_Tayside_cost = sum(NHS_Tayside_cost),
        NHS_Greater_Glasgow_and_Clyde_cost = sum(NHS_Greater_Glasgow_and_Clyde_cost),
        NHS_Lanarkshire_cost = sum(NHS_Lanarkshire_cost)
      ) %>%
      #mutate_all(as.character) %>%
      tidyr::pivot_longer(
        cols = everything(),
        names_to = "measure",
        values_to = "value",
        values_transform = list(value = as.numeric)
      )
  }
}
