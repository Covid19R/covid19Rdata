#' Get newest data from all packages and log any errors
#'
#' Uses \code{/data-raw/packages.csv} CSV to try the package's \code{get_info} function as well as its \code{refresh} function to get the most up to date data.
#'
#' @param verbose Should messages be logged?
#'
#' @return New data in the \code{data} dir.
#' @export
#'
#' @examples
#' \donttest{
#' acquire_data
#' }
acquire_data <- function(verbose = TRUE) {
  
  current_time <- lubridate::now() %>%
    as.character() %>%
    snakecase::to_snake_case()
  
  # Load the list of packages queried
  packages <- readr::read_csv(
    "data-raw/packages.csv",
    col_types = "cc"
  )
  
  if (verbose) {
    message(
      glue::glue("Refreshing packages:\n\n{packages$package %>% stringr::str_c(collapse = '\n')}")
    )
  }
  
  # Query each package for info on datasets present using get_info methods
  # Where get_package_info returns the results of a try()
  data_info <- purrr::map(packages$package, get_package_info)
  names(data_info) <- packages$package
  
  # If any get_info fails, email the package author/file a github issue if it was
  # not already failing.
  # Add a flag of no info and use past info for the new dataset info table.
  # Add to the error log.
  errors_in_getinfo <- purrr::map_dbl(data_info, ~ sum(class(.) %in% "try-error"))
  
  # add to error log
  if (sum(errors_in_getinfo) > 0) {
    errors <- purrr::imap_dfr(
      data_info[which(errors_in_getinfo > 0)],
      ~ dplyr::tibble(
        package_name = .y,
        data_set_name = "",
        error = .x[1],
        timestamp = lubridate::now()
      )
    ) %>%
      dplyr::bind_rows(errors, .)
    
    # eleminate from data info
    data_info <- data_info[-which(errors_in_getinfo > 0)]
  }
  
  # If get_info doesn't fail, add it to the new dataset info output table with a flag of
  # get_info passing.
  valid_packages <- data_info %>%
    dplyr::bind_rows() %>%
    dplyr::mutate(get_info_passing = TRUE)
  
  # With the new dataset table, use the info to refresh_* each dataset from the
  # appropriate package.
  refresh_status <- purrr::map_df(
    purrr::transpose(valid_packages), 
    refresh_data, 
    verbose = verbose
  )
  
  data_info <- valid_packages %>%
    dplyr::left_join(
      refresh_status %>%
        dplyr::filter(refresh_status == "Passed") %>%
        dplyr::select(data_set_name, refresh_status, last_refresh_update)
    )
  
  # If refresh fails, file an issue/email the package author if it was not already flagged
  # as failing. Do not update the data. Do not change the last updated date.
  # Note failure in error log.
  failed <- refresh_status %>%
    dplyr::filter(refresh_status == "Failed")
  
  if (nrow(failed) > 0) {
    errors <- dplyr::bind_rows(
      errors,
      failed %>%
        dplyr::select(package_name, data_set_name, error)
    )
    
    if (verbose) {
      message(
        glue::glue("Error refreshing the following packages:\n\n{errors$package_name %>% stringr::str_c(collapse = '\n')}")
      )
    }
    
    readr::write_csv(
      errors,
      glue::glue("./logs/error_log_{current_time}.csv"),
      append = TRUE
    )
  } else {
    if (verbose) {
      message("Successfully refreshed all packages.")
    }
  }
  
  # Add old info for failed packages ####
  # Load the past table of datasets and info from previous get_info
  past_data_info <- readr::read_csv("data-raw/covid19R_data_info.csv")
  
  if (sum(errors_in_getinfo) > 0) {
    bad_pkg <- names(errors_in_getinfo)
    
    old_info <- past_data_info %>%
      dplyr::filter(package_name %in% bad_pkg) %>%
      dplyr::filter(refresh_status = "Failed")
    
    data_info <- data_info %>%
      dplyr::bind_rows(old_info)
  }
  
  # Write out data_info table
  info_fl <- "data-raw/covid19R_data_info.csv"
  if (!fs::file_exists(info_fl)) fs::file_create(info_fl)
  
  readr::write_csv(data_info, info_fl)
}
