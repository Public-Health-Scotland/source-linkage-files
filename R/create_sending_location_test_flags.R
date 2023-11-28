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
      Aberdeen_City = {{ sending_location_var }} == 100L | {{ sending_location_var }} == "01",
      Aberdeenshire = {{ sending_location_var }} == 110L | {{ sending_location_var }} == "02",
      Angus = {{ sending_location_var }} == 120L | {{ sending_location_var }} == "03",
      Argyll_and_Bute = {{ sending_location_var }} == 130L | {{ sending_location_var }} == "04",
      City_of_Edinburgh = {{ sending_location_var }} == 230L | {{ sending_location_var }} == "14",
      Clackmannanshire = {{ sending_location_var }} == 150L | {{ sending_location_var }} == "06",
      Dumfries_and_Galloway = {{ sending_location_var }} == 170L | {{ sending_location_var }} == "08",
      Dundee_City = {{ sending_location_var }} == 180L | {{ sending_location_var }} == "09",
      East_Ayrshire = {{ sending_location_var }} == 190L | {{ sending_location_var }} == "10",
      East_Dunbartonshire = {{ sending_location_var }} == 200L | {{ sending_location_var }} == "11",
      East_Lothian = {{ sending_location_var }} == 210L | {{ sending_location_var }} == "12",
      East_Renfrewshire = {{ sending_location_var }} == 220L | {{ sending_location_var }} == "13",
      Falkirk = {{ sending_location_var }} == 240L | {{ sending_location_var }} == "15",
      Fife = {{ sending_location_var }} == 250L | {{ sending_location_var }} == "16",
      Glasgow_City = {{ sending_location_var }} == 260L | {{ sending_location_var }} == "17",
      Highland = {{ sending_location_var }} == 270L | {{ sending_location_var }} == "18",
      Inverclyde = {{ sending_location_var }} == 280L | {{ sending_location_var }} == "19",
      Midlothian = {{ sending_location_var }} == 290L | {{ sending_location_var }} == "20",
      Moray = {{ sending_location_var }} == 300L | {{ sending_location_var }} == "21",
      Na_h_Eileanan_Siar = {{ sending_location_var }} == 235L | {{ sending_location_var }} == "32",
      North_Ayrshire = {{ sending_location_var }} == 310L | {{ sending_location_var }} == "22",
      North_Lanarkshire = {{ sending_location_var }} == 320L | {{ sending_location_var }} == "23",
      Orkney_Islands = {{ sending_location_var }} == 330L | {{ sending_location_var }} == "24",
      Perth_and_Kinross = {{ sending_location_var }} == 340L | {{ sending_location_var }} == "25",
      Renfrewshire = {{ sending_location_var }} == 350L | {{ sending_location_var }} == "26",
      Scottish_Borders = {{ sending_location_var }} == 355L | {{ sending_location_var }} == "05",
      Shetland_Islands = {{ sending_location_var }} == 360L | {{ sending_location_var }} == "27",
      South_Ayrshire = {{ sending_location_var }} == 370L | {{ sending_location_var }} == "28",
      South_Lanarkshire = {{ sending_location_var }} == 380L | {{ sending_location_var }} == "29",
      Stirling = {{ sending_location_var }} == 390L | {{ sending_location_var }} == "30",
      West_Dunbartonshire = {{ sending_location_var }} == 395L | {{ sending_location_var }} == "07",
      West_Lothian = {{ sending_location_var }} == 400L | {{ sending_location_var }} == "31"
    )

  return(data)
}
