# @author Scott Dobbins
# @version 0.9.8
# @date 2017-08-11 23:30


debug_message("downsampling")
downsampled <- FALSE

if (nrow(WW1_unique) > downsample_size) {
  downsampled <- TRUE
  WW1_original <- data.table(WW1_unique)
  WW1_unique <- sample_n(tbl = WW1_unique, size = downsample_size, replace = FALSE)
}
if (nrow(WW2_unique) > downsample_size) {
  downsampled <- TRUE
  WW2_original <- data.table(WW2_unique)
  WW2_unique <- sample_n(tbl = WW2_unique, size = downsample_size, replace = FALSE)
}
if (nrow(Korea_unique2) > downsample_size) {
  downsampled <- TRUE
  Korea_original2 <- data.table(Korea_unique2)
  Korea_unique2 <- sample_n(tbl = Korea_unique2, size = downsample_size, replace = FALSE)
}
if (nrow(Vietnam_unique) > downsample_size) {
  downsampled <- TRUE
  Vietnam_original <- data.table(Vietnam_unique)
  Vietnam_unique <- sample_n(tbl = Vietnam_unique, size = downsample_size, replace = FALSE)
}
