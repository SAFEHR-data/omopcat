get_bundles <- function() {
  ## Always use the latest version
  bundles <- omopbundles::available_bundles(version = "latest")

  ## Sanity checks
  stopifnot(is.data.frame(bundles))
  stopifnot("Bundles are empty" = nrow(bundles) > 0)
  stopifnot(
    "omopbundles::available_bundles() data.frame doesn't have the expected names" =
      c("id", "concept_name", "domain", "version") %in% names(bundles)
  )
  bundles
}

get_concepts_by_bundle <- function(...) {
  concepts <- omopbundles::concept_by_bundle(...)

  ## Sanity checks
  stopifnot(is.data.frame(concepts))
  stopifnot(
    "omopbundles::concept_by_bundle() data.frame doesn't have the expected names" =
      c("concept_id", "domain") %in% names(concepts)
  )
  concepts
}
