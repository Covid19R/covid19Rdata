refresh_data <- function(one_dataset) {
  # get what we need to fetch the dataset
  data_set_name <- one_dataset$data_set_name
  package_name <- one_dataset$package_name

  current_time <- lubridate::now()

  # build the call
  run <- glue::glue("{package_name}::refresh_{data_set_name}()")

  dat <- try(eval(parse(text = run)))

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
    
    suppress
    packages <- readr::read_csv("data/packages.csv")

    username <- packages %>%
      dplyr::filter(
        package == package_name
      ) %>%
      dplyr::slice(1) %>%
      dplyr::pull(username)

    issue_creator_usernames <- c("aedobbyn", "jebyrnes", "RamiKrispin")
    
    # If running locally, use GitHub PAT which is used when .token is null
    if (!exists("token")) token <- NULL

    # Create GitHub issue
    gh::gh(
      glue::glue("POST /repos/{username}/{package_name}/issues"),
      username = sample(issue_creator_usernames, 1),
      title = "Change in source data: some column names missing",
      body = glue::glue("The following names were missing in the {current_time} refresh of {one_dataset$package_name}:\n\n```{missing}```") %>%
        as.character(),
      .token = token
    )
    
    error <- glue::glue("Missing cols: {missing}")
  }

  if (sum(class(dat) == "try-error") == 0) {
    
    if (!exists("error")) error <- dat[1]
    
    current_time <- lubridate::now() %>% as.character() %>% snakecase::to_snake_case()
    
    out <- 
      tibble::tibble(
        package_name = package_name,
        data_set_name = data_set_name,
        refresh_status = "Failed",
        last_data_update = NA,
        last_refresh_update = lubridate::now(),
        error = error
      )
    
    readr::write_csv(
      out, 
      glue::glue("./logs/error_log_{current_time}.csv"), 
      append = TRUE
    )
    
    return(out)
  }

  # write the dataset if there is no error
  # and return that everything worked. Otherwise
  # return the error
  readr::write_csv(dat, glue::glue("./data/{data_set_name}.csv"))

  tibble::tibble(
    package_name = package_name,
    data_set_name = data_set_name,
    refresh_status = "Passed",
    last_data_update = max(dat$date),
    last_refresh_update = lubridate::now(),
    error = NA
  )
}
