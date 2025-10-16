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
  expect_error(rocrate_bag_filename <- basic_crate |> 
                   rocrateR::bag_rocrate(path = tmp_dir, 
                                         overwrite = TRUE,
                                         force_bag = TRUE))
  
  # try to bag RO-Crate overwriting previous one
  expect_warning(rocrate_bag_filename <- basic_crate |> 
      rocrateR::bag_rocrate(path = tmp_dir, overwrite = TRUE))
  
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
  unlink(dirname(tmp_dir), recursive = TRUE, force = TRUE)
  
  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})
