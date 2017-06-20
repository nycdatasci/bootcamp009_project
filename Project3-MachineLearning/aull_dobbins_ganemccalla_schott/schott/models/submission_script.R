mlr = read.csv('submission_Scott_2017-05-29-2200_33871.csv')
rf = read.csv('rfPrediction_32777.csv')
xgb = read.csv('submission_xgb_33650.csv')
macro = read.csv('old_submissions/WA-RF.csv')

library(scales)
cols <- cut(z, 6, labels = c("pink", "red", "yellow", "blue", "green", "purple"))
plot(x, y, main= "Fragment recruitment plot - FR-HIT", 
     ylab = "Percent identity", xlab = "Base pair position", 
     col = alpha('red', 0.5), pch=16) 

plot(mlr, col = alpha('black',0.1))
points(rf, col = alpha('red',0.1))
points(xgb, col = alpha('green',0.1))

hist(log(mlr$price_doc),breaks = 100,)
hist(log(rf$price_doc),breaks=100)
hist(log(xgb$price_doc),breaks=100)
plot(density(log(mlr$price_doc)))
line(density(log(rf$price_doc)),col='green')

library(sm)
sm.density.compare(mlr$price_doc, rf$price_doc)
plot.multi.dens <- function(s)
{
  junk.x = NULL
  junk.y = NULL
  for(i in 1:length(s)) {
    junk.x = c(junk.x, density(s[[i]])$x)
    junk.y = c(junk.y, density(s[[i]])$y)
  }
  xr <- range(junk.x)
  yr <- range(junk.y)
  plot(density(s[[1]]), xlim = xr, ylim = yr, main = "ln(price) Density Plots")
  for(i in 1:length(s)) {
    lines(density(s[[i]]), xlim = xr, ylim = yr, col = i)
  }
}
# the input of the following function MUST be a numeric list
plot.multi.dens( list(log(mlr$price_doc),log(rf$price_doc), log(xgb$price_doc), log(macro$price_doc)))
plot.multi.dens(list(mlr$price_doc,rf$price_doc,xgb$price_doc,macro$price_doc))
legend("topright", inset=.05, title="Model Type",
       c("RF","XGB","MLR","RF w/ MAC"), fill=c('red','green','black','purple'), horiz=F)
