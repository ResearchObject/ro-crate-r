test_that("new_rocrate_validation constructs object correctly", {
  res <- new_rocrate_validation(
    errors = c("e1", "e2"),
    warnings = "w1",
    info = "i1"
  )

  expect_s3_class(res, "rocrate_validation")

  expect_equal(res$errors, c("e1", "e2"))
  expect_equal(res$warnings, "w1")
  expect_equal(res$info, "i1")
})

test_that("validation passes when crate satisfies RO-Crate 1.2 profile", {
  root <- list(
    "@id" = "./",
    "@type" = "Dataset",
    conformsTo = "https://w3id.org/ro/crate/1.2"
  )

  local_mocked_bindings(
    .get_root_entity = function(x) root,
    .get_entity_ids = function(x) c("./", "ro-crate-metadata.json")
  )

  profile <- .rocrate_profiles[["https://w3id.org/ro/crate/1.2"]]

  errors <- .validate_against_profile(list(), profile)

  expect_length(errors, 0)
})

test_that("error raised when root type missing", {
  root <- list(
    "@id" = "./",
    conformsTo = "https://w3id.org/ro/crate/1.2"
  )

  local_mocked_bindings(
    .get_root_entity = function(x) root,
    .get_entity_ids = function(x) c("./", "ro-crate-metadata.json")
  )

  profile <- .rocrate_profiles[["https://w3id.org/ro/crate/1.2"]]

  errors <- .validate_against_profile(list(), profile)

  expect_true(any(grepl("Root entity must have", errors)))
})

test_that("error raised when required entity missing", {
  root <- list(
    "@id" = "./",
    "@type" = "Dataset",
    conformsTo = "https://w3id.org/ro/crate/1.2"
  )

  local_mocked_bindings(
    .get_root_entity = function(x) root,
    .get_entity_ids = function(x) c("./") # missing metadata file
  )

  profile <- .rocrate_profiles[["https://w3id.org/ro/crate/1.2"]]

  errors <- .validate_against_profile(list(), profile)

  expect_true(any(grepl("Missing required entity", errors)))
})

test_that("error raised when root property missing", {
  root <- list(
    "@id" = "./",
    "@type" = "Dataset"
  )

  local_mocked_bindings(
    .get_root_entity = function(x) root,
    .get_entity_ids = function(x) c("./", "ro-crate-metadata.json")
  )

  profile <- .rocrate_profiles[["https://w3id.org/ro/crate/1.2"]]

  errors <- .validate_against_profile(list(), profile)

  expect_true(any(grepl("missing required property", errors)))
})

test_that("5S profile requires license property", {
  root <- list(
    "@id" = "./",
    "@type" = "Dataset",
    conformsTo = "https://w3id.org/5s-crate/0.4"
  )

  local_mocked_bindings(
    .get_root_entity = function(x) root,
    .get_entity_ids = function(x) c("./", "ro-crate-metadata.json")
  )

  profile <- .rocrate_profiles[["https://w3id.org/5s-crate/0.4"]]

  errors <- .validate_against_profile(list(), profile)

  expect_true(any(grepl("license", errors)))
})

test_that("no validation occurs when root is NULL", {
  local_mocked_bindings(
    .get_root_entity = function(x) NULL,
    .get_entity_ids = function(x) character()
  )

  profile <- .rocrate_profiles[["https://w3id.org/ro/crate/1.2"]]

  errors <- .validate_against_profile(list(), profile)

  expect_length(errors, 0)
})
