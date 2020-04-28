# Required covid19 packages
args <-
  readr::read_csv("data-raw/packages.csv", col_types = "cc") %>%
  dplyr::mutate(
    arg = glue::glue("{username}/{package}")
  ) %>%
  dplyr::pull(arg)

for (a in 1:nrow(args)) {
  devtools::install_github(a)
}
