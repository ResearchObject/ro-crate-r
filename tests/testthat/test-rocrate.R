test_that("rocrate works", {
  basic_crate <- rocrateR::rocrate()
  expect_contains(class(basic_crate), "rocrate")

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

  # create crate and include additional entities
  basic_crate_2 <- rocrateR::rocrate(person_rvd, organisation_uol)
})

test_that("rocrate_5s works", {
  basic_crate_5s <- rocrateR::rocrate_5s()
  expect_contains(class(basic_crate_5s), "rocrate")
})
