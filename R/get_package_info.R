get_package_info <- function(pkg) {
  
  # make the call for the package
  run <- glue::glue("{pkg}::get_info_{pkg}()")
  
  try(eval(parse(text = run)))
}
