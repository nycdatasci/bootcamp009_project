##################################################
##################################################
#####[08] Cluster Analysis Homework Solutions#####
##################################################
##################################################



#####################
#####Question #1#####
#####################
#1
protein = read.table("[08] Protein.txt", sep = "\t", header = TRUE)
# Why did we scale the data here?
summary(protein)
protein.scaled = as.data.frame(scale(protein[, -1]))
rownames(protein.scaled) = protein$Country

#2a
wssplot = function(data, nc = 15, seed = 0) {
  wss = (nrow(data) - 1) * sum(apply(data, 2, var))
  for (i in 2:nc) {
    set.seed(seed)
    wss[i] = sum(kmeans(data, centers = i, iter.max = 100, nstart = 100)$withinss)
  }
  plot(1:nc, wss, type = "b",
       xlab = "Number of Clusters",
       ylab = "Within-Cluster Variance",
       main = "Scree Plot for the K-Means Procedure")
}

wssplot(protein.scaled)

#There doesn't appear to be a clear drop-off or elbow within the graph. Thus,
#the K-means algorithm may not be the best choice for clustering this data,
#although it is still worth exploring. Let's choose K = 3 as the percentage
#drop-off at this point appears to slow (there seems to be a reduction on the
#"return on investment" of creating additional clusters at this point).

#3
set.seed(0)
km.protein1 = kmeans(protein.scaled, centers = 3) #Running the K-means procedure
km.protein2 = kmeans(protein.scaled, centers = 3) #5 different times, but with
km.protein3 = kmeans(protein.scaled, centers = 3) #only one convergence of the
km.protein4 = kmeans(protein.scaled, centers = 3) #algorithm each time.
km.protein5 = kmeans(protein.scaled, centers = 3)

#4
set.seed(0)
km.proteinsim = kmeans(protein.scaled, centers = 3, nstart = 100)

#5abcd
par(mfrow = c(2, 3))
plot(protein.scaled$Cereals, protein.scaled$RedMeat, col = km.protein1$cluster,
     xlab = "Cereal Consumption", ylab = "Red Meat Consumption",
     main = paste("Single K-Means Attempt #1\n WCV: ",
                  round(km.protein1$tot.withinss, 4)))
plot(protein.scaled$Cereals, protein.scaled$RedMeat, col = km.protein2$cluster,
     xlab = "Cereal Consumption", ylab = "Red Meat Consumption",
     main = paste("Single K-Means Attempt #2\n WCV: ",
                  round(km.protein2$tot.withinss, 4)))
plot(protein.scaled$Cereals, protein.scaled$RedMeat, col = km.protein3$cluster,
     xlab = "Cereal Consumption", ylab = "Red Meat Consumption",
     main = paste("Single K-Means Attempt #3\n WCV: ",
                  round(km.protein3$tot.withinss, 4)))
plot(protein.scaled$Cereals, protein.scaled$RedMeat, col = km.protein4$cluster,
     xlab = "Cereal Consumption", ylab = "Red Meat Consumption",
     main = paste("Single K-Means Attempt #4\n WCV: ",
                  round(km.protein4$tot.withinss, 4)))
plot(protein.scaled$Cereals, protein.scaled$RedMeat, col = km.protein5$cluster,
     xlab = "Cereal Consumption", ylab = "Red Meat Consumption",
     main = paste("Single K-Means Attempt #5\n WCV: ",
                  round(km.protein5$tot.withinss, 4)))
plot(protein.scaled$Cereals, protein.scaled$RedMeat, col = km.proteinsim$cluster,
     xlab = "Cereal Consumption", ylab = "Red Meat Consumption",
     main = paste("Best K-Means Attempt out of 100\n WCV: ",
                  round(km.proteinsim$tot.withinss, 4)))

#6
par(mfrow = c(1, 1))
plot(protein.scaled$Cereals, protein.scaled$RedMeat, type = "n",
     xlab = "Cereal Consumption", ylab = "Red Meat Consumption",
     main = paste("Best K-Means Attempt out of 100\n WCV: ",
                  round(km.proteinsim$tot.withinss, 4)))
points(km.proteinsim$centers[, 6], km.proteinsim$centers[, 1], pch = 16, col = "blue")
abline(h = 0, lty = 2)
abline(v = 0, lty = 2)
text(protein.scaled$Cereals, protein.scaled$RedMeat,
     labels = rownames(protein.scaled),
     col = km.proteinsim$cluster)

#7
#The best clustering solution manafests in a clear way when inspecting the cereal
#and red meat consumption cross-section. Generally, there appears to be a group
#that consumes cereal at an above average rate, while red meat at a below average
#rate (consisting of countries Albania, USSR, Hungary, Romania, Bulgaria, and
#Yugoslavia). On the flip side, the largest cluster appears to have an above
#average red meat consumption, with a below average cereal consumption (consisting
#of countries like France, UK, Ireland, Switerland, etc.). There is also a smaller
#cluster that falls somewhere closer to the average consumption of both cereal
#and red meat (consisting of countries Greece, Italy, Spain, and Portugal). In
#general, these country groups make sense based on proximity.



#####################
#####Question #2#####
#####################
#1
d = dist(protein.scaled)

#2
library(flexclust)
fit.single = hclust(d, method = "single")
fit.complete = hclust(d, method = "complete")
fit.average = hclust(d, method = "average")

#3ab
par(mfrow = c(1, 3))
plot(fit.single, hang = -1, main = "Dendrogram of Single Linkage")
plot(fit.complete, hang = -1, main = "Dendrogram of Complete Linkage")
plot(fit.average, hang = -1, main = "Dendrogram of Average Linkage")

#There seems to be a bit of chaining depicted in the single linkage solution
#In particular, there seem to be some clusters with few observation memberships;
#the first two cluster splits place single observations in their own clusters
#(Portugal and Spain). We might not want to move forward with the single
#linkage solution. On the other hand, the complete linkage solution seems to have
#a pretty good balance of cluster sizes at various heights of the dendrogram.

#4ab
clusters.complete2 = cutree(fit.complete, k = 2)
clusters.complete2
table(clusters.complete2)

par(mfrow = c(1, 1))
plot(fit.complete, hang = -1, main = "Dendrogram of Complete Linkage\n2 Clusters")
rect.hclust(fit.complete, k = 2)

aggregate(protein.scaled, by = list(cluster = clusters.complete2), median)

#The 2-cluster solution of the complete linkage dendrogram creates a cluster that
#has 8 members and a cluster that has 17 members. The smaller cluster consists
#of countries Portugal, Spain, Greece, Italy, Albania, Bulgaria, Romania, and
#Yugoslavia. The median consumption of this cluster appears to be particularly
#low in white meat, eggs, milk, and starch; in contrast, the median consumption
#of this cluster appears to be particularly high in cereals, nuts, fruits, and
#vegetables. The larger cluster consists of the remaining countries; the median
#consumption of this cluster is in the opposite direction of the highlights
#listed for the smaller cluster.

#5ab
clusters.complete5 = cutree(fit.complete, k = 5)
clusters.complete5
table(clusters.complete5)

par(mfrow = c(1, 1))
plot(fit.complete, hang = -1, main = "Dendrogram of Complete Linkage\n5 Clusters")
rect.hclust(fit.complete, k = 5)

aggregate(protein.scaled, by = list(cluster = clusters.complete5), median)

#The 5-cluster solution of the complete linkage dendrogram creates clusters that
#have between 2 and 8 members each. The smallest cluster consists of just Portugal
#and Spain and has a particualrly low median consumption of red meat, white meat,
#and milk, but particularly high median consumption of fish, starch, nuts, fruits,
#and vegetables. The second smallest cluster consists of Finland, Norway, Denmark,
#and Sweden. This cluster has the highest median consumption of milk, the second
#largest median consumption of fish, but particularly low consumption of nuts
#fruits, and vegetables. The next smallest cluster consists of Hungary, USSR,
#Poland, Czech., and East Germany. This cluster is particularly denoted by its
#high median consumption of white meat and starch. The largest cluster is home
#to the countries France, UK, Ireland, Belgium, West Germany, Switzerland,
#Austria, and the Netherlands. These countries have the particular characteristic
#of the highest median consumption of red meat and eggs. The second largest cluster
#contains Greece, Italy, Albania, Bulgaria, Romania, and Yugoslavia. This cluster
#is denoted by their lowest median consumption of eggs, fish, and starch, but
#the highest median consumption of cereals and nuts.