test_that("is_rocrate works", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()

  expect_true(
    basic_crate |>
      rocrateR::is_rocrate()
  )

  # check with `strict = TRUE`
  expect_true(
    basic_crate |>
      rocrateR::is_rocrate(strict = TRUE)
  )

  # pass an empty list to rocrateR::is_rocrate()
  expect_error(
    list() |>
      rocrateR::is_rocrate()
  )

  # drop the RO-Crate Metadata descriptor entity
  basic_crate_v2 <- basic_crate |>
    rocrateR::remove_entity(entity = "ro-crate-metadata.json")

  expect_error(
    basic_crate_v2 |>
      rocrateR::is_rocrate()
  )

  # drop the root entity
  basic_crate_v3 <- basic_crate |>
    rocrateR::remove_entity(entity = "./")

  expect_error(
    basic_crate_v3 |>
      rocrateR::is_rocrate()
  )

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

test_that("load_rocrate reads metadata file", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()

  tmp <- file.path(tempdir(), "ro-crate-metadata.json")

  write_rocrate(basic_crate, tmp)

  expect_message(
    crate <- load_rocrate(tmp, verbose = TRUE)
  )

  expect_s3_class(crate, "rocrate")
})

test_that("load_rocrate fails when path does not exist", {
  expect_error(load_rocrate("INVALID PATH"))
})

test_that("load_rocrate handles rocrate", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()

  expect_message(
    crate <- load_rocrate(basic_crate, verbose = TRUE)
  )

  expect_equal(crate, basic_crate)
})

test_that("load_rocrate reads RO-Crate bag", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()

  # create temporary directory
  tmp_dir <- file.path(
    tempdir(),
    paste0("rocrate-tests-", digest::digest(runif(1)))
  )
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  # write RO-Crate to temporary file
  tmp_file <- file.path(tmp_dir, "ro-crate-metadata.json")

  # check that the temporary file doesn't exist
  expect_false(file.exists(tmp_file))

  # write to temporary file
  basic_crate |>
    rocrateR::write_rocrate(path = tmp_file)

  # check that the temporary file exists
  expect_true(file.exists(tmp_file))

  # try to bag RO-Crate overwriting previous one
  expect_message(
    expect_warning(
      rocrate_bag_filename <- basic_crate |>
        rocrateR::bag_rocrate(path = tmp_dir, overwrite = TRUE)
    )
  )

  # check that the RO-Crate bag exists
  expect_true(file.exists(rocrate_bag_filename))

  # check that the created object is a valid RO-Crate bag
  expect_message(
    crate <- rocrateR::load_rocrate(rocrate_bag_filename, verbose = TRUE)
  )

  expect_equal(crate, basic_crate)

  # unbag RO-Crate bag
  root_to_rocrate_bag <- unbag_rocrate(rocrate_bag_filename)
  expect_message(
    crate_v2 <- rocrateR::load_rocrate(root_to_rocrate_bag, verbose = TRUE)
  )
  expect_equal(crate_v2, basic_crate)

  # skip RO-Crate bag root and call within the data/ directory
  expect_message(
    crate_v3 <- rocrateR::load_rocrate(
      file.path(root_to_rocrate_bag, "data"),
      verbose = TRUE
    )
  )
  expect_equal(crate_v3, basic_crate)

  # call with the wrong input file
  expect_error(rocrateR::load_rocrate(file.path(
    root_to_rocrate_bag,
    "bag-info.txt"
  )))

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("validate_rocrate returns validation object", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()

  tmp <- file.path(tempdir(), "ro-crate-metadata.json")

  write_rocrate(basic_crate, tmp)

  result <- validate_rocrate(tmp, mode = "report", strict = TRUE)

  expect_s3_class(result, "rocrate_validation")
  expect_true(length(result$error) == 0)

  result <- validate_rocrate(tmp, mode = "stop", strict = TRUE)

  expect_s3_class(result, "rocrate_validation")
  expect_true(length(result$error) == 0)
})

test_that("validate_rocrate errors when passing invalid object", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate() |>
    rocrateR::remove_entity("./")

  result <- validate_rocrate(basic_crate, mode = "report", strict = TRUE)

  expect_s3_class(result, "rocrate_validation")
  expect_false(length(result$error) == 0)

  expect_error(
    validate_rocrate(basic_crate, mode = "stop", strict = TRUE)
  )
})
