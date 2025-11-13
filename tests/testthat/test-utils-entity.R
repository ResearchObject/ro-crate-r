test_that(".validate_entity works", {
  # create entity with numeric @id
  expect_no_failure({
    rocrateR::entity(
      x = 123456,
      type = "Dataset"
    )
  })

  # create RO-Crate with entity missing @type
  incomplete_entity <- list(`@id` = 123456)
  expect_warning(rocrateR::rocrate(incomplete_entity))
})
