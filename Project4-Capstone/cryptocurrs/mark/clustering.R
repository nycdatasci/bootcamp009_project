#1
protein = read.table('[08] Protein.txt', sep = "\t", header = T)
protein.scaled = as.data.frame(scale(protein[,-1]))
rownames(protein.scaled) = protein$Country

#2
#A function to help determine the number of clusters when we do not have an
#idea ahead of time.
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

#Visualizing the scree plot for the scaled iris data; 3 seems like a plausible
#choice.
wssplot(protein.scaled, 22)

# I'm not sure why suggests kmeans is not appropriate to model this data. Perhaps because there is
# no drastic drop off in the within-cluster variance suggesting that the data is perhaps uniformly
# distributed. 

#3
kmeans_sols = list()
set.seed(0)
for (i in 1:5) {
    kmeans_sols[i] = kmeans(protein.scaled, centers = 2, iter.max = 1, nstart = 100)
}

#4 Create and store 1 kmeans solutions solution that was created by running the algorithm 100 times
kmeans_100[i] = kmeans(protein.scaled, centers = 2, iter.max = 100, nstart = 100)

#5

plot(protein$Cereals, protein$RedMeat)








##########################################################################################################
# Hierarchical Clustering

#1
# Calculate pairwise distances
d = dist(protein.scaled)

#2
#Using the hclust() function, we define the linkage manner by which we will
#cluster our data.
fit.single = hclust(d, method = "single")
fit.complete = hclust(d, method = "complete")
fit.average = hclust(d, method = "average")

#3 Dendograms
par(mfrow = c(1, 3))
plot(fit.single, hang = -1, main = "Dendrogram of Single Linkage")
plot(fit.complete, hang = -1, main = "Dendrogram of Complete Linkage")
plot(fit.average, hang = -1, main = "Dendrogram of Average Linkage")

# It's hard to explain exactly why single linkage (minimal distance between clusters) would be poor in this
# case although it appears that way. It appears like it just keeps grabbing the closest pair. It's fairly
# sequential 1 -> 2 -> 4 -> 8 ...., instead of building bigger clusters on the way up. Complete linkage(maximal)
# seems to be more natural in building up the clusters. 

#4
clusters.complete2 = cutree(fit.complete, k = 2)
#Visualizing the groups in the dendrogram.
par(mfrow = c(1, 1))
plot(fit.complete, hang = -1, main = "Dendrogram of Average Linkage\n5 Clusters")
rect.hclust(fit.complete, k = 2)

#5
clusters.complete2 = cutree(fit.complete, k = 5)
#Visualizing the groups in the dendrogram.
par(mfrow = c(1, 1))
plot(fit.complete, hang = -1, main = "Dendrogram of Average Linkage\n5 Clusters")
rect.hclust(fit.complete, k = 5)
