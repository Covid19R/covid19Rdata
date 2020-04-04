#'-----------------------------------------------
#' Master Script to update the datasets
#' for covid19R from multiple different packages
#' 
#'-----------------------------------------------
library(readr)
library(tibble)
library(dplyr)
library(glue)
library(purrr)

# Load the list of packages queried
packages <- read_csv("./data/packages.csv",
                     col_types = "c") %>%
  bind_rows(tibble(package = "dplyr"))

# Start an error log
errors <- tibble(package = character(), 
                 dataset = character(), 
                 error = character())


# Load the past table of datasets and info from previous get_info

# Query each package for info on datasets present using get_info methods
# Where get_package_info returns the results of a try()
data_info <- map(packages$package, get_package_info)
names(data_info) <- packages$package

# If any get_info fails, email the package author/file a github issue if it was not already failing. 
# Add a flag of no info and use past info for the new dataset info table. 
# Add to the error log.
errors_in_getinfo <- map_dbl(data_info, ~sum(class(.) %in% "try-error"))

#add to error log
errors <- imap_dfr(data_info[which(errors_in_getinfo>0)], 
    ~ tibble(package = .y, 
             dataset="",
             error = .x[1])) %>% 
  bind_rows(errors, .)


# If get_info doesn't fail, add it to the new dataset info output table with a flag of 
# get_info passing.
valid_packages <- data_info[-which(errors_in_getinfo>0)] %>%
  bind_rows() %>%
  mutate(get_info_passing = TRUE)

# Check to see if any packages in the old data table have not been queried. Kick out 
# an error if anything is not queried that was there previously into error log.

# With the new dataset table, use the info to refresh_* each dataset from the appropriate 
# package.

# If refresh fails, file an issue/email the package author if it was not already flagged
# as failing. Do not update the data. Do not change the last updated date. 
# Note failure in error log.

# Test the data (testhat?) for standard conditions.
# column names
# controlled vocabulary
# others?
# If it fails, file an issue/email 
# package author if not already done. Note as failing. Do not update data. Output to error log

# Otherwise, if it succeeds, overwrite the data with refreshed data, mark it as passing, 
# and provide the current date as the last date updated. Note version of package used.