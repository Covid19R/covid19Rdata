get_package_info <- function(a_package){
  
  #make the call for the package
  runme <- glue("{a_package}::get_info_{a_package}()")
  
  new_info <- try(eval(parse(text = runme)))
  
  new_info
  
}
