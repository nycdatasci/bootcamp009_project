library(randomForest)
rfcv_custom = function(X, y, ntrees = 500, metric = 'accuracy') {
    if (class(y) != 'factor') {
        return('Error! The predicted column must be a factor')
    }
    if (nrow(X) != length(y)) {
        return('Error! X and y not of the same dimensions')
    }
    max_vars = ncol(X)
    # Should be accuracy or gini
    measure = ifelse(metric == 'gini', 4, 3)
    # Get list of variable names 
    var_names = names(X)
    df = cbind(X,y)
    # Empty list where to store the importances and errors
    result = vector('list', 2)
    result[[2]] = vector('list', max_vars)

    for (i in max_vars:2) {
        print('starting iteration ')
        print(max_vars - i + 1)
        fit = randomForest(y ~ ., data = df[,var_names], importance = TRUE, n.trees = ntrees)
        # Save OOB error
        result[[1]][i] = fit$err.rate[ntrees,1]
        # Save importance plots
        result[[2]][[i]] = importance(fit)
        #print(sort(importance(fit)[,3]))
        var_names = names((sort(importance(fit)[, measure])))
        var_names = var_names[-1]
        #print('new variables are')
        #print(var_names)
    }
    return(result)
}