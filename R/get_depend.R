# Required covid19 packages
get_depend <- function(verbose = TRUE){
  
  arg <- NULL
  
  if(verbose) {
    message("Installing the supporting packages")
  }
  
  packages_list <- utils::read.csv("https://raw.githubusercontent.com/Covid19R/covid19Rdata/master/data-raw/packages.csv", 
                                   stringsAsFactors = FALSE) 
  args <-paste(packages_list$username, packages_list$package, sep = "/")
  
  for (a in args) {
    devtools::install_github(a, upgrade = "never")
    if(verbose){
      message(paste(a, "was installed", sep = " "))
    }
  }
  return(message("Done.."))  
}
