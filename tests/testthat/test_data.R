test_that(desc = "Test the columns names", {
  
  col_names_std <- covid19Rdata:::col_names_standard
  
  expect_equal(length(col_names_std) == 7, TRUE)
  expect_equal(all(c("date", "location", "location_type", "location_code", "location_code_type", "data_type", "value") %in% col_names_std), TRUE)
})


test_that(desc = "Test the packages list", {
  
packages <- readr::read_csv(
  "https://raw.githubusercontent.com/Covid19R/covid19Rdata/master/data-raw/packages.csv",
  col_types = "cc"
)
expect_equal(nrow(packages) == 7, TRUE)
expect_equal(ncol(packages) == 2, TRUE)


})