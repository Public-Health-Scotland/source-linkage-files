#' Create sending location test flags
#'
#' @description Create flags for sending location
#'
#' @param data the data containing the variable sending_location
#' @param sending_location_var sending_location variable
#' @return a dataframe with flag (T or F) for each sending location
#'
#' @family flag functions
create_sending_location_test_flags <- function(data, sending_location_var) {
  data <- data %>%
    dplyr::mutate(
      Aberdeen_City = {{ sending_location_var }} == 100L,
      Aberdeenshire = {{ sending_location_var }} == 110L,
      Angus = {{ sending_location_var }} == 120L,
      Argyll_and_Bute = {{ sending_location_var }} == 130L,
      City_of_Edinburgh = {{ sending_location_var }} == 230L,
      Clackmannanshire = {{ sending_location_var }} == 150L,
      Dumfries_and_Galloway = {{ sending_location_var }} == 170L,
      Dundee_City = {{ sending_location_var }} == 180L,
      East_Ayrshire = {{ sending_location_var }} == 190L,
      East_Dunbartonshire = {{ sending_location_var }} == 200L,
      East_Lothian = {{ sending_location_var }} == 210L,
      East_Renfrewshire = {{ sending_location_var }} == 220L,
      Falkirk = {{ sending_location_var }} ==240L,
      Fife = {{ sending_location_var }} == 250L,
      Glasgow_City = {{ sending_location_var }} == 260L,
      Highland = {{ sending_location_var }} == 270L,
      Inverclyde = {{ sending_location_var }} == 280L,
      Midlothian = {{ sending_location_var }} == 290L,
      Moray = {{ sending_location_var }} == 300L,
      Na_h_Eileanan_Siar = {{ sending_location_var }} == 235L,
      North_Ayrshire = {{ sending_location_var }} == 310L,
      North_Lanarkshire = {{ sending_location_var }} == 320L,
      Orkney_Islands = {{ sending_location_var }} == 330L,
      Perth_and_Kinross = {{ sending_location_var }} == 340L,
      Renfrewshire = {{ sending_location_var }} == 350L,
      Scottish_Borders = {{ sending_location_var }} == 355L,
      Shetland_Islands = {{ sending_location_var }} == 360L,
      South_Ayrshire = {{ sending_location_var }} == 370L,
      South_Lanarkshire = {{ sending_location_var }} == 380L,
      Stirling = {{ sending_location_var }} == 390L,
      West_Dunbartonshire = {{ sending_location_var }} == 395L,
      West_Lothian = {{ sending_location_var }} == 400L
    )

  return(data)
}

