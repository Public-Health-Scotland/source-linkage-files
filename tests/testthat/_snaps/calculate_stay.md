# Calculate stay works well in the normal use case

    Code
      tibble::tribble(~start_date, ~end_date, as.Date("2019-03-31"), as.Date(
        "2019-10-31"), as.Date("2019-06-30"), as.Date("2019-08-31"), as.Date(
        "2019-01-01"), as.Date("2020-04-01"), as.Date("2019-04-01"), as.Date(
        "2020-07-01"), as.Date("2019-03-31"), lubridate::NA_Date_, as.Date(
        "2019-06-30"), lubridate::NA_Date_, as.Date("2019-01-01"), lubridate::NA_Date_,
      as.Date("2019-04-01"), lubridate::NA_Date_) %>% dplyr::mutate(stay = calculate_stay(
        "1920", start_date, end_date))
    Output
      # A tibble: 8 x 3
        start_date end_date    stay
        <date>     <date>     <dbl>
      1 2019-03-31 2019-10-31   214
      2 2019-06-30 2019-08-31    62
      3 2019-01-01 2020-04-01   456
      4 2019-04-01 2020-07-01   457
      5 2019-03-31 NA           367
      6 2019-06-30 NA           276
      7 2019-01-01 NA           456
      8 2019-04-01 NA           366

# Calculate stay works well in the Social Care use case

    Code
      tibble::tribble(~start_date, ~end_date, ~sc_qtr, as.Date("2019-03-31"),
      lubridate::NA_Date_, "2019Q1", as.Date("2019-06-30"), lubridate::NA_Date_,
      "2019Q2", as.Date("2019-01-01"), lubridate::NA_Date_, "2019Q3", as.Date(
        "2019-04-01"), lubridate::NA_Date_, "2019Q4", as.Date("2019-07-31"),
      lubridate::NA_Date_, "2019Q1", as.Date("2019-10-31"), lubridate::NA_Date_,
      "2019Q2", as.Date("2020-01-31"), lubridate::NA_Date_, "2019Q3", as.Date(
        "2020-04-30"), lubridate::NA_Date_, "2019Q4", as.Date("2019-03-31"), as.Date(
        "2019-10-31"), "2019Q1", as.Date("2019-06-30"), as.Date("2019-08-31"),
      "2019Q2", as.Date("2019-01-01"), as.Date("2020-04-01"), "2019Q3", as.Date(
        "2019-04-01"), as.Date("2020-07-01"), "2019Q4") %>% dplyr::mutate(stay = calculate_stay(
        "1920", start_date, end_date, sc_qtr))
    Output
      # A tibble: 12 x 4
         start_date end_date   sc_qtr  stay
         <date>     <date>     <chr>  <dbl>
       1 2019-03-31 NA         2019Q1    92
       2 2019-06-30 NA         2019Q2    93
       3 2019-01-01 NA         2019Q3   365
       4 2019-04-01 NA         2019Q4   366
       5 2019-07-31 NA         2019Q1    62
       6 2019-10-31 NA         2019Q2    62
       7 2020-01-31 NA         2019Q3    61
       8 2020-04-30 NA         2019Q4    62
       9 2019-03-31 2019-10-31 2019Q1   214
      10 2019-06-30 2019-08-31 2019Q2    62
      11 2019-01-01 2020-04-01 2019Q3   456
      12 2019-04-01 2020-07-01 2019Q4   457

