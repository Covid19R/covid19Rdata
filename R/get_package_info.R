get_package_info <- function(pkg, verbose = TRUE) {

  if (verbose) {
    cat("Getting info for", pkg, "\n")
  }
  
  # make the call for the package
  run <- sprintf("%s::get_info_%s()", pkg, pkg)

  try(eval(parse(text = run)))
}
