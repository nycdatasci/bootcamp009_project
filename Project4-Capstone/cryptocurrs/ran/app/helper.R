library(ggplot2)

plot_power <- function(p, N, dmin, threshold){
p = min(max(0.001, p), 0.999)
se = sqrt(p*(1-p)/N)
q = qnorm(1-threshold, sd=se)

x_start = qnorm(0.001, sd=se)
x_end   = max(qnorm(0.999, mean=dmin, sd=se), 0.04)
x = seq(x_start, x_end, length.out = 200)
y = dnorm(x, sd=se)
ndata = data.frame(p=x, y=y)
g <- ggplot()+geom_line(data=ndata, aes(x, y),
                        linetype=2, alpha=0.5)+theme_bw()+
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.title=element_blank())


m = dnorm(0, sd=se)
g <- g + geom_line(aes(x = c(q, q), y=c(0, m)),
                   alpha=0.5, linetype=2, color='orange')



y_ = dnorm(x-dmin, sd=se)
ndata_ = data.frame(x=x, y=y_)
g <- g+ geom_line(data=ndata_, aes(x, y_))


pt__ =  x[x>q]
x__  =  c(q, pt__, x_end, q)
y__  =  c(dnorm(q-dmin, sd=se), dnorm(pt__-dmin, sd=se), 0, 0)
g<- g + geom_polygon(aes(x__, y__, fill=1), fill='blue', alpha=0.2)
        #geom_text(aes(x=q+0.02, y=1, label='Power'), color='red')
print(g)
}



power <- function(p, N, dmin, threshold){
  p = min(max(0.00001, p), 0.99999)
  se = sqrt(p*(1-p)/N)
  q = qnorm(1-threshold, sd=se)
  1- pnorm(q, mean=dmin, sd=se)
}



f <- function(N){
  power(0.2643, N, 0.03, 0.5)
}




s = 100
e = 10000
error=1
while(e-s>1){
  n = round((s+e)/2)
  if( (f(n)-0.8)*(f(e)-0.8)>0){
    e = n
  }else{
    s = n
  }
}
if(f(e)>0.8){
  print(e)
}else{
  print(s)
}

