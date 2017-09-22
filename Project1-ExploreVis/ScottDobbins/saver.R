# @author Scott Dobbins
# @version 0.9.8.3
# @date 2017-08-24 22:30


### Save Data ---------------------------------------------------------------

debug_message("saving cleaned bomb data")
for (war_data_tag in war_data_tags) {
  fwrite(bomb_data[[war_data_tag]], 
         file = war_bombs_filepath[[war_data_tag]], 
         quote = TRUE)
}

debug_message("saving processed clean data")
for (war_data_tag in war_data_tags) {
  fwrite(clean_data[[war_data_tag]], 
         file = war_clean_filepath[[war_data_tag]], 
         quote = TRUE)
}

debug_message("saving unique targets data")
for (war_data_tag in war_data_tags) {
  fwrite(unique_data[[war_data_tag]], 
         file = war_unique_filepath[[war_data_tag]], 
         quote = TRUE)
}

debug_message("saving workspace")
save.image(file = paste0(save_path, Sys.Date(), save_extension))


### Sample and Resave -------------------------------------------------------

if (downsample) {
  source('downsampler.R')
  
  if (downsampled) {
    debug_message("saving workspace with downsamples")
    save.image(file = paste0(save_path_downsampled, Sys.Date(), save_extension))
  }
}
