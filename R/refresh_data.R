refresh_data <- function(one_dataset) {
  # get what we need to fetch the dataset
  data_set_name <- one_dataset$data_set_name
  package_name <- one_dataset$package_name
  
  current_time <- lubridate::now()

  # build the call
  runme <- glue("{package_name}::refresh_{data_set_name}()")

  # get the dataset
  dat <- try(eval(parse(text = runme)))

  #### NOTE - this testing bit needs to be worked out - currently
  #### just make sure there isn't a try-error
  # Test the data sets (testhat?) for standard conditions.
  # column names
  # controlled vocabulary
  # others?
  # If it fails, file an issue/email package author if not already done.
  # Note as failing. Do not update data. Output to error log

  # Otherwise, if it succeeds, overwrite the data with refreshed data, mark it as passing,
  # and provide the current date as the last date updated. Note version of package used.
  
  missing_col_names <- col_names_standard[-which(col_names_standard %in% names(dat))]

  if (length(missing_col_names) > 0) {
    missing <- 
      missing_col_names %>% 
      stringr::str_c(collapse = "\n") 
    
    username <- packages %>% 
      filter(
        package == package_name
      ) %>% 
      slice(1) %>% 
      pull(username)
    
    issue_creator_usernames <- c("aedobbyn", "jebyrnes", "RamiKrispin")
    
    # Create GitHub issue
    gh::gh(
      glue::glue("POST /repos/{username}/{package_name}/issues"), 
      username = "aedobbyn", 
      title = "Change in source data: some column names missing", 
      body = glue::glue("The following names were missing in the {current_time} refresh of {one_dataset$package_name}:\n\n```{missing}```") %>% 
        as.character()
    )
  }

  # write the dataset if there is no error
  # and return that everything worked. Otherwise
  # return the error
  if (sum(class(dat) == "try-error") == 0) {
    write_csv(dat, glue("./data/{data_set_name}.csv"))
    return(tibble(
      package_name = package_name,
      data_set_name = data_set_name,
      refresh_status = "Passed",
      last_update = max(dat$date),
      error = NA
    ))
  } else {
    return(tibble(
      package_name = package_name,
      data_set_name = data_set_name,
      refresh_status = "Failed",
      last_update = NA,
      error = dat[1]
    ))
  }
}
