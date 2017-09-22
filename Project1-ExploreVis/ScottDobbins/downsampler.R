# @author Scott Dobbins
# @version 0.9.8.3
# @date 2017-08-24 22:30


debug_message("downsampling")
downsampled <- FALSE

if (nrow(WW1_unique) > downsample_size) {
  downsampled <- TRUE
  WW1_original <- copy(WW1_unique)
  WW1_unique <- sample_n(WW1_unique, downsample_size, replace = FALSE)
}
if (nrow(WW2_unique) > downsample_size) {
  downsampled <- TRUE
  WW2_original <- copy(WW2_unique)
  WW2_unique <- sample_n(WW2_unique, downsample_size, replace = FALSE)
}
if (nrow(Korea_unique2) > downsample_size) {
  downsampled <- TRUE
  Korea_original2 <- copy(Korea_unique2)
  Korea_unique2 <- sample_n(Korea_unique2, downsample_size, replace = FALSE)
}
if (nrow(Vietnam_unique) > downsample_size) {
  downsampled <- TRUE
  Vietnam_original <- copy(Vietnam_unique)
  Vietnam_unique <- sample_n(Vietnam_unique, downsample_size, replace = FALSE)
}
