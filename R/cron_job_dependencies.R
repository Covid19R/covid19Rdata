#' Install Required covid19 Packages
#' @details Install the required packages for the cron job
#' @param verbose if TRUE, will show messages
#' 

install_depend <- function(verbose = TRUE){
  if(verbose) {
    message("Installing the supporting packages")
  }
  args <-
    readr::read_csv("https://raw.githubusercontent.com/Covid19R/covid19Rdata/rami-dev/data-raw/packages.csv", col_types = "cc") %>%
    dplyr::mutate(
      arg = glue::glue("{username}/{package}")
    ) %>%
    dplyr::pull(arg)
  
  for (a in args) {
    devtools::install_github(a)
    if(verbose){
      message(paste(a, "was installed", sep = " "))
    }
  }
 return(message("Done.."))  
}
