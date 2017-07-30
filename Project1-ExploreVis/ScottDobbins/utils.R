# @author Scott Dobbins
# @version 0.9.7.2
# @date 2017-07-29 20:00


debug_message <- function(string) {
  if (debug_mode_on) {
    message(string)
  }
}
