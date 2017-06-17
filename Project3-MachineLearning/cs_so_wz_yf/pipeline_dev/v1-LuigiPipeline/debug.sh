#!/usr/bin/env bash

rm /tmp/russian_housing_model.pkl
rm /tmp/test_clean_out.csv
rm /tmp/train_clean_out.csv

echo "\n\ndebug mode"

read model_choice

timestamp(){
	date +%s
}
python luigi_ml_pipeline.py --workers 4 ModelSelection "xgb"
#python luigi_ml_pipeline.py --workers 4 Predict "$model_choice" > ./logs/"$(timestamp)"-luigi-log.txt