import numpy as np
import pandas as pd
import re
import itertools

train = pd.read_csv('../data/train.csv')
cols = list(train.columns)
regex = re.compile('.*km.*')
matching_cols = []
for i in cols:
    s = regex.findall(i)
    if len(s) != 0:
        matching_cols.append(s)

# Flatten the list
matching_cols = list(itertools.chain.from_iterable(matching_cols))
