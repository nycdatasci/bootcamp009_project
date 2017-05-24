# @author Scott Dobbins
# @date 2017-05-24 18:30
# @version 0.6.3


### import libraries ###
library(ggplot2)

### global constants ###
dpi <- 120
image_width <- 1024
image_height <- 768
scale_factor <- 4
scale_down <- 1/(dpi * scale_factor)
cols <- c("log_price_per_log_fullsq.mean", "log_price_per_log_fullsq.sd", "sqrt_kremlin_km.mean", "invest_prop")

raions_wikipedia <- fread('data/raion_Wikipedia.csv')

setkey(raions, sub_area)
setkey(raions_wikipedia, Raion)
raions_extra <- raions[raions_wikipedia]

raions_extra_norm <- raions_extra
raions_extra_norm <- raions_extra_norm[, (cols) := 
                                       list((log_price_per_log_fullsq.mean - mean(log_price_per_log_fullsq.mean, na.rm = TRUE)) / sd(log_price_per_log_fullsq.mean, na.rm = TRUE), 
                                            (log_price_per_log_fullsq.sd - mean(log_price_per_log_fullsq.sd, na.rm = TRUE)) / sd(log_price_per_log_fullsq.sd, na.rm = TRUE), 
                                            (sqrt(kremlin_km.mean) - mean(sqrt(kremlin_km.mean), na.rm = TRUE)) / sd(sqrt(kremlin_km.mean), na.rm = TRUE), 
                                            (invest_prop - mean(invest_prop, na.rm = TRUE)) / sd(invest_prop, na.rm = TRUE))]

raions_clusters_average <- hclust(dist(raions_extra_norm[, (cols), with = FALSE]), method = 'average')
raions_clusters_complete <- hclust(dist(raions_extra_norm[, (cols), with = FALSE]), method = 'complete')
raions_clusters_single <- hclust(dist(raions_extra_norm[, (cols), with = FALSE]), method = 'single')

num_clusters <- c(1,2,4,6,8,12,16,20,24,32,40,48,64)

raions_cluster_average_cut <- list()
raions_cluster_complete_cut <- list()
raions_cluster_single_cut <- list()

for(num in num_clusters) {
  this_tree <- cutree(raions_clusters_average, num)
  raions_cluster_average_cut[[length(raions_cluster_average_cut) + 1]] <- this_tree
  
  ggplot(data = raions_extra, mapping = aes(x = log_price_per_log_fullsq.mean, y = log_price_per_log_fullsq.sd, size = count, col = factor(this_tree))) + geom_point() + theme_bw() + scale_color_brewer(palette = "Set3", name = "Cluster #") + xlab("Mean of log(price)/log(fullsq)") + ylab("Stdev of log(price)/log(fullsq)") + ggtitle(paste0("Raion Clustering - average, ", toString(num), " cuts")) + theme(plot.title = element_text(hjust = 0.5))
  ggsave(filename = paste0('images/raions_cluster_average1_cut', toString(num), '.png'), width = (image_width / dpi), height = (image_height / dpi), dpi = dpi)
  ggplot(data = raions_extra, mapping = aes(x = sqrt_kremlin_km.mean, y = invest_prop, size = count, col = factor(this_tree))) + geom_point() + theme_bw() + scale_color_brewer(palette = "Set3", name = "Cluster #") + xlab("Mean of sqrt of Kremlin distance (km)") + ylab("Proportion of units owned as Investments") + ggtitle(paste0("Raion Clustering - average, ", toString(num), " cuts")) + theme(plot.title = element_text(hjust = 0.5))
  ggsave(filename = paste0('images/raions_cluster_average2_cut', toString(num), '.png'), width = (image_width * scale_down), height = (image_height * scale_down), scale = scale_factor)
  
  this_tree <- cutree(raions_clusters_complete, num)
  raions_cluster_complete_cut[[length(raions_cluster_complete_cut) + 1]] <- this_tree
  ggplot(data = raions_extra, mapping = aes(x = log_price_per_log_fullsq.mean, y = log_price_per_log_fullsq.sd, size = count, col = factor(this_tree))) + geom_point() + theme_bw() + scale_color_brewer(palette = "Set3", name = "Cluster #") + xlab("Mean of log(price)/log(fullsq)") + ylab("Stdev of log(price)/log(fullsq)") + ggtitle(paste0("Raion Clustering - complete, ", toString(num), " cuts")) + theme(plot.title = element_text(hjust = 0.5))
  ggsave(filename = paste0('images/raions_cluster_complete1_cut', toString(num), '.png'), width = (image_width * scale_down), height = (image_height * scale_down), scale = scale_factor)
  ggplot(data = raions_extra, mapping = aes(x = sqrt_kremlin_km.mean, y = invest_prop, size = count, col = factor(this_tree))) + geom_point() + theme_bw() + scale_color_brewer(palette = "Set3", name = "Cluster #") + xlab("Mean of sqrt of Kremlin distance (km)") + ylab("Proportion of units owned as Investments") + ggtitle(paste0("Raion Clustering - complete, ", toString(num), " cuts")) + theme(plot.title = element_text(hjust = 0.5))
  ggsave(filename = paste0('images/raions_cluster_complete2_cut', toString(num), '.png'), width = (image_width * scale_down), height = (image_height * scale_down), scale = scale_factor)
  
  this_tree <- cutree(raions_clusters_single, num)
  raions_cluster_single_cut[[length(raions_cluster_single_cut) + 1]] <- this_tree
  ggplot(data = raions_extra, mapping = aes(x = log_price_per_log_fullsq.mean, y = log_price_per_log_fullsq.sd, size = count, col = factor(this_tree))) + geom_point() + theme_bw() + scale_color_brewer(palette = "Set3", name = "Cluster #") + xlab("Mean of log(price)/log(fullsq)") + ylab("Stdev of log(price)/log(fullsq)") + ggtitle(paste0("Raion Clustering - single, ", toString(num), " cuts")) + theme(plot.title = element_text(hjust = 0.5))
  ggsave(filename = paste0('images/raions_cluster_single1_cut', toString(num), '.png'), width = (image_width * scale_down), height = (image_height * scale_down), scale = scale_factor)
  ggplot(data = raions_extra, mapping = aes(x = sqrt_kremlin_km.mean, y = invest_prop, size = count, col = factor(this_tree))) + geom_point() + theme_bw() + scale_color_brewer(palette = "Set3", name = "Cluster #") + xlab("Mean of sqrt of Kremlin distance (km)") + ylab("Proportion of units owned as Investments") + ggtitle(paste0("Raion Clustering - single, ", toString(num), " cuts")) + theme(plot.title = element_text(hjust = 0.5))
  ggsave(filename = paste0('images/raions_cluster_single2_cut', toString(num), '.png'), width = (image_width * scale_down), height = (image_height * scale_down), scale = scale_factor)
}

