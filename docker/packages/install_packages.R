# installing package imports packages
pkg_list <- c("dplyr",
              "tibble",
              "devtools",
              "fs",
              "gh",
              "glue",
              "here",
              "lubridate",
              "magrittr",
              "purrr",
              "readr",
              "snakecase",
              "stringr",
              "tibble",
              "rmarkdown",
              "shiny",
              "tidyr",
              "testthat",
              "usethis")

install.packages(pkgs = pkg_list, repos = "https://cran.rstudio.com/")

for(i in pkg_list){
  
  if(!i %in% rownames(installed.packages())){
    stop(paste("Package", i, "is not available"))
  }
}
