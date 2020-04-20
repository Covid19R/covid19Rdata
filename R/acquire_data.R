#' -----------------------------------------------
#' Master Script to update the datasets
#' for covid19R from multiple different packages
#'
#' -----------------------------------------------
library(readr)
library(tibble)
library(dplyr)
library(glue)
library(purrr)

# load helper functions
source("./R/refresh_data.R")
source("./R/get_package_info.R")

# constants
current_time <- snakecase::to_snake_case(Sys.time() %>% as.character())

# Load the list of packages queried
packages <- read_csv("./data/packages.csv",
  col_types = "c"
)

# Start an error log
errors <- tibble(
  package_name = character(),
  data_set_name = character(),
  error = character()
)


# TODO Check to see if any packages in the old data table are not going to be queried.
# Kick out an error if anything is not queried that was there previously into
# error log.


# Query each package for info on datasets present using get_info methods
# Where get_package_info returns the results of a try()
data_info <- map(packages$package, get_package_info)
names(data_info) <- packages$package

# If any get_info fails, email the package author/file a github issue if it was
# not already failing.
# Add a flag of no info and use past info for the new dataset info table.
# Add to the error log.
errors_in_getinfo <- map_dbl(data_info, ~ sum(class(.) %in% "try-error"))

# add to error log
if (sum(errors_in_getinfo) > 0) {
  errors <- imap_dfr(
    data_info[which(errors_in_getinfo > 0)],
    ~ tibble(
      package_name = .y,
      data_set_name = "",
      error = .x[1]
    )
  ) %>%
    bind_rows(errors, .)
  
  #eleminate from data info
  data_info <- data_info[-which(errors_in_getinfo > 0)] 
}


# If get_info doesn't fail, add it to the new dataset info output table with a flag of
# get_info passing.
valid_packages <- data_info %>%
  bind_rows() %>%
  mutate(get_info_passing = TRUE)

# With the new dataset table, use the info to refresh_* each dataset from the
# appropriate package.
refresh_status <- map_df(transpose(valid_packages), refresh_data)

data_info <- valid_packages %>%
  left_join(refresh_status %>%
    filter(refresh_status == "Passed") %>%
    select(data_set_name, refresh_status, last_update))

# If refresh fails, file an issue/email the package author if it was not already flagged
# as failing. Do not update the data. Do not change the last updated date.
# Note failure in error log.
failed <- refresh_status %>% filter(refresh_status == "Failed")
if (nrow(failed) > 0) {
  errors <- bind_rows(
    errors,
    failed %>% select(package_name, data_set_name, error)
  )
}


# Add old info for failed packages ####
# Load the past table of datasets and info from previous get_info
past_data_info <- read_csv("./data/covid19R_data_info.csv")
if (sum(errors_in_getinfo) > 0) {
  bad_pkg <- names(errors_in_getinfo)

  old_info <- past_data_info %>%
    filter(package_name %in% bad_pkg) %>%
    filter(refresh_status = "Failed")

  data_info <- data_info %>%
    bind_rows(old_info)
}



# Write out data_info table
write_csv(data_info, "./data/covid19R_data_info.csv")

# if needed, write out the error log and notify the maintainer
# maybe use https://rpremraj.github.io/mailR/
if (nrow(errors) > 0) {
  write_csv(errors, glue("./logs/error_log_{current_time}.csv"))
}
