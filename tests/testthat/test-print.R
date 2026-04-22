test_that("print.rocrate works", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()
  # test that the print method returns invisibly an RO-Crate
  testthat::expect_invisible(print(basic_crate))
  testthat::expect_equal(print(basic_crate), basic_crate)

  # test that the contents of the RO-Crate are displayed as message
  testthat::expect_message(print(basic_crate))
})

test_that("print.entity works", {
  # create basic RO-Crate entity
  basic_entity <- rocrateR::entity("./", type = "Dateset")
  # test that the print method returns invisibly an RO-Crate entity
  testthat::expect_invisible(print(basic_entity))
  testthat::expect_equal(print(basic_entity), basic_entity)

  # test that the contents of the RO-Crate are displayed as message
  testthat::expect_message(print(basic_entity))
})

test_that("print.rocrate_validation works", {
  x <- structure(list(valid = TRUE), class = "rocrate_validation")
  expect_equal(print(x), x)

  x2 <- structure(
    list(
      valid = FALSE,
      errors = "This is an error",
      warnings = "This is a warning"
    ),
    class = "rocrate_validation"
  )
  expect_equal(print(x2), x2)
})
