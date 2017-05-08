
ggplotRegression <- function (fit) {
         
             require(ggplot2)
        
             ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
                 geom_jitter(aes(colour = wine$category)) +
                 stat_smooth(method = "lm", col = "red") +
                 labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                                                                "Intercept =",signif(fit$coef[[1]],5 ),
                                                                " Slope =",signif(fit$coef[[2]], 5),
                                                                " P =",signif(summary(fit)$coef[2,4], 5)))
    }
 ggplotRegression(lm(price ~points, data =wine))

 
 
 
 
 
 
 