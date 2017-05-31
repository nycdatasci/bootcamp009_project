#!/usr/bin/env bash

timestamp(){
	date +%s
}

python luigi_ml_pipeline.py --workers 4 Predict > ./logs/"$(timestamp)"-luigi-log.txt