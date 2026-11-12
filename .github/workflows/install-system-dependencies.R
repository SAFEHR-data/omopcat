project <- Sys.getenv("PACKAGE_DIR")

if (!nzchar(project)) {
  stop(
    "PACKAGE_DIR must identify the project whose dependencies should be installed."
  )
}

run_command <- function(command, args) {
  status <- system2(command, args)
  if (status != 0L) {
    quit(save = "no", status = status)
  }
}

run_command("sudo", c("apt-get", "update"))
install.packages("renv")

requirements <- renv::sysreqs(
  project = project,
  source = "lockfile",
  check = FALSE,
  report = FALSE
)
packages <- unlist(
  lapply(requirements, function(requirement) requirement$packages),
  use.names = FALSE
)

# renv 1.3.1 does not map gert's libgit2 requirement on every Ubuntu release.
if ("gert" %in% names(requirements)) {
  packages <- c(packages, "libgit2-dev")
}

packages <- sort(unique(packages))
if (length(packages)) {
  run_command("sudo", c("apt-get", "install", "-y", packages))
}
