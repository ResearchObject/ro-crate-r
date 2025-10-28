test_that("bag_rocrate works", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()
  
  # create temporary directory
  tmp_dir <- file.path(tempdir(), 
                       paste0("rocrate-tests-", digest::digest(Sys.time())))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)
  
  # missing path
  expect_error(rocrateR::bag_rocrate(basic_crate))
  
  # use invalid path
  expect_error(rocrateR::bag_rocrate(basic_crate, path = "/invalid/path"))
  expect_error(rocrateR::bag_rocrate("/invalid/path"))
  
  # write RO-Crate to temporary file
  tmp_file <- file.path(tmp_dir, "ro-crate-metadata.json")
  
  # check that the temporary file doesn't exist
  expect_false(file.exists(tmp_file))
  
  # write to temporary file
  basic_crate |>
    rocrateR::write_rocrate(path = tmp_file)
  
  # check that the temporary file exists
  expect_true(file.exists(tmp_file))
  
  # try to bag RO-Crate without overwriting previous one
  expect_error(rocrateR::bag_rocrate(basic_crate, path = tmp_dir))
  
  # force creation of bag
  expect_warning( # warning because force_bag = TRUE
    expect_warning( # warning because overwrite = TRUE
      rocrate_bag_filename <- basic_crate |>
        rocrateR::bag_rocrate(path = tmp_dir,
                              overwrite = TRUE,
                              force_bag = TRUE)
      )
  )
  # check that the RO-Crate bag exists
  expect_true(file.exists(rocrate_bag_filename))
  
  # delete intermediate RO-Crate bag
  unlink(rocrate_bag_filename, force = TRUE)
  
  # delete RO-Crate metadata descriptor file
  unlink(file.path(dirname(rocrate_bag_filename), "ro-crate-metadata.json"),
         force = TRUE)

  # attempt bagging empty directory
  expect_error(dirname(rocrate_bag_filename) |>
    rocrateR::bag_rocrate(overwrite = TRUE,
                          force_bag = FALSE))
  
  # try to bag RO-Crate overwriting previous one
  rocrate_bag_filename <- basic_crate |> 
      rocrateR::bag_rocrate(path = tmp_dir, overwrite = TRUE)
  
  # check that the RO-Crate bag exists
  expect_true(file.exists(rocrate_bag_filename))
  
  # check contents of RO-Crate bag
  ## unzip the new RO-Crate bag
  unzip(rocrate_bag_filename, exdir = file.path(tmp_dir, "..", "VALIDATION"))
  ## list files in the RO-Crate bag
  rocrate_bag_files <- list.files(file.path(tmp_dir, "..", "VALIDATION"),
                                  recursive = TRUE)
  ## subset files in the data/ directory
  rocrate_bag_files <- 
    basename(rocrate_bag_files[grepl("/data/", rocrate_bag_files)])
  ## list files in the original input directory
  tmp_dir_files <- list.files(tmp_dir, recursive = TRUE)
  ## subset files in the RO-Crate bag, excluding the bag itself
  tmp_dir_files <- 
    tmp_dir_files[!grepl(basename(rocrate_bag_filename), tmp_dir_files)]
  ## compare main contents of the RO-Crate bag
  expect_equal(rocrate_bag_files, tmp_dir_files)
  
  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)
  
  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("is_rocrate_bag works", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()
  
  # create temporary directory
  tmp_dir <- file.path(tempdir(), 
                       paste0("rocrate-tests-", digest::digest(Sys.time())))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)
  
  # missing path
  expect_error(rocrateR::is_rocrate_bag())
  
  # invalid path
  expect_error(rocrateR::is_rocrate_bag("/invalid/path"))
  
  # path to empty directory
  expect_error(rocrateR::is_rocrate_bag(tmp_dir))
  
  # write RO-Crate to temporary file
  tmp_file <- file.path(tmp_dir, "ro-crate-metadata.json")
  
  # check that the temporary file doesn't exist
  expect_false(file.exists(tmp_file))
  
  # write to temporary file
  basic_crate |>
    rocrateR::write_rocrate(path = tmp_file)
  
  # check that the temporary file exists
  expect_true(file.exists(tmp_file))
  
  # try to bag RO-Crate without overwriting previous one
  expect_error(rocrateR::bag_rocrate(basic_crate, path = tmp_dir))
  
  # try to bag RO-Crate overwriting previous one
  expect_message(
    expect_warning(rocrate_bag_filename <- basic_crate |> 
                     rocrateR::bag_rocrate(path = tmp_dir, overwrite = TRUE)
                   )
  )
  
  # check that the RO-Crate bag exists
  expect_true(file.exists(rocrate_bag_filename))
  
  # check that the created object is a valid RO-Crate bag
  expect_message(
    basic_crate_from_bag <- rocrateR::is_rocrate_bag(rocrate_bag_filename)
  )
  
  # compare object read from the bag and original RO-Crate
  expect_equal(basic_crate_from_bag, basic_crate)
  
  # extract RO-Crate bag
  expect_message(
    rocrate_bag_contents <- rocrateR::unbag_rocrate(rocrate_bag_filename)
  )
  # delete the tagmanifest file and validate RO-Crate bag
  expect_true(file.exists(file.path(rocrate_bag_contents, "tagmanifest-sha512.txt")))
  unlink(file.path(rocrate_bag_contents, "tagmanifest-sha512.txt"))
  expect_false(file.exists(file.path(rocrate_bag_contents, "tagmanifest-sha512.txt")))
  expect_message(
    basic_crate_from_bag <- rocrateR::is_rocrate_bag(rocrate_bag_contents)
  )
  
  # create invalid bag for testing purposes
  dir.create(file.path(tmp_dir, "INVALID/data"), recursive = TRUE, 
             showWarnings = FALSE)
  # create skeleton with empty files
  idx <- file.path(tmp_dir, "INVALID", 
            c("bagit.txt", "manifest-sha512.txt", "tagmanifest-sha512.txt")) |>
    file.create(showWarnings = FALSE)
  # create data dir
  dir.create(file.path(tmp_dir, "INVALID/data"), 
             showWarnings = FALSE, 
             recursive = TRUE)
  idx <- file.path(tmp_dir, "INVALID/data/ro-crate-metadata.json") |>
    file.create(showWarnings = FALSE)
  # populate invalid manifest and tagmanifest files
  writeLines("1234 data/ro-crate-metadata.json",
             file.path(tmp_dir, "INVALID/manifest-sha512.txt"))
  writeLines("1234 bagit.txt",
             file.path(tmp_dir, "INVALID/tagmanifest-sha512.txt"))
  # check invalid RO-Crate bag
  expect_error(rocrateR::is_rocrate_bag(file.path(tmp_dir, "INVALID")))
  
  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)
  
  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("unbag_rocrate works", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()
  
  # create temporary directory
  tmp_dir <- file.path(tempdir(), 
                       paste0("rocrate-tests-", digest::digest(Sys.time())))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)
  
  # missing path
  expect_error(rocrateR::unbag_rocrate())
  
  # invalid path
  expect_error(rocrateR::unbag_rocrate("/invalid/path"))
  
  # path to empty directory
  expect_error(rocrateR::unbag_rocrate(tmp_dir))
  
  # write RO-Crate to temporary file
  tmp_file <- file.path(tmp_dir, "ro-crate-metadata.json")
  
  # check that the temporary file doesn't exist
  expect_false(file.exists(tmp_file))
  
  # write to temporary file
  basic_crate |>
    rocrateR::write_rocrate(path = tmp_file)
  
  # check that the temporary file exists
  expect_true(file.exists(tmp_file))
  
  # try to unbag non-zipped file
  expect_error(rocrateR::unbag_rocrate(file.path(tmp_file)))
  
  # try to bag RO-Crate overwriting previous one
  expect_message(
    expect_warning(rocrate_bag_filename <- basic_crate |> 
                     rocrateR::bag_rocrate(path = tmp_dir, overwrite = TRUE)
    )
  )
  
  # check that the RO-Crate bag exists
  expect_true(file.exists(rocrate_bag_filename))
  
  rocrate_bag_files <- rocrateR::unbag_rocrate(rocrate_bag_filename,
                                               output = tmp_dir)
  
  # read RO-Crate metadata descriptor file
  basic_crate_from_bag <- file.path(rocrate_bag_files, 
                                      "data/ro-crate-metadata.json") |>
    rocrateR::read_rocrate()
  
  # compare with the original RO-Crate
  expect_equal(basic_crate_from_bag, basic_crate)
  
  # add new directory in root of RO-Crate
  dir.create(file.path(rocrate_bag_files, "not_a_crate"))
  # create new zip file with the additional directory
  new_roc_zip_file <- file.path(dirname(rocrate_bag_files), "test_roc2.zip")
  expect_false(file.exists(new_roc_zip_file))
  zip(new_roc_zip_file, rocrate_bag_files)
  expect_true(file.exists(new_roc_zip_file))
  expect_error(
    temp_roc_files <- rocrateR::unbag_rocrate(new_roc_zip_file)
  )
  # delete new zip
  unlink(new_roc_zip_file, force = TRUE)
  expect_false(file.exists(new_roc_zip_file))
  
  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)
  
  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})