# setup
basic_crate <- rocrateR::rocrate()

# create entity for an organisation
organisation_uol <- rocrateR::entity(
  "https://ror.org/04xs57h96",
  type = "Organization",
  name = "University of Liverpool",
  url = "http://www.liv.ac.uk"
)

# create an entity for a person
person_rvd <- rocrateR::entity(
  "https://orcid.org/0000-0001-5036-8661",
  type = "Person",
  name = "Roberto Villegas-Diaz",
  affiliation = list(`@id` = organisation_uol$`@id`)
)

basic_crate_v2 <- basic_crate |>
  rocrateR::add_entity(person_rvd) |>
  rocrateR::add_entity_value(
    id = "./",
    key = "author",
    value = list(`@id` = person_rvd$`@id`)
  ) |>
  rocrateR::add_entity(organisation_uol)

test_that("entity works", {
  # valid entity
  expect_equal(
    rocrateR::entity(
      "https://orcid.org/0000-0001-5036-8661",
      type = "Person",
      name = "Roberto Villegas-Diaz",
      affiliation = list(`@id` = organisation_uol$`@id`)
    ),
    person_rvd
  )

  # invalid entity, missing type
  expect_error({
    rocrateR::entity(
      "https://orcid.org/0000-0001-5036-8661",
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
  expect_message({
    basic_crate |>
      rocrateR::add_entity(person_rvd, verbose = TRUE) |>
      rocrateR::add_entity(person_rvd, overwrite = TRUE, verbose = TRUE)
  })
})

test_that("add_entity_value works", {
  expect_equal(
    basic_crate |>
      rocrateR::add_entity(person_rvd) |>
      rocrateR::add_entity_value(
        id = "./",
        key = "author",
        value = list(`@id` = person_rvd$`@id`)
      ) |>
      rocrateR::add_entity(organisation_uol),
    basic_crate_v2
  )

  # pass invalid @id value
  expect_error({
    basic_crate |>
      rocrateR::add_entity_value(
        id = ".",
        key = "author",
        value = list(`@id` = person_rvd$`@id`)
      )
  })

  # duplicated entity value
  expect_error(
    basic_crate |>
      rocrateR::add_entity(person_rvd) |>
      rocrateR::add_entity_value(
        id = "./",
        key = "author",
        value = list(`@id` = person_rvd$`@id`)
      ) |>
      rocrateR::add_entity_value(
        id = "./",
        key = "author",
        value = list(`@id` = person_rvd$`@id`)
      ) |>
      rocrateR::add_entity(organisation_uol)
  )

  # duplicated entity value, with overwrite = TRUE
  expect_message(
    basic_crate |>
      rocrateR::add_entity(person_rvd) |>
      rocrateR::add_entity_value(
        id = "./",
        key = "author",
        value = list(`@id` = person_rvd$`@id`)
      ) |>
      rocrateR::add_entity_value(
        id = "./",
        key = "author",
        value = list(`@id` = person_rvd$`@id`),
        overwrite = TRUE,
        verbose = TRUE
      ) |>
      rocrateR::add_entity(organisation_uol)
  )
})

test_that("add_entities is deprecated", {
  crate <- rocrate()
  ent <- entity("a", "File")

  expect_warning(
    add_entities(crate, list(ent)),
    "deprecated"
  )
})

test_that("get_entity works", {
  # call without `id` and `type`
  expect_error(rocrateR::get_entity(basic_crate))

  # call with invalid `id`
  expect_warning(rocrateR::get_entity(basic_crate, id = "cool_id"))

  # call with invalid `type`
  expect_warning(rocrateR::get_entity(basic_crate, type = "cool_type"))

  # call with valid `id`
  res_val_id <- rocrateR::get_entity(basic_crate, id = "./")
  expect_equal(length(res_val_id), 1)
  expect_equal(class(res_val_id[[1]]), c("entity", "list"))

  # call with valid `type`
  res_val_type <- rocrateR::get_entity(basic_crate, type = "Dataset")
  expect_equal(length(res_val_type), 1)
  expect_equal(class(res_val_type[[1]]), c("entity", "list"))

  # call with valid `id` and `type`
  res_val_id_type <- rocrateR::get_entity(
    basic_crate,
    id = "./",
    type = "Dataset"
  )
  expect_equal(length(res_val_id_type), 1)
  expect_equal(class(res_val_id_type[[1]]), c("entity", "list"))

  # call with `entity` object
  res_val_entity <- basic_crate |>
    rocrateR::get_entity(rocrateR::entity("./", type = "Dataset"))
  expect_equal(length(res_val_entity), 1)
  expect_equal(class(res_val_entity[[1]]), c("entity", "list"))

  # add multiple entities
  basic_crate_v3 <- basic_crate_v2 |>
    rocrateR::add_entity(rocrateR::entity(id = "1234", type = "Person"))

  res_mult_ent <- basic_crate_v3 |>
    rocrateR::get_entity(type = "Person")
  expect_equal(length(res_mult_ent), 2)

  # mismatching size of `id` and `type`
  expect_error(
    basic_crate_v3 |>
      rocrateR::get_entity(id = 1:2, type = rep("Person", 3))
  )

  # recycle id
  expect_warning(
    res_mult_ent_v2 <- basic_crate_v3 |>
      rocrateR::get_entity(id = 0, type = c("Person", "Dataset"))
  )
  expect_equal(length(res_mult_ent_v2), 0)

  # recycle type
  expect_warning(
    res_mult_ent_v3 <- basic_crate_v3 |>
      rocrateR::get_entity(id = 1:3, type = "Person")
  )
  expect_equal(length(res_mult_ent_v3), 0)
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

test_that("remove_entities is deprecated", {
  expect_warning(
    basic_crate |>
      rocrateR::add_entity(person_rvd) |>
      rocrateR::remove_entities(list("https://orcid.org/0000-0001-5036-8661")),
    "deprecated"
  )
})
