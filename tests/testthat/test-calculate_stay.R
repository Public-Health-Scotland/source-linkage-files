test_that("Can return correct length of stay", {

  expect_equal(calculate_stay("1920 ", as.Date("2019/05/30"), as.Date(NA)), 307)
  expect_equal(calculate_stay("1920", as.Date("2018/06/06"), as.Date("2020/09/30")), 847)
  expect_equal(calculate_stay("1920", as.Date("2020/03/19"), as.Date("2020/04/30")), 42)
})

  expect_equal(calculate_stay("1920", as.Date(c("2019/05/30", "2018/06/06")), as.Date(c(NA, "2020/09/30"))), c(307, 847))
  expect_equal(calculate_stay("1920", as.Date(c("2019/05/30", "2018/06/06")), as.Date(c("2020/04/01", NA))), c(307, 307))


  expect_snapshot(test_tibble %>% mutate(stay = calculate_stay("1920", start_date, end_date)))
  expect_equal(calcu)


})

