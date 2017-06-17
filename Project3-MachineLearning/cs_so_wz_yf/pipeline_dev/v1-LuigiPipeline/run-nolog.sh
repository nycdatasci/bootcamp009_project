#!/usr/bin/env bash

rm /tmp/russian_housing_model.pkl
rm /tmp/test_clean_out.csv
rm /tmp/train_clean_out.csv

echo "\n\nAvailable models: \nXGB (XGBOOST),\nRF (Random Forest),\nLR (forward-select LinReg)"
echo "\nInput the model you want to use, followed by [ENTER]:\n"

read model_choice

timestamp(){
	date +%s
}
#python luigi_ml_pipeline.py --workers 4 ModelSelection "$model_choice"
python luigi_ml_pipeline.py --workers 1 Predict "$model_choice"