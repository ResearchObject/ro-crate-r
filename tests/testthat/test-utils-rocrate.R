test_that("add_author adds person", {
  crate <- rocrateR::rocrate()

  crate <- rocrateR::add_author(
    crate,
    name = "Test User",
    orcid = "0000-0001-5036-8661",
    affiliation = "Test Org"
  )

  person <- rocrateR::get_entity(crate, type = "Person")[[1]]

  expect_equal(person$name, "Test User")
})

test_that("affiliation ROR works", {
  crate <- rocrateR::rocrate()

  crate <- rocrateR::add_author(
    crate,
    name = "Alice Smith",
    affiliation = "University X",
    ror = "https://ror.org/03yrm5c26"
  )

  org <- rocrateR::get_entity(
    crate,
    id = "https://ror.org/03yrm5c26"
  )[[1]]

  expect_equal(org$name, "University X")
})


test_that("add_dataset adds File and Dataset entities", {
  crate <- rocrateR::rocrate()

  crate <- rocrateR::add_dataset(
    crate,
    iris,
    file_id = "iris.csv",
    name = "Iris dataset"
  )

  file_ent <- rocrateR::get_entity(crate, id = "iris.csv")[[1]]
  dataset_ent <- rocrateR::get_entity(
    crate,
    id = "#dataset-iris",
    type = "Dataset"
  )[[1]]

  expect_equal(file_ent$encodingFormat, "text/csv")
  expect_true(!is.null(file_ent$content))

  expect_equal(dataset_ent$name, "Iris dataset")

  # missing file_id
  expect_error(rocrateR::add_dataset(crate, iris))
})

test_that("add_notebook works", {
  crate <- rocrateR::rocrate()

  crate <- rocrateR::add_notebook(
    crate,
    "analysis.Rmd"
  )

  ent <- rocrateR::get_entity(crate, id = "analysis.Rmd")[[1]]

  expect_equal(ent$encodingFormat, "text/markdown")
})

test_that("add_project works", {
  crate <- rocrateR::rocrate()

  crate <- rocrateR::add_project(
    crate,
    "My cool research"
  )

  ent <- rocrateR::get_entity(crate, id = "#project-my_cool_research")[[1]]

  expect_equal(ent$name, "My cool research")
})

test_that("add_notebook works", {
  crate <- rocrateR::rocrate()

  crate <- rocrateR::add_notebook(
    crate,
    "analysis.Rmd"
  )

  ent <- rocrateR::get_entity(crate, id = "analysis.Rmd")[[1]]

  expect_equal(ent$encodingFormat, "text/markdown")
})

test_that("add_readme works", {
  crate <- rocrateR::rocrate() |>
    rocrateR::add_readme(text = c("# rocrateR"))

  readme_ent <- rocrateR::get_entity(crate, id = "README.md")[[1]]

  expect_equal(readme_ent$name, "README.md")
  expect_equal(length(readme_ent$content), 1)
})

test_that("add_software works", {
  crate <- rocrateR::rocrate() |>
    rocrateR::add_software("R", version = R.version.string)

  soft_ent <- rocrateR::get_entity(crate, id = "#software-r")[[1]]

  expect_equal(soft_ent$name, "R")
  expect_equal(soft_ent$version, R.version.string)
})

test_that("add_workflow adds workflow entities", {
  crate <- rocrateR::rocrate()

  crate <- rocrateR::add_workflow(
    crate,
    "analysis.R",
    content = c("print('hello')")
  )

  wf <- rocrateR::get_entity(crate, type = "ComputationalWorkflow")[[1]]
  file <- rocrateR::get_entity(crate, id = "analysis.R")[[1]]

  expect_equal(wf$hasPart[[1]]$`@id`, "analysis.R")
  expect_true(!is.null(file$content))

  # missing file_id
  expect_error(rocrateR::add_workflow(crate))
})

test_that("workflow records language", {
  crate <- rocrateR::rocrate() |>
    rocrateR::add_workflow(
      "analysis.R",
      language = "R"
    )

  lang <- rocrateR::get_entity(crate, type = "ComputerLanguage")[[1]]

  expect_equal(lang$name, "R")
})

test_that("crate_project scans directory", {
  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  writeLines("print('hello')", file.path(tmp_dir, "script.R"))
  writeLines("# rocrateR", file.path(tmp_dir, "markdown.Rmd"))
  writeLines("rocrateR", file.path(tmp_dir, "text.txt"))
  write.csv(iris, file.path(tmp_dir, "iris.csv"))

  crate <- rocrateR::crate_project(tmp_dir)

  expect_true(!is.null(rocrateR::get_entity(crate, id = "script.R")))
  expect_true(!is.null(rocrateR::get_entity(crate, id = "iris.csv")))
  expect_true(!is.null(rocrateR::get_entity(crate, id = "markdown.Rmd")))
  expect_true(!is.null(rocrateR::get_entity(crate, id = "text.txt")))

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("dataset links to file via hasPart", {
  crate <- rocrateR::rocrate() |>
    rocrateR::add_dataset(
      iris,
      file_id = "iris.csv"
    )

  dataset <- rocrateR::get_entity(
    crate,
    id = "#dataset-iris",
    type = "Dataset"
  )[[1]]

  expect_equal(dataset$hasPart[[1]]$`@id`, "iris.csv")
})

test_that("extract_content writes dataset files", {
  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  # dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  crate <- rocrateR::rocrate() |>
    rocrateR::add_dataset(
      iris,
      file_id = "iris.csv"
    ) |>
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

  rocrateR::extract_content(crate, tmp_dir)

  expect_true(file.exists(file.path(tmp_dir, "iris.csv")))

  # extract_content fails if missing path
  expect_error(extract_content(crate))

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("extract_content respects overwrite flag", {
  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  crate <- rocrateR::rocrate() |>
    rocrateR::add_dataset(
      iris,
      file_id = "iris.csv"
    )

  rocrateR::extract_content(crate, tmp_dir)

  size1 <- file.info(file.path(tmp_dir, "iris.csv"))$size

  rocrateR::extract_content(crate, tmp_dir, overwrite = FALSE)

  size2 <- file.info(file.path(tmp_dir, "iris.csv"))$size

  expect_equal(size1, size2)

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

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
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
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

  result <- validate_rocrate(
    basic_crate,
    mode = "report",
    strict = TRUE
  )

  expect_s3_class(result, "rocrate_validation")
  expect_true(length(result$errors) > 0)

  expect_error(
    validate_rocrate(
      basic_crate,
      mode = "stop",
      strict = TRUE
    )
  )
})

test_that("load_content loads CSV into entity content", {
  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  utils::write.csv(iris, file.path(tmp_dir, "iris.csv"), row.names = FALSE)

  crate <- rocrateR::rocrate() |>
    rocrateR::add_entity(
      rocrateR::entity(
        "iris.csv",
        type = "File",
        encodingFormat = "text/csv"
      )
    )

  crate <- rocrateR:::.load_content(crate, tmp_dir, max_file_size = 10 * 1024^2)

  file_ent <- rocrateR::get_entity(crate, id = "iris.csv")[[1]]

  expect_true(!is.null(file_ent$content))

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})

test_that("load_rocrate loads external content", {
  # create temporary directory
  tmp_dir <- file.path(tempdir(), .create_rocrate_id("rocrate_tests-"))
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

  utils::write.csv(iris, file.path(tmp_dir, "iris.csv"), row.names = FALSE)

  crate <- rocrateR::rocrate() |>
    rocrateR::add_entity(
      rocrateR::entity(
        "iris.csv",
        type = "File",
        encodingFormat = "text/csv"
      )
    )

  rocrateR::write_rocrate(crate, file.path(tmp_dir, "ro-crate-metadata.json"))

  crate2 <- rocrateR::load_rocrate(tmp_dir, load_content = TRUE)

  file_ent <- rocrateR::get_entity(crate2, id = "iris.csv")[[1]]

  expect_true(!is.null(file_ent$content))

  # delete temporary directory
  unlink(tmp_dir, recursive = TRUE, force = TRUE)

  # check if the temporary directory was successfully deleted
  expect_false(dir.exists(tmp_dir))
})
