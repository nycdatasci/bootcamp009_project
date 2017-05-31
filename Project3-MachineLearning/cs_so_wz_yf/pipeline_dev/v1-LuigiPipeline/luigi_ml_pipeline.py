import luigi
import pandas as pd
import os, sys
import pickle
from urllib2 import Request,urlopen,URLError
import time
from internal_helper_luigi import *
from external_helper_luigi import custom_out, model_in, stacked_model_compute
import xgboost as xgb

class TrainDataPreProcessing(luigi.Task):

    def output(self):
        return luigi.LocalTarget("/tmp/train_clean_out.csv")

    def run(self):
        custom_out('TrainDataPreProcessing Node initiated')
        #train_df = pd.read_csv(os.path.join(os.getcwd(), "data", "train_clean.csv"))
        train_df = pd.read_csv(os.path.join(os.getcwd(), "data", "train_debug.csv"))
        #####################################################
        ## This space saved for future Train-PreProcessing ##
        #####################################################
        train_df.to_csv(self.output().path, index=False)
        custom_out('TrainDataPreProcessing Node finished')

class TestDataPreProcessing(luigi.Task):

    def run(self):
        custom_out('TestDataPreProcessing Node initiated')
        #test_df = pd.read_csv(os.path.join(os.getcwd(), "data", "test_clean.csv"))
        test_df = pd.read_csv(os.path.join(os.getcwd(), "data", "test_debug.csv"))
        ####################################################
        ## This space saved for future Test-PreProcessing ##
        ####################################################
        test_df.to_csv(self.output().path, index=False)
        custom_out('TestDataPreProcessing Node finished')

    def output(self):
        return luigi.LocalTarget("/tmp/test_clean_out.csv")

class Train(luigi.Task):
    def requires(self):
        return TrainDataPreProcessing()

    def output(self):
        return luigi.LocalTarget("/tmp/russian_housing_model.pkl")

    def run(self):
        custom_out('Train Node initiated')

        train_df = pd.read_csv(self.input().path)

        model_str = model_in(sys.argv[4])
        custom_out('Model chosen: {}'.format(model_str))
        train_df = preprocess_data(train_df, model_str, 'train')
        prices_model = model_choice(model_str, train_df)
        
        custom_out('Successfully trained model')
        with open(self.output().path, 'wb') as f:
            pickle.dump(prices_model, f)
        custom_out('Successfully wrote model to pickle')

class Predict(luigi.Task):
    def requires(self):
        yield Train()
        yield TestDataPreProcessing()
        yield WeightedModel()

    def output(self):
        timestr = time.strftime("%Y%m%d-%H%M%S")
        return luigi.LocalTarget(os.path.join(os.getcwd(), "logs", "predictions/russian_housing_submission_{}.csv".format(timestr)))

    def run(self):
        custom_out('Predict Node initiated')
        model_str = model_in(sys.argv[4])
        if model_str == 'xgbtolr':
            #pass off functional call to helper files
            #predictions = xgb_lr()
            pass
        elif not (model_str in function_mappings().keys()):
            custom_out('Model input is not in available models')
        else:
            prices_model = pd.read_pickle(Train().output().path)
            test_df = pd.read_csv(TestDataPreProcessing().output().path)
            test_x = test_postprocess(model_str, test_df)
            predictions = prices_model.predict(test_x)

            model_str2 = model_in(sys.argv[5])
            if not (model_str2 in function_mappings().keys()):
                custom_out('No (or invalid) 2nd model choice')
            else:
                second_model = pd.read_pickle(WeightedModel().output().path)
                test_x2 = test_postprocess(model_str2, test_df)
                predictions2 = second_model.predict(test_x2)
                predictions = stacked_model_compute(predictions, predictions2)

        submission = prediction_to_submission(test_df, predictions, model_str)
        submission.to_csv(self.output().path, index=False)

        custom_out('Write of submission to csv successful')


class WeightedModel(luigi.Task):
    def requires(self):
        return TrainDataPreProcessing()

    def output(self):
        return luigi.LocalTarget("/tmp/russian_housing_model2.pkl")

    def run(self):
        model_str = model_in(sys.argv[5])
        if model_str in function_mappings():        
            custom_out('Stacked Model Node initiated')

            train_df = pd.read_csv(self.input().path)

            custom_out('2nd Model chosen: {}'.format(model_str))
            train_df = preprocess_data(train_df, model_str, 'train')
            prices_model = model_choice(model_str, train_df)
        
            custom_out('Successfully trained model')
            with open(self.output().path, 'wb') as f:
                pickle.dump(prices_model, f)
            custom_out('Successfully wrote model to pickle')

        else:
            with open(self.output().path, 'wb') as f:
                pickle.dump('none', f)


class ModelSelection(luigi.Task):
   def run(self):
       model_str = model_in(sys.argv[4])
       print '\n\ndebug successful\n\n'

if __name__ == '__main__':
    luigi.run(sys.argv[1:4])
    
