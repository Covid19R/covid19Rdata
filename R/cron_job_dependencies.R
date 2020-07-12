#' Install Required covid19 Packages
#' @details Install the required packages for the cron job
#' @param verbose if TRUE, will show messages
#' 

install_depend <- function(verbose = TRUE){
  if(verbose) {
    message("Installing the supporting packages")
  }
  args <-
    utils::read.csv("https://raw.githubusercontent.com/Covid19R/covid19Rdata/master/data-raw/packages.csv", stringsAsFactors = FALSE) %>%
    dplyr::mutate(
      arg = sprintf("%s/%s", username, package)
    ) %>%
    dplyr::pull(arg)
  for (a in args) {
    devtools::install_github(a, upgrade = "never")
    if(verbose){
      message(paste(a, "was installed", sep = " "))
    }
  }
 return(message("Done.."))  
}
