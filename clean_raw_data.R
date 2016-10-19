library(tidyverse)
library(stringr)
#Data is organized as 1 folder per station. Within each station folder
#is an 1. observation file, 2. a description of the depths, and 3. description of the 
#station site 
#1: stationid/stationid_readings.txt
#2: stationid/stationid_depths.txt
#3: stationid/stationid_stations.txt
#
#Iterate thru each file and concatonate all data into 3 files representing the above.

raw_data_dir='~/data/atm_analysis_project/soil_moisture_data/'
cleaned_data_dir='~/data/atm_analysis_project/'

readings=data.frame()
depths=data.frame()
stations=data.frame()

for(this_station_folder in list.dirs(raw_data_dir)[-1]){
  this_station_depths_file = paste0(this_station_folder,'/',basename(this_station_folder),'_depths.txt')
  depths=depths %>%
    bind_rows(read.csv(this_station_depths_file, sep='\t',
              colClasses=c('BulkDensity'='character',
                           'SHC'='character')))
  
  
  this_station_stations_file = paste0(this_station_folder,'/',basename(this_station_folder),'_stations.txt')
  stations=stations %>%
    bind_rows(read.csv(this_station_stations_file, sep='\t'))
  
  this_station_readings_file = paste0(this_station_folder,'/',basename(this_station_folder),'_readings.txt')
  #Readings file requires a little cleaning, and sometimes doesn't exist.
  #Remove nulls and make a new column for depth and moisture for 1 observation/line
  if(file.exists(this_station_readings_file)){
    tidy_format_data=read.csv(this_station_readings_file, sep='\t') %>%
      gather(depth, moisture, -stationID,-Y,-M,-D,-DOY) %>%
      filter(moisture != (-9999)) %>%
      mutate(depth = as.integer(word(depth, 2, 2, '_')))
    
    readings = readings %>%
      bind_rows(tidy_format_data)
  }

}

write.csv(readings, paste0(cleaned_data_dir,'readings.csv'), row.names = F)
write.csv(depths, paste0(cleaned_data_dir,'depths.csv'), row.names = F)
write.csv(stations, paste0(cleaned_data_dir,'stations.csv'), row.names = F)

