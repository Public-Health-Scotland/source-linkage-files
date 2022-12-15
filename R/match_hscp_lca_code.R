#' Match dummy HSCP and LCA codes
#'
#' @description Match dummy HSCP and LCA codes
#'
#' @param data episode files
#'
#' @return data with matched hscp and lca codes
#' @export
#'
#' @examples match_hscp_lca_code(data)
match_hscp_lca_code <- function(data) {
  data <- data %>%
    # Recode some strange dummy codes which seem to come from A&E
    tidylog::mutate(
      hscp2018 = dplyr::case_when(hscp2018 %in% c("S37999998", "S37999999") ~ "",
                                  TRUE ~ hscp2018),
      # If we can, 'cascade' the geographies upwards
      # i.e. if they have an LCA use this to fill in HSCP2018 and so on for hbrescode
      # Codes are correct as at August 2018
      lca = dplyr::case_when(
        is_missing(lca) & hscp2018 == "S37000001" ~ "01",
        is_missing(lca) & hscp2018 == "S37000002" ~ "02",
        is_missing(lca) & hscp2018 == "S37000003" ~ "03",
        is_missing(lca) & hscp2018 == "S37000004" ~ "04",
        is_missing(lca) & hscp2018 == "S37000025" ~ "05",
        is_missing(lca) & hscp2018 == "S37000029" ~ "07",
        is_missing(lca) & hscp2018 == "S37000006" ~ "08",
        is_missing(lca) & hscp2018 == "S37000007" ~ "09",
        is_missing(lca) & hscp2018 == "S37000008" ~ "10",
        is_missing(lca) & hscp2018 == "S37000009" ~ "11",
        is_missing(lca) & hscp2018 == "S37000010" ~ "12",
        is_missing(lca) & hscp2018 == "S37000011" ~ "13",
        is_missing(lca) & hscp2018 == "S37000012" ~ "14",
        is_missing(lca) & hscp2018 == "S37000013" ~ "15",
        is_missing(lca) & hscp2018 == "S37000032" ~ "16",
        is_missing(lca) & hscp2018 == "S37000015" ~ "17",
        is_missing(lca) & hscp2018 == "S37000016" ~ "18",
        is_missing(lca) & hscp2018 == "S37000017" ~ "19",
        is_missing(lca) & hscp2018 == "S37000018" ~ "20",
        is_missing(lca) & hscp2018 == "S37000019" ~ "21",
        is_missing(lca) & hscp2018 == "S37000020" ~ "22",
        is_missing(lca) & hscp2018 == "S37000021" ~ "23",
        is_missing(lca) & hscp2018 == "S37000022" ~ "24",
        is_missing(lca) & hscp2018 == "S37000033" ~ "25",
        is_missing(lca) & hscp2018 == "S37000024" ~ "26",
        is_missing(lca) & hscp2018 == "S37000026" ~ "27",
        is_missing(lca) & hscp2018 == "S37000027" ~ "28",
        is_missing(lca) & hscp2018 == "S37000028" ~ "29",
        is_missing(lca) & hscp2018 == "S37000030" ~ "31",
        is_missing(lca) & hscp2018 == "S37000031" ~ "32",
        TRUE ~ lca
      ),
      # Next, use LCA to fill in hscp2018 if possible
      hscp2018 = dplyr::case_when(
        is_missing(hscp2018) & lca == "01" ~ "S37000001",
        is_missing(hscp2018) & lca == "02" ~ "S37000002",
        is_missing(hscp2018) & lca == "03" ~ "S37000003",
        is_missing(hscp2018) & lca == "04" ~ "S37000004",
        is_missing(hscp2018) & lca == "05" ~ "S37000025",
        is_missing(hscp2018) & lca == "06" ~ "S37000005",
        is_missing(hscp2018) & lca == "07" ~ "S37000029",
        is_missing(hscp2018) & lca == "08" ~ "S37000006",
        is_missing(hscp2018) & lca == "09" ~ "S37000007",
        is_missing(hscp2018) & lca == "10" ~ "S37000008",
        is_missing(hscp2018) & lca == "11" ~ "S37000009",
        is_missing(hscp2018) & lca == "12" ~ "S37000010",
        is_missing(hscp2018) & lca == "13" ~ "S37000011",
        is_missing(hscp2018) & lca == "14" ~ "S37000012",
        is_missing(hscp2018) & lca == "15" ~ "S37000013",
        is_missing(hscp2018) & lca == "16" ~ "S37000032",
        is_missing(hscp2018) & lca == "17" ~ "S37000015",
        is_missing(hscp2018) & lca == "18" ~ "S37000016",
        is_missing(hscp2018) & lca == "19" ~ "S37000017",
        is_missing(hscp2018) & lca == "20" ~ "S37000018",
        is_missing(hscp2018) & lca == "21" ~ "S37000019",
        is_missing(hscp2018) & lca == "22" ~ "S37000020",
        is_missing(hscp2018) & lca == "23" ~ "S37000021",
        is_missing(hscp2018) & lca == "24" ~ "S37000022",
        is_missing(hscp2018) & lca == "25" ~ "S37000033",
        is_missing(hscp2018) & lca == "26" ~ "S37000024",
        is_missing(hscp2018) & lca == "27" ~ "S37000026",
        is_missing(hscp2018) & lca == "28" ~ "S37000027",
        is_missing(hscp2018) & lca == "29" ~ "S37000028",
        is_missing(hscp2018) & lca == "30" ~ "S37000005",
        is_missing(hscp2018) & lca == "31" ~ "S37000030",
        is_missing(hscp2018) & lca == "32" ~ "S37000031",
        TRUE ~ hscp2018
      ),
      # Next, use LCA to fill in ca2018
      ca2018 = dplyr::case_when(
        is_missing(ca2018) & lca == "01" ~ "S12000033",
        is_missing(ca2018) & lca == "02" ~ "S12000034",
        is_missing(ca2018) & lca == "03" ~ "S12000041",
        is_missing(ca2018) & lca == "04" ~ "S12000035",
        is_missing(ca2018) & lca == "05" ~ "S12000026",
        is_missing(ca2018) & lca == "06" ~ "S12000005",
        is_missing(ca2018) & lca == "07" ~ "S12000039",
        is_missing(ca2018) & lca == "08" ~ "S12000006",
        is_missing(ca2018) & lca == "09" ~ "S12000042",
        is_missing(ca2018) & lca == "10" ~ "S12000008",
        is_missing(ca2018) & lca == "11" ~ "S12000045",
        is_missing(ca2018) & lca == "12" ~ "S12000010",
        is_missing(ca2018) & lca == "13" ~ "S12000011",
        is_missing(ca2018) & lca == "14" ~ "S12000036",
        is_missing(ca2018) & lca == "15" ~ "S12000014",
        is_missing(ca2018) & lca == "16" ~ "S12000047",
        is_missing(ca2018) & lca == "17" ~ "S12000046",
        is_missing(ca2018) & lca == "18" ~ "S12000017",
        is_missing(ca2018) & lca == "19" ~ "S12000018",
        is_missing(ca2018) & lca == "20" ~ "S12000019",
        is_missing(ca2018) & lca == "21" ~ "S12000020",
        is_missing(ca2018) & lca == "22" ~ "S12000021",
        is_missing(ca2018) & lca == "23" ~ "S12000044",
        is_missing(ca2018) & lca == "24" ~ "S12000023",
        is_missing(ca2018) & lca == "25" ~ "S12000048",
        is_missing(ca2018) & lca == "26" ~ "S12000038",
        is_missing(ca2018) & lca == "27" ~ "S12000027",
        is_missing(ca2018) & lca == "28" ~ "S12000028",
        is_missing(ca2018) & lca == "29" ~ "S12000029",
        is_missing(ca2018) & lca == "30" ~ "S12000030",
        is_missing(ca2018) & lca == "31" ~ "S12000040",
        is_missing(ca2018) & lca == "32" ~ "S12000013",
        TRUE ~ ca2018
      ),
      # Finally, use hscp2018 to fill hbrescode
      hbrescode = dplyr::case_when(
        is_missing(hbrescode) &
          hscp2019 %in% c("S37000008", "S37000020", "S37000027") ~ "S08000015",
        is_missing(hbrescode) &
          hscp2019 %in% c("S37000025") ~ "S08000016",
        is_missing(hbrescode) &
          hscp2019 %in% c("S37000006") ~ "S08000017",
        is_missing(hbrescode) &
          hscp2019 %in% c("S37000005", "S37000013") ~ "S08000019",
        is_missing(hbrescode) &
          hscp2019 %in% c("S37000001", "S37000002", "S37000019") ~ "S08000020",
        is_missing(hbrescode) & hscp2019 %in% c(
          "S37000009",
          "S37000011",
          "S37000015",
          "S37000017",
          "S37000024",
          "S37000029"
        ) ~ "S08000021",
        is_missing(hbrescode) &
          hscp2019 %in% c("S37000004", "S37000016") ~ "S08000022",
        is_missing(hbrescode) &
          hscp2019 %in% c("S37000021", "S37000028") ~ "S08000023",
        is_missing(hbrescode) & hscp2019 %in% c("S37000010", "S37000012", "S37000018",
                                                "S37000030") ~ "S08000024",
        is_missing(hbrescode) &
          hscp2019 %in% c("S37000022") ~ "S08000025",
        is_missing(hbrescode) &
          hscp2019 %in% c("S37000026") ~ "S08000026",
        is_missing(hbrescode) &
          hscp2019 %in% c("S37000031") ~ "S08000028",
        is_missing(hbrescode) &
          hscp2019 %in% c("S37000032") ~ "S08000029",
        is_missing(hbrescode) &
          hscp2019 %in% c("S37000003", "S37000007", "S37000033") ~ "S08000030",
        TRUE ~ hbrescode
      )
    )

  return(data)
}
