skip_if_offline()

test_that("GP prac cluster lookup is correct", {
  gp_cluster_lookup <- expect_warning(get_gpprac_opendata())

  expect_named(
    gp_cluster_lookup,
    c(
      "gpprac",
      "practice_name",
      "postcode",
      "cluster",
      "partnership",
      "health_board"
    )
  )
})
