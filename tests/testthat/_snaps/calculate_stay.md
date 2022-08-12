# calculate stay function works

    Code
      test_tibble %>% dplyr::mutate(stay = calculate_stay("1920", start_date,
        end_date, sc_latest_submission))
    Output
      # A tibble: 20 x 4
         start_date end_date   sc_latest_submission  stay
         <date>     <date>     <chr>                <dbl>
       1 2019-03-31 2019-10-31 <NA>                   214
       2 2019-06-30 2019-08-31 <NA>                    62
       3 2019-01-01 2020-04-01 <NA>                   456
       4 2019-04-01 2020-07-01 <NA>                   457
       5 2019-03-31 NA         <NA>                    NA
       6 2019-06-30 NA         <NA>                    NA
       7 2019-01-01 NA         <NA>                    NA
       8 2019-04-01 NA         <NA>                    NA
       9 2019-03-31 NA         2019Q1                  92
      10 2019-06-30 NA         2019Q2                  93
      11 2019-01-01 NA         2019Q3                 365
      12 2019-04-01 NA         2019Q4                 366
      13 2019-07-31 NA         2019Q1                  62
      14 2019-10-31 NA         2019Q2                  62
      15 2020-01-31 NA         2019Q3                  61
      16 2020-04-30 NA         2019Q4                  62
      17 2019-03-31 2019-10-31 2019Q1                 214
      18 2019-06-30 2019-08-31 2019Q2                  62
      19 2019-01-01 2020-04-01 2019Q3                 456
      20 2019-04-01 2020-07-01 2019Q4                 457

