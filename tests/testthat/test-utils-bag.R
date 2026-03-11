test_that("bag_rocrate works", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()

  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
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
  expect_warning(
    # warning because overwrite = TRUE
    rocrate_bag_filename <- basic_crate |>
      rocrateR::bag_rocrate(
        path = tmp_dir,
        overwrite = TRUE,
        force_bag = TRUE
      )
  )
  # check that the RO-Crate bag exists
  expect_true(file.exists(rocrate_bag_filename))

  # delete intermediate RO-Crate bag
  unlink(rocrate_bag_filename, force = TRUE)

  # delete RO-Crate metadata descriptor file
  unlink(
    file.path(dirname(rocrate_bag_filename), "ro-crate-metadata.json"),
    force = TRUE
  )

  # attempt bagging empty directory
  expect_error(
    dirname(rocrate_bag_filename) |>
      rocrateR::bag_rocrate(overwrite = TRUE, force_bag = FALSE)
  )

  # try to bag RO-Crate overwriting previous one
  rocrate_bag_filename <- basic_crate |>
    rocrateR::bag_rocrate(path = tmp_dir, overwrite = TRUE)

  # check that the RO-Crate bag exists
  expect_true(file.exists(rocrate_bag_filename))

  # check contents of RO-Crate bag
  ## unzip the new RO-Crate bag
  unzip(rocrate_bag_filename, exdir = file.path(tmp_dir, "..", "VALIDATION"))
  ## list files in the RO-Crate bag
  rocrate_bag_files <- list.files(
    file.path(tmp_dir, "..", "VALIDATION"),
    recursive = TRUE
  )
  ## subset files in the data/ directory
  rocrate_bag_files <-
    basename(rocrate_bag_files[grepl("data/", rocrate_bag_files)])
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

  # delete temporary directory used for validation
  unlink(
    file.path(dirname(tmp_dir), "VALIDATION"),
    recursive = TRUE,
    force = TRUE
  )
  expect_false(dir.exists(file.path(dirname(tmp_dir), "VALIDATION")))
})

test_that("bag_rocrate writes dataset files", {
  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  crate <- rocrateR::rocrate() |>
    rocrateR::add_dataset(
      file_id = "iris.csv",
      data = iris
    )

  roc_bag_path <- rocrateR::bag_rocrate(
    crate,
    path = tmp_dir,
    write_content = TRUE
  )

  roc_bag_contents_root <- rocrateR::unbag_rocrate(roc_bag_path)

  roc_bag_contents <- list.files(roc_bag_contents_root)

  expect_true("iris.csv" %in% roc_bag_contents)
  expect_true("bagit.txt" %in% roc_bag_contents)

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("is_rocrate_bag works", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()

  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  # missing path
  expect_error(rocrateR::is_rocrate_bag())

  # invalid path
  expect_warning(
    expect_false(
      rocrateR::is_rocrate_bag("/invalid/path")
    )
  )

  # path to empty directory
  expect_warning(
    expect_false(
      rocrateR::is_rocrate_bag(tmp_dir)
    )
  )

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
    expect_warning(
      rocrate_bag_filename <- basic_crate |>
        rocrateR::bag_rocrate(path = tmp_dir, overwrite = TRUE)
    )
  )

  # check that the RO-Crate bag exists
  expect_true(file.exists(rocrate_bag_filename))

  # check that the created object is a valid RO-Crate bag
  expect_true(
    rocrateR::is_rocrate_bag(rocrate_bag_filename)
  )

  # extract RO-Crate bag
  expect_message(
    rocrate_bag_contents <- rocrateR::unbag_rocrate(rocrate_bag_filename)
  )
  # delete the tagmanifest file and validate RO-Crate bag
  expect_true(file.exists(file.path(
    rocrate_bag_contents,
    "tagmanifest-sha512.txt"
  )))
  unlink(file.path(rocrate_bag_contents, "tagmanifest-sha512.txt"))
  expect_false(file.exists(file.path(
    rocrate_bag_contents,
    "tagmanifest-sha512.txt"
  )))
  expect_true(
    rocrateR::is_rocrate_bag(rocrate_bag_contents)
  )

  # create invalid bag for testing purposes
  dir.create(
    file.path(tmp_dir, "INVALID/data"),
    recursive = TRUE,
    showWarnings = FALSE
  )
  # create skeleton with empty files
  idx <- file.path(
    tmp_dir,
    "INVALID",
    c("bagit.txt", "manifest-sha512.txt", "tagmanifest-sha512.txt")
  ) |>
    file.create(showWarnings = FALSE)
  # create data dir
  dir.create(
    file.path(tmp_dir, "INVALID/data"),
    showWarnings = FALSE,
    recursive = TRUE
  )
  idx <- file.path(tmp_dir, "INVALID/data/ro-crate-metadata.json") |>
    file.create(showWarnings = FALSE)
  # populate invalid manifest and tagmanifest files
  writeLines(
    "1234 data/ro-crate-metadata.json",
    file.path(tmp_dir, "INVALID/manifest-sha512.txt")
  )
  writeLines(
    "1234 bagit.txt",
    file.path(tmp_dir, "INVALID/tagmanifest-sha512.txt")
  )
  # check invalid RO-Crate bag
  expect_false(rocrateR::is_rocrate_bag(file.path(tmp_dir, "INVALID")))

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("load_rocrate_bag works", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate() |>
    # add JSON file
    rocrateR::add_entity(
      rocrateR::entity(
        id = "my_json.json",
        type = "File",
        encodingFormat = "application/json",
        content = list('[{"rocrateR":"0.0.2"}]')
      )
    ) |>
    # add text file
    rocrateR::add_entity(
      rocrateR::entity(
        id = "text.txt",
        type = "File",
        encodingFormat = "text/plain",
        content = list('rocrateR v0.0.2')
      )
    )

  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  # missing path
  expect_error(rocrateR::load_rocrate_bag())

  # invalid path
  expect_error(rocrateR::load_rocrate_bag("/invalid/path"))

  # path to empty directory
  expect_error(rocrateR::load_rocrate_bag(tmp_dir))

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

  # extract RO-Crate bag
  rocrate_bag_contents <- rocrateR::load_rocrate_bag(
    rocrate_bag_filename,
    load_content = TRUE
  )

  # compare contents extracted from the bag and the original R object
  expect_equal(rocrate_bag_contents, basic_crate)

  # extract RO-Crate bag without loading the contents from disk, for File ents.
  rocrate_bag_contents_wo_contents <- rocrateR::load_rocrate_bag(
    rocrate_bag_filename,
    load_content = FALSE
  )

  my_json_ent <- rocrateR::get_entity(
    rocrate_bag_contents_wo_contents,
    id = "my_json.json"
  )[[1]]

  # assert that `content` is missing for one of the File entities
  expect_null(getElement(my_json_ent, "content"))

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("unbag_rocrate works", {
  # create basic RO-Crate
  basic_crate <- rocrateR::rocrate()

  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)
  on.exit(unlink(tmp_dir, recursive = TRUE, force = TRUE))

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
    expect_warning(
      rocrate_bag_filename <- basic_crate |>
        rocrateR::bag_rocrate(path = tmp_dir, overwrite = TRUE)
    )
  )

  # check that the RO-Crate bag exists
  expect_true(file.exists(rocrate_bag_filename))

  rocrate_bag_files <- rocrateR::unbag_rocrate(
    rocrate_bag_filename,
    output = tmp_dir
  )

  # delete RO-Crate file
  unlink(rocrate_bag_filename, force = TRUE)
  expect_false(file.exists(rocrate_bag_filename))

  # read RO-Crate metadata descriptor file
  basic_crate_from_bag <- file.path(
    rocrate_bag_files,
    "data/ro-crate-metadata.json"
  ) |>
    rocrateR::read_rocrate()

  # compare with the original RO-Crate
  expect_equal(basic_crate_from_bag, basic_crate)

  # Robustness to extra directories ----
  dir.create(file.path(rocrate_bag_files, "not_a_crate"))

  new_roc_zip_file <- file.path(dirname(rocrate_bag_files), "test_roc2.zip")
  expect_false(file.exists(new_roc_zip_file))

  zip::zip(new_roc_zip_file, rocrate_bag_files, mode = "cherry-pick")
  expect_true(file.exists(new_roc_zip_file))

  tmp_dir_v2 <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir_v2, showWarnings = FALSE, recursive = TRUE)
  on.exit(unlink(tmp_dir_v2, recursive = TRUE, force = TRUE), add = TRUE)

  temp_roc_root <- rocrateR::unbag_rocrate(
    new_roc_zip_file,
    output = tmp_dir_v2
  )

  expect_true(dir.exists(temp_roc_root))
  expect_true(file.exists(file.path(temp_roc_root, "bagit.txt")))
  expect_true(dir.exists(file.path(temp_roc_root, "data")))

  # macOS artefact tolerance (__MACOSX, .DS_Store) ----
  macos_dir <- file.path(rocrate_bag_files, "__MACOSX")
  dir.create(macos_dir)
  file.create(file.path(rocrate_bag_files, ".DS_Store"))

  macos_zip <- file.path(dirname(rocrate_bag_files), "test_macos.zip")
  zip::zip(macos_zip, rocrate_bag_files, mode = "cherry-pick")

  tmp_dir_v3 <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir_v3, showWarnings = FALSE, recursive = TRUE)
  on.exit(unlink(tmp_dir_v3, recursive = TRUE, force = TRUE), add = TRUE)

  macos_root <- rocrateR::unbag_rocrate(
    macos_zip,
    output = tmp_dir_v3
  )

  expect_true(dir.exists(macos_root))
  expect_true(file.exists(file.path(macos_root, "bagit.txt")))

  # delete new zip
  unlink(new_roc_zip_file, force = TRUE)
  expect_false(file.exists(new_roc_zip_file))

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)
  unlink(tmp_dir_v2, recursive = TRUE, force = TRUE)
  unlink(tmp_dir_v3, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
  expect_false(dir.exists(tmp_dir_v2))
  expect_false(dir.exists(tmp_dir_v3))
})

test_that("unbag_rocrate fails on invalid BagIt structure", {
  tmp <- tempfile(fileext = ".zip")
  tmp_dir <- tempfile()
  dir.create(tmp_dir)

  # create fake zip with no bagit structure
  file.create(file.path(tmp_dir, "random.txt"))
  zip::zip(tmp, tmp_dir, mode = "cherry-pick")

  expect_error(
    rocrateR::unbag_rocrate(tmp, output = tempdir())
  )
})

test_that("unbag_rocrate accepts directory input", {
  crate <- rocrateR::rocrate()

  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  suppressWarnings(
    roc_zip <- rocrateR::bag_rocrate(crate, path = tmp_dir, overwrite = TRUE)
  )
  extracted <- rocrateR::unbag_rocrate(roc_zip)

  expect_true(dir.exists(extracted))

  # run again using directory input
  expect_equal(
    rocrateR::unbag_rocrate(roc_zip),
    extracted
  )

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("bag_rocrate can force bag when file copy fails", {
  # create basic RO-Crate
  crate <- rocrateR::rocrate()

  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  f <- file.path(tmp_dir, "test.txt")
  writeLines("hello", f)

  # simulate .copy_file (wrapper for file.copy) failure
  testthat::with_mocked_bindings(
    .copy_file = function(...) FALSE,
    {
      expect_error(
        rocrateR::bag_rocrate(crate, path = tmp_dir)
      )

      expect_warning(
        rocrateR::bag_rocrate(tmp_dir, force_bag = TRUE)
      )
    },
    .package = "rocrateR"
  )

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("bag_rocrate creates output directory when create_dir = TRUE", {
  # create basic RO-Crate
  crate <- rocrateR::rocrate()

  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  out <- file.path(tmp_dir, "output")

  bag_rocrate(
    crate,
    path = tmp_dir,
    output = out,
    overwrite = TRUE,
    create_dir = TRUE
  )

  expect_true(dir.exists(out))

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("unbag_rocrate fails for empty zip", {
  tmp <- tempfile(fileext = ".zip")

  zip::zip(tmp, files = character(0))

  expect_error(
    unbag_rocrate(tmp)
  )
})

test_that("unbag_rocrate rejects archives with only hidden files", {
  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  hidden <- file.path(tmp_dir, "_hidden1")
  writeLines("junk", hidden)

  zip_path <- tempfile(fileext = ".zip")
  suppressWarnings(
    # zip::zip(zip_path, files = hidden)
    zip::zip(zip_path, files = basename(hidden), root = tmp_dir)
  )
  expect_error(unbag_rocrate(zip_path))

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})


test_that("unbag_rocrate rejects archives with only hidden files", {
  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  hidden <- file.path(tmp_dir, ".hidden")
  writeLines("junk", hidden)

  zip_path <- tempfile(fileext = ".zip")

  zip::zip(
    zipfile = zip_path,
    files = ".hidden",
    root = tmp_dir
  )

  expect_error(
    rocrateR::unbag_rocrate(zip_path),
    "No valid files"
  )

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("bag_rocrate generates fetch.txt for remote files", {
  crate <- rocrateR::rocrate()

  crate$`@graph` <- append(
    crate$`@graph`,
    list(list(
      "@id" = "https://example.org/file.txt",
      "@type" = "File"
    ))
  )

  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  bag <- bag_rocrate(crate, path = tmp_dir)

  extracted <- unbag_rocrate(bag)

  expect_true(
    file.exists(file.path(extracted, "fetch.txt"))
  )

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("detect_manifest_algo errors if manifest missing", {
  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  expect_error(
    rocrateR:::.detect_manifest_algo(tmp_dir)
  )

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("detect_manifest_algo errors with multiple manifests", {
  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  file.create(file.path(tmp_dir, "manifest-sha256.txt"))
  file.create(file.path(tmp_dir, "manifest-md5.txt"))

  expect_error(
    rocrateR:::.detect_manifest_algo(tmp_dir)
  )

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})
