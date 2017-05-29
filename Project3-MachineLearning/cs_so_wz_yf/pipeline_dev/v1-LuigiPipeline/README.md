# Luigi-Price Prediction

This project is an example of how to create a Machine Learning pipeline to build models.
It uses the data from the Russian Housing Prices Competition in Kaggle. 
The purpose of the project is not to create an accurate model for predicting Prices instead how to 
orchestrate the various tasks.

It uses [Luigi](https://github.com/spotify/luigi) to orchestrate the pipeline of the batch jobs.


## Installation 
===============
### Python
---------------
It requires Python 2.7.*


### Installation and Execution 
------------------------
```
$ sh build.sh
$ sh run.sh
```

* Run the build.sh
	+ It will create a virtual environment in the root directory of the project with all the dependencies maintained in requirements.txt
	+ It will also setup the luigi Central Scheduler and run it as a daemon process.
	+ The Luigi Task Visualiser can be accessed by http://localhost:8082 which will give visualisation of all the running tasks.
	+ Historical Tasks can also be viewed by http://localhost:8082/history
* Run the run.sh
	+ This starts the pipeline
	+ Access visualization via http://localhost:8082

### Known Issues
------------------------

* XGBOOST is the only implemented regressor
	+ To change hyperparameters/settings, only alter the train_xg_boost function in the regressor.py module
	
* Using the SkLearn n_jobs > 1 for Scikit Learn Modules like GridSearchCV and others will cause an error.
* This may be due to the the Process Assignment ID of Luigi using the Central Scheduler.
* In case of --local-scheduler flag the error is not reproduced.



