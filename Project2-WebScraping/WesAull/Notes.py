import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
import seaborn as sns

tbl = pd.read_csv('correlate-tableau.csv')
tbl.head()
plt.hist(tbl[' '])
plt.hist(df['imdb_score'], bins=20, color="#666699")

# log_budget = np.log(df['budget'])
# log_budget.plot.hist()
# plt.xlabel('log of budget')
# plt.ylabel('count')
# plt.title('Histogram of budget', fontsize=20)

# Great PDF plot at SNS.
# sns.kdeplot(df['imdb_score'], shade=True, label='Estimated PDF of imdb score')


