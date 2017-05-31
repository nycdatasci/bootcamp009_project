import time
import statsmodels.formula.api as smf
import pandas as pd
import os
import pickle

def custom_out(my_str):
    print '\n{}: {}\n'.format(time.strftime("%Y%m%d-%H%M%S"), my_str)
    return

def forward_selected(data, response):
    remaining = set(data.columns)
    remaining.remove(response)
    selected = []
    current_score, best_new_score = 0.0, 0.0
    while remaining and current_score == best_new_score:
        scores_with_candidates = []
        for candidate in remaining:
            formula = "{} ~ {} + 1".format(response,
                                           ' + '.join(selected + [candidate]))
            score = smf.ols(formula, data).fit().rsquared_adj
            scores_with_candidates.append((score, candidate))
        scores_with_candidates.sort()
        best_new_score, best_candidate = scores_with_candidates.pop()
        if current_score < best_new_score:
            remaining.remove(best_candidate)
            selected.append(best_candidate)
            current_score = best_new_score
    formula = "{} ~ {} + 1".format(response,
                                   ' + '.join(selected))
    model = smf.ols(formula, data).fit()
    return model

def model_in(model_str):
    return str(model_str).lower()

def stacked_model_compute(pred1, pred2):
    #can add more complicated algo later if needed
    return (pred1+pred2)/2

def auto_grid(grid_search, X_train, y_train, model_str):
    grid_search.fit(X_train, y_train)
    custom_out('Best score {}: {}'.format(model_str, grid_search.best_score_))
    custom_out('Best parameters {}: {}'.format(model_str, grid_search.best_params_))
    print '\n All grid results: \n'
    print grid_search.grid_scores_
    print grid_search.best_estimator_
    return grid_search.best_estimator_

if __name__ == '__main__':
    pass