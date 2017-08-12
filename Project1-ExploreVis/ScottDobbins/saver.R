# @author Scott Dobbins
# @version 0.9.8
# @date 2017-08-11 23:30


### Save Data ---------------------------------------------------------------

debug_message("writing WW1")
fwrite(x = WW1_bombs,  file = WW1_bombs_filepath,  quote = TRUE, nThread = cores)
fwrite(x = WW1_clean,  file = WW1_clean_filepath,  quote = TRUE, nThread = cores)
fwrite(x = WW1_unique, file = WW1_unique_filepath, quote = TRUE, nThread = cores)

debug_message("writing WW2")
fwrite(x = WW2_bombs,  file = WW2_bombs_filepath,  quote = TRUE, nThread = cores)
fwrite(x = WW2_clean,  file = WW2_clean_filepath,  quote = TRUE, nThread = cores)
fwrite(x = WW2_unique, file = WW2_unique_filepath, quote = TRUE, nThread = cores)

debug_message("writing Korea")
fwrite(x = Korea_bombs2,  file = Korea_bombs2_filepath,  quote = TRUE, nThread = cores)
fwrite(x = Korea_clean2,  file = Korea_clean2_filepath,  quote = TRUE, nThread = cores)
fwrite(x = Korea_unique2, file = Korea_unique2_filepath, quote = TRUE, nThread = cores)

debug_message("writing Vietnam")
fwrite(x = Vietnam_bombs,  file = Vietnam_bombs_filepath,  quote = TRUE, nThread = cores)
fwrite(x = Vietnam_clean,  file = Vietnam_clean_filepath,  quote = TRUE, nThread = cores)
fwrite(x = Vietnam_unique, file = Vietnam_unique_filepath, quote = TRUE, nThread = cores)

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
