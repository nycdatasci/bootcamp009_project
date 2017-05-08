##############################################
# Geospatial Data Digester Prototyped in R -- 
# A Shiny Project @ NYC Data Science Academy
# 
#
# Chao Shi
# chao.shi.datasci@gmail.com
# 4/23/2017
##############################################



# this helps to format the FIPS or GEOID column in different datasets, before join
fips_fix_dig <- function(vec,wid){
  # format county identifier FIPS to a given number of digits (adding "0" in front when needed)
  formatC(vec, width = wid, format = "d", flag = "0")
}

# reading csv files with fread (from data.table package), with additional lines designed for this map app
readcsv_fips_value <- function(filename, fipscol, valcol, valcolname,...){
  dat <- fread(filename, stringsAsFactors = FALSE,...)
  dat = as.data.frame(dat)
  dat <- dat[,c(fipscol,valcol)]
  dat[,1] <- fips_fix_dig(dat[,1],5)
  names(dat)[-1] = valcolname
  names(dat) <- tolower(names(dat))
  names(dat)[1] = "GEOID"
  return(dat)
}


# Spec
mypallete_spec_11 = c('#9e0142','#d53e4f','#f46d43','#fdae61','#fee08b','#ffffbf','#e6f598','#abdda4','#66c2a5','#3288bd','#5e4fa2')


mypallete_spec_10 = c('#9e0142','#d53e4f','#f46d43','#fdae61','#fee08b','#e6f598','#abdda4','#66c2a5','#3288bd','#5e4fa2')
labels_spec_10    = c('90-100','80-90','70-80','60-70','50-60','40-50','30-40','20-30','10-20','0-10')


# RdBu
mypallete_RdBu_7 = c('#b2182b','#ef8a62','#fddbc7','#f7f7f7','#d1e5f0','#67a9cf','#2166ac')
mypallete_RdBu_11 = c('#67001f','#b2182b','#d6604d','#f4a582','#fddbc7','#f7f7f7','#d1e5f0','#92c5de','#4393c3','#2166ac','#053061')


mypallete_RdBu_10 = c('#67001f','#b2182b','#d6604d','#f4a582','#fddbc7','#d1e5f0','#92c5de','#4393c3','#2166ac','#053061')
labels_RdBu_10    = c('R led by 80-100%', 'R led by 60-80%', 'R led by 40-60%', 'R led by 20-40%', 'R led by 0-20%',
                      'D led by 0-20%', 'D led by 20-40%', 'D led by 40-60%', 'D led by 60-80%', 'D led by 80-100%')

