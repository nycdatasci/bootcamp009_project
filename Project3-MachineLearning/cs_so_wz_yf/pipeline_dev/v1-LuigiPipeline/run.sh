#!/usr/bin/env bash

rm /tmp/russian_housing_model.pkl
rm /tmp/russian_housing_model2.pkl
rm /tmp/test_clean_out.csv
rm /tmp/train_clean_out.csv

echo "\n\nAvailable models: \nXGB (XGBOOST),\nRF (Random Forest),\nFLR (forward-select LinReg),"
echo "RLR (ridge LinReg)\nEN (elastic net lin reg)"
echo "xgbGrid (XGB with grid search on hyperparam)"
echo "\nInput the model you want to use, followed by [ENTER]:\n"

read model_choice

echo "Enter second model choice for stacking (or none if single)\n"

read second_choice

echo "\n"
timestamp(){
	date +%s
}
#python luigi_ml_pipeline.py --workers 4 ModelSelection "$model_choice"
python luigi_ml_pipeline.py --workers 1 Predict "$model_choice" "$second_choice" > ./logs/"$(timestamp)"-luigi-log.txt