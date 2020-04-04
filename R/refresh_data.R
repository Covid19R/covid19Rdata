refresh_data <- function(one_dataset){
  #get what we need to fetch the dataset
  data_set_name <- one_dataset$data_set_name
  package_name <- one_dataset$package_name
  
  #build the call
  runme <- glue("{package_name}::refresh_{data_set_name}()")
  
  #get the dataset
  dat <- try(eval(parse(text = runme)))
  
  #write the dataset if there is no error
  #and return that everything worked. Otherwise
  #return the error
  if(sum(class(dat) == "try-error")==0){
    write_csv(dat, glue("./data/{data_set_name}.csv"))
    return(tibble(data_set_name = data_set_name, 
                  refresh_states = "Passed", 
                  last_update = max(dat$date),
                  msg=NA))
  }else{
    return(tibble(data_set_name = data_set_name, 
                  refresh_states = "Failed",
                  last_update = NA,
                  msg = dat[1]))
    
  }
  
}