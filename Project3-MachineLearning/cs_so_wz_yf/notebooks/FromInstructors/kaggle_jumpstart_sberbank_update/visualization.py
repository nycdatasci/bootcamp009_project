import numpy as np
import seaborn as sns
from pandas.io.json import build_table_schema


def hist_density_plot(data, x, logx=False):
    data = data[x]
    if logx:
        data = np.log(data + 1)
    xlim = (min(data), max(data))
    data.plot(kind='hist', xlim=xlim, bins=50, color='red', alpha=.6)
    data.plot(kind='kde', xlim=xlim, secondary_y=True, color='black')


def corr_plot(data):
    corrmtx = data.corr()
    sns.clustermap(corrmtx, annot=True, linewidths=.5)


def timeseries_plot(data, val, timestamp='timestamp', by='day'):
    by = by.strip().lower()
    if by == 'day':
        data.loc[:, [timestamp, val]].groupby(timestamp).agg('mean').plot()
        return
    elif by == 'weekday':
        by = '%w'
    elif by == 'month':
        by = '%m'
    elif by == 'year-month':
        by = '%Y-%m'
    elif by == 'year':
        by = '%Y'
    by_what = data[timestamp].apply(lambda x: x.strftime(by))
    data.loc[:, [timestamp, val]].groupby(by_what).agg('mean').plot()
    
    
    
    