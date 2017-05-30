#!/usr/bin/env bash

echo "\n\nAvailable models: xgb, rf"
echo "\nInput the model you want to use, followed by [ENTER]:\n"

read model_choice

timestamp(){
	date +%s
}
#python luigi_ml_pipeline.py --workers 4 ModelSelection "$model_choice"
python luigi_ml_pipeline.py --workers 1 Predict "$model_choice" > ./logs/"$(timestamp)"-luigi-log.txt