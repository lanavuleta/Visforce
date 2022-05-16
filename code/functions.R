get_scenario <- function(file) {
  # Function takes the .obs filename
  # Returns the scenario (tx_py)
  # Assumptions: files are named as "location_tx_py_..."
  
  file_info <- str_split(file, "/")[[1]]
  file_info <- str_split(file_info[length(file_info)], "_")[[1]]
 
  scenario <- paste(file_info[2], file_info[3], sep = "_")
  
  return(scenario)
  
}

prepare_df <- function(df, scenario) {
  # Function takes a .obs dataframe and the associated scenario (tx_py)
  # Returns a dataframe:
  #       date | `variable` | scenario
  # yyyy-mm-dd |  variable  | tx_py    
  # Assumptions: .obs data is in daily values
  #            : only basinflow is desired
  
  # Get daily values
  df_daily <- df %>%
    group_by(date = date(datetime)) %>%
    summarise(basinflow = sum(basinflow.1))

  df_daily['scenario'] = scenario
  
  return(df_daily)
  
}

make_csv <- function(dir) {
  # Function takes a directory containing all the .obs files for a class
  # Creates a csv of the desired data:
  #       date | `variable` | t1_p1 | t1_p2 | ...
  # yyyy-mm-dd |  variable  | xxxxx | xxxxx | ...  
  # Assumptions: undesired dates are the first 5 years and last (incomplete) yr
  #            : desired format is as above
  
  files <- list.files(dir, full.names = TRUE)
  
  # data contains a list of dataframes, where each dataframe comes from a .obs
  data <- map(files, readOutputFile, timezone = "etc/GMT-6")
  
  # scenarios contains a list of the scenarios covered (tx_py)
  scenarios <- map(files, get_scenario)
  
  # data_daily contains one dataframe with all of the .obs data, row bound
  data_daily <- map2_df(data, scenarios, prepare_df)
  
  # Remove undesired dates
  data_daily <- data_daily %>%
    filter(date >= as.Date("1965-01-01"), date < as.Date("2006-01-01"))
  
  # Reorganize data to be in the desired format
  data_daily$variable <- names(data_daily)[2] 
  data_daily <- data_daily %>%
    pivot_wider(names_from = scenario, values_from = basinflow)
  
  # Write data to csv file
  file_name <- tail(str_split(dir, "/") %>% .[[1]], n = 1)
  
  write.csv(data_daily, 
            paste("data/clean_data/", file_name, ".csv", sep = ""), 
            row.names = FALSE)
  
}