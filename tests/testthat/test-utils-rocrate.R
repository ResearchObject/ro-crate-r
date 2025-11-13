test_that("is_rocrate works", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()

  expect_equal(basic_crate, basic_crate |>
                 rocrateR::is_rocrate())

  # pass an empty list to rocrateR::is_rocrate()
  expect_error(list() |>
                 rocrateR::is_rocrate())

  # drop the RO-Crate Metadata descriptor entity
  basic_crate_v2 <- basic_crate |>
    rocrateR::remove_entity(entity = "ro-crate-metadata.json")

  expect_error(basic_crate_v2 |>
                 rocrateR::is_rocrate())

  # drop the root entity
  basic_crate_v3 <- basic_crate |>
    rocrateR::remove_entity(entity = "./")

  expect_error(basic_crate_v3 |>
                 rocrateR::is_rocrate())

  # modify entity to remove @type
  basic_crate$`@graph`[[1]]$`@type` <- NULL
  expect_error(
    expect_warning(basic_crate |> rocrateR::is_rocrate())
  )
  
  # set invalid context value
  basic_crate$`@context` <- "My awesome, but non-standard context"
  expect_error(
    expect_warning(
      basic_crate |> rocrateR::is_rocrate()
    )
  )
  
  # drop @graph from a valid RO-Crate
  basic_crate_v4 <- rocrateR::rocrate()
  basic_crate_v4$`@graph` <- NULL
  expect_error(rocrateR::is_rocrate(basic_crate_v4))
  
  # drop @type from one of the entities
  basic_crate_v5 <- rocrateR::rocrate()
  basic_crate_v5$`@graph`[[2]]$`@type` <- NULL
  expect_error(
    expect_warning(rocrateR::is_rocrate(basic_crate_v5))
  )
})
