#' Retrieve all available bundles
#'
#' This is essentially a wrapper around [`omopbundles::available_bundles()`]
#' to retrieve the available bundles.
#'
#' @param version The version of the OMOP bundles to use. Defaults to `"latest"`.
#'
#' @return A data.frame with the available bundles, containing their `id`, `concept_name`, `domain`
#' and `version`.
#'
#' @keywords internal
all_bundles <- function(version = "latest") {
  ## Always use the latest version
  bundles <- omopbundles::available_bundles(version = version)

  ## Sanity checks
  stopifnot(is.data.frame(bundles))
  stopifnot("Bundles are empty" = nrow(bundles) > 0)
  stopifnot(
    "omopbundles::available_bundles() data.frame doesn't have the expected names" =
      c("id", "concept_name", "domain", "version") %in% names(bundles)
  )
  bundles
}

#' Retrieve concepts for a given bundle
#'
#' This is essentially a wrapper around [`omopbundles::concept_by_bundle()`]
#' to retrieve the concepts belonging to a spcecific bundle, defined by its `id` and `domain`,
#' but returning only the concept IDs as a vector.
#'
#' @param id The id of the bundle to retrieve concepts for.
#' @param domain The domain of the bundle to retrieve concepts for.
#'
#' @return An `integer` vector with the concept IDs.
#'
#' @keywords internal
get_bundle_concepts <- function(id, domain) {
  concepts <- omopbundles::concept_by_bundle(id = id, domain = domain)

  ## Sanity checks
  stopifnot(is.data.frame(concepts))
  stopifnot(
    "omopbundles::concept_by_bundle() data.frame doesn't have the expected names" =
      c("concept_id", "domain") %in% names(concepts)
  )

  ## Make sure concept_id is an integer
  as.integer(concepts$concept_id)
}
