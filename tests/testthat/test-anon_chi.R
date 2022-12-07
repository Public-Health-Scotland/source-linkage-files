test_that("convert from anon_chi to CHI", {
  anon_chi <- c(
    "MDkwMTk2NTI4Ng==",
    "MDYwODYyNjgwNQ==",
    "MDkwNDc0NjIxNg==",
    "MTgxMjYzMTE0Ng==",
    "MjAwNDUzMzQ0Nw=="
  )

  expect_equal(convert_anon_chi_to_chi(anon_chi),
    c(
      "0901965286",
      "0608626805",
      "0904746216",
      "1812631146",
      "2004533447"
    ),
    ignore_attr = TRUE
  )

  expect_snapshot(tibble::tibble(anon_chi = anon_chi) %>%
    dplyr::mutate(chi = convert_anon_chi_to_chi(anon_chi)))
})

test_that("convert from CHI to anon_chi", {
  chi <- c(
    "0901965286",
    "0608626805",
    "0904746216",
    "1812631146",
    "2004533447"
  )

  expect_equal(convert_chi_to_anon_chi(chi),
    c(
      "MDkwMTk2NTI4Ng==",
      "MDYwODYyNjgwNQ==",
      "MDkwNDc0NjIxNg==",
      "MTgxMjYzMTE0Ng==",
      "MjAwNDUzMzQ0Nw=="
    ),
    ignore_attr = TRUE
  )

  expect_snapshot(tibble::tibble(chi = chi) %>%
    dplyr::mutate(anon_chi = convert_chi_to_anon_chi(chi)))
})
