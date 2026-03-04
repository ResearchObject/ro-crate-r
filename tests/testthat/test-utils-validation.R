test_that("RO-Crate 1.2 profile validation passes for minimal valid crate", {
  crate <- rocrateR::rocrate()

  result <- validate_rocrate(crate, mode = "report", strict = TRUE)

  expect_s3_class(result, "rocrate_validation")
  expect_true(length(result$errors) == 0)
})

test_that("5S profile fails when license missing", {
  crate <- rocrateR::rocrate_5s()

  crate$`@graph`[[2]]$license <- NULL

  result <- validate_rocrate(crate, mode = "report", strict = TRUE)

  expect_false(length(result$errors) == 0)
  expect_true(any(grepl("license", result$errors)))
})

test_that("Unknown profile is skipped silently", {
  crate <- rocrateR::rocrate()

  crate$`@graph`[[1]]$conformsTo <- list(
    list(`@id` = "https://example.org/unknown-profile")
  )

  result <- validate_rocrate(crate, mode = "report", strict = TRUE)

  expect_true(length(result$errors) == 0)
})
