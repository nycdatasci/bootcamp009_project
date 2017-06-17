import luigi
import pandas as pd
import os
import pickle

class Train(luigi.Task):

    def requires(self):
        yield DataPreProcessing()
        yield PipelineCreation()

    def run(self):
        #Need to implement actual training of model here
        #prices_model = train_model_ridge(pandas.read_csv(DataPreProcessing().output().path))
        with open(self.output().path, 'wb') as f:
            pickle.dump(prices_model, f)
        request = Request('http://127.0.0.1:5000/loadModels/')
        try:
            print "Reloading models"
            response = urlopen(request)
        except URLError, e:
            "No Russian Housing Prices Prediction API", e



    def output(self):
        return luigi.LocalTarget("/tmp/russian_housing_model.pkl")


class PipelineCreation(luigi.Task):

    def requires(self):
        return {'a':EstimatorCreation(), 'b':ParameterGrid()}

    def output(self):
        return luigi.LocalTarget("/tmp/russian_housing_pipeline.pkl")

    def run(self):
        estimators = pd.read_pickle(self.input()['a'].path)

        parameter_grid = pd.read_pickle(self.input()['b'].path)

        pipeline = make_pipeline(estimators)

        grid_search = GridSearchCV(estimator = pipeline, param_grid = parameter_grid)

        with self.output().open('w') as out_f:
            out_f.to_pickle(grid_search)

class EstimatorCreation(luigi.Task):

    def output(self):
        return luigi.LocalTarget("/tmp/russian_housing_estimators.pkl")

    def run(self):
        #add estimators to list below as needed
        estimators = [('xgb',xgb.XGBClassifier())]
        pd.to_pickle(estimators, self.output().path)

class ParameterGrid(luigi.Task):

    def output(self):
        return luigi.LocalTarget("/tmp/russian_housing_parameter_grid.pkl")

    def run(self):
        parameter_grid = dict(xgb__learning_rate=[0.05, 0.10, 0.15],
                              xgb__max_depth=[3,5,7],
                              xgb__subsample=[1.0],
                              xgb__colsample_bytree=[0.7],
                              xgb__objective=['reg:linear'],
                              xgb__silent=[True]
                              )
        pd.to_pickle(parameter_grid, self.output().path)



    
