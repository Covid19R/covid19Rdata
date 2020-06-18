get_package_info <- function(pkg, verbose = TRUE) {

  if (verbose) {
    message(
      glue::glue("Getting info for {pkg}\n")
    )
  }
  
  # make the call for the package
  run <- glue::glue("{pkg}::get_info_{pkg}()")

  try(eval(parse(text = run)))
}
