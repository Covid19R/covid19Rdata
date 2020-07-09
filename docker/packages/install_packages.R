# installing package imports packages
pkg_list <- c("dplyr",
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
              "usethis")

install.packages(pkgs = pkg_list, repos = "https://cran.rstudio.com/")