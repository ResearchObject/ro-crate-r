test_that("read_rocrate and write_rocrate works", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()

  # write RO-Crate to temporary file
  tmp_file <- tempfile(fileext = ".json")

  # check that the temporary file doesn't exist
  expect_false(file.exists(tmp_file))

  # write to temporary file
  basic_crate |>
    rocrateR::write_rocrate(path = tmp_file)

  # check that the temporary file exists
  expect_true(file.exists(tmp_file))

  # read RO-crate from the temporary file
  new_ro_crate <- rocrateR::read_rocrate(tmp_file)

  # compare the original RO-Crate to the loaded from the temporary file
  expect_equal(new_ro_crate, basic_crate)

  # delete temporary file
  unlink(tmp_file, force = TRUE)

  # verify that the temporary file was deleted
  expect_false(file.exists(tmp_file))
})
