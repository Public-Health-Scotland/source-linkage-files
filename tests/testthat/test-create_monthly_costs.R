test_that("can create monthly cost for maternity", {
  # Tests
  # * Single day episodes work with 0, 0.33(only maternity) or 1+ yearstay
  # * Multi day episodes work with 0 or 1+ yearstay
  # * episodes which span months work
  # * episodes which span financial years work
  # * episodes in a single month (multiday) work

  dummy_data =  dplyr::bind_cols(
    year = rep("1718", 5),
    yearstay = c(0, 0.33, 0.33, 30, 365),
    record_keydate1 = c(
      "2017-09-01",
      "2017-04-01",
      "2017-05-01",
      "2017-04-21",
      "2017-04-01"
    ) %>% lubridate::ymd(),
    record_keydate2 = c(
      "2017-09-01",
      "2017-04-01",
      "2017-05-01",
      "2017-05-20",
      "2018-03-31"
    ) %>% lubridate::ymd(),
    cost_per_day = rep(100, 5),
    cost_total_net = c(0, 100, 0, 3000, 36500),
    apr_beddays = c(0, 0, 0, 10, 30),
    may_beddays = c(0, 0, 0, 20, 31),
    jun_beddays = c(0, 0, 0, 0, 30),
    jul_beddays = c(0, 0, 0, 0, 31),
    aug_beddays = c(0, 0, 0, 0, 31),
    sep_beddays = c(0, 0, 0, 0, 30),
    oct_beddays = c(0, 0, 0, 0, 31),
    nov_beddays = c(0, 0, 0, 0, 30),
    dec_beddays = c(0, 0, 0, 0, 31),
    jan_beddays = c(0, 0, 0, 0, 31),
    feb_beddays = c(0, 0, 0, 0, 28),
    mar_beddays = c(0, 0, 0, 0, 30)
  )

  dummy_data_cost = dummy_data %>%
    dplyr::mutate(
      apr_cost = c(0, 100, 0, 1000, 3000),
      may_cost = c(0,   0, 0, 2000, 3100),
      jun_cost = c(0,   0, 0, 0, 3000),
      jul_cost = c(0,   0, 0, 0, 3100),
      aug_cost = c(0,   0, 0, 0, 3100),
      sep_cost = c(0,   0, 0, 0, 3000),
      oct_cost = c(0,   0, 0, 0, 3100),
      nov_cost = c(0,   0, 0, 0, 3000),
      dec_cost = c(0,   0, 0, 0, 3100),
      jan_cost = c(0,   0, 0, 0, 3100),
      feb_cost = c(0,   0, 0, 0, 2800),
      mar_cost = c(0,   0, 0, 0, 3000)
    )

  expect_equal(create_monthly_costs(dummy_data),
               dummy_data_cost)
})

test_that("can create monthly cost generally", {
  # Tests
  # * Multi day episodes work with 0 or 1+ yearstay
  # * episodes which span months work
  # * episodes which span financial years work
  # * episodes in a single month (multiday) work

  dummy_data1 =  dplyr::bind_cols(
    year = rep("1718", 4),
    yearstay = c(0, 0, 0, 30),
    record_keydate1 = c("2017-09-01",
                        "2017-04-01",
                        "2017-05-01",
                        "2017-04-21") %>% lubridate::ymd(),
    record_keydate2 = c("2017-09-01",
                        "2017-04-01",
                        "2017-05-01",
                        "2017-05-20") %>% lubridate::ymd(),
    cost_per_day = rep(100, 4),
    cost_total_net = c(0, 0, 0, 3000)
  ) %>% create_monthly_beddays("1718",
                               .data$record_keydate1,
                               .data$record_keydate2,
                               count_last = FALSE)

  dummy_data1_cost = dummy_data1 %>%
    dplyr::mutate(
      apr_cost = c(0,   0, 0, 1000),
      may_cost = c(0,   0, 0, 1900),
      jun_cost = c(0,   0, 0, 0),
      jul_cost = c(0,   0, 0, 0),
      aug_cost = c(0,   0, 0, 0),
      sep_cost = c(0,   0, 0, 0),
      oct_cost = c(0,   0, 0, 0),
      nov_cost = c(0,   0, 0, 0),
      dec_cost = c(0,   0, 0, 0),
      jan_cost = c(0,   0, 0, 0),
      feb_cost = c(0,   0, 0, 0),
      mar_cost = c(0,   0, 0, 0)
    )

  expect_equal(
    create_monthly_costs(dummy_data1, cost_total_net = yearstay * cost_per_day),
    dummy_data1_cost
  )
})
