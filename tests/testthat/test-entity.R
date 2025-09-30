# setup
basic_crate <- rocrateR::rocrate()

# create entity for an organisation
organisation_uol <- rocrateR::entity(
  x = "https://ror.org/04xs57h96",
  type = "Organization",
  name = "University of Liverpool",
  url = "http://www.liv.ac.uk"
)

# create an entity for a person
person_rvd <- rocrateR::entity(
  x = "https://orcid.org/0000-0001-5036-8661",
  type = "Person",
  name = "Roberto Villegas-Diaz",
  affiliation = list(`@id` = organisation_uol$`@id`)
)

basic_crate_v2 <- basic_crate |>
  rocrateR::add_entity(person_rvd) |>
  rocrateR::add_entity_value(id = "./", key = "author", value = list(`@id` = person_rvd$`@id`)) |>
  rocrateR::add_entity(organisation_uol)

test_that("entity works", {
  # valid entity
  expect_equal(rocrateR::entity(
    x = "https://orcid.org/0000-0001-5036-8661",
    type = "Person",
    name = "Roberto Villegas-Diaz",
    affiliation = list(`@id` = organisation_uol$`@id`)
  ),
  person_rvd)

  # invalid entity, missing type
  expect_error({
    rocrateR::entity(
      x = "https://orcid.org/0000-0001-5036-8661",
      name = "Roberto Villegas-Diaz",
      affiliation = list(`@id` = organisation_uol$`@id`)
    )
  })
})

test_that("add_entity works", {
  # attempt adding same entity without `overwrite = TRUE`
  expect_error({
    basic_crate |>
      rocrateR::add_entity(person_rvd) |>
      rocrateR::add_entity(person_rvd)
  })

  # set `overwrite = TRUE`
  expect_warning({
    basic_crate |>
      rocrateR::add_entity(person_rvd) |>
      rocrateR::add_entity(person_rvd, overwrite = TRUE)
  })
})

test_that("add_entity_value works", {
  expect_equal(
    basic_crate |>
      rocrateR::add_entity(person_rvd) |>
      rocrateR::add_entity_value(id = "./", key = "author", value = list(`@id` = person_rvd$`@id`)) |>
      rocrateR::add_entity(organisation_uol),
    basic_crate_v2
  )

  # pass invalid @id value
  expect_error({
    basic_crate |>
      rocrateR::add_entity_value(id = ".", key = "author", value = list(`@id` = person_rvd$`@id`))
  })
})

test_that("remove_entity works", {
  # attempt adding and removing the same entity using entity object
  expect_equal(
    basic_crate |>
      rocrateR::add_entity(person_rvd) |>
      rocrateR::remove_entity(person_rvd),
    basic_crate
  )

  # attempt adding and removing the same entity using @id
  expect_equal(
    basic_crate |>
      rocrateR::add_entity(person_rvd) |>
      rocrateR::remove_entity("https://orcid.org/0000-0001-5036-8661"),
    basic_crate
  )

  # attempt removing non-existing entity
  expect_warning({
    basic_crate |>
      rocrateR::remove_entity("https://orcid.org/0000-0001-5036-8661")
  })
})

