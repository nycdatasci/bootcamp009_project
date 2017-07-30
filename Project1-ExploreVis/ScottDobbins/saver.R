# @author Scott Dobbins
# @version 0.9.7.2
# @date 2017-07-29 20:00


### Save Data ---------------------------------------------------------------

debug_message("writing WW1")
write.csv(x = WW1_bombs,  file = WW1_bombs_filepath,  quote = TRUE)
write.csv(x = WW1_clean,  file = WW1_clean_filepath,  quote = TRUE)
write.csv(x = WW1_unique, file = WW1_unique_filepath, quote = TRUE)

debug_message("writing WW2")
write.csv(x = WW2_bombs,  file = WW2_bombs_filepath,  quote = TRUE)
write.csv(x = WW2_clean,  file = WW2_clean_filepath,  quote = TRUE)
write.csv(x = WW2_unique, file = WW2_unique_filepath, quote = TRUE)

debug_message("writing Korea")
write.csv(x = Korea_bombs2,  file = Korea_bombs2_filepath,  quote = TRUE)
write.csv(x = Korea_clean2,  file = Korea_clean2_filepath,  quote = TRUE)
write.csv(x = Korea_unique2, file = Korea_unique2_filepath, quote = TRUE)

debug_message("writing Vietnam")
write.csv(x = Vietnam_bombs,  file = Vietnam_bombs_filepath,  quote = TRUE)
write.csv(x = Vietnam_clean,  file = Vietnam_clean_filepath,  quote = TRUE)
write.csv(x = Vietnam_unique, file = Vietnam_unique_filepath, quote = TRUE)

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
