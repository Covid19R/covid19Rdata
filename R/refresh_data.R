refresh_data <- function(one_dataset) {
  # get what we need to fetch the dataset
  data_set_name <- one_dataset$data_set_name
  package_name <- one_dataset$package_name

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
