from scipy.stats.mstats import normaltest
from matplotlib import pyplot as plt

## Returns
def outliers(feature):
    feature = feature.loc[feature.notnull()]
    for sd in np.arange(0.5,4,0.5):
        remaining = feature.loc[(feature - np.mean(feature)).abs() / np.std(feature) < sd]
        percent = np.float(len(remaining))/np.float(len(feature))
        print 'Within {0} SD, Remaining Obs: {1}, Percent: {2}'.format(sd,len(remaining),round(percent, 2))

## Returns number of missing features per df
def missing_count(df):
    features = {}
    for feature in df:
        if np.sum(df[feature].isnull()) > 0:
            features[feature] = np.sum(df[feature].isnull())
    return features

    # Plots the s^2 + k^2, where s is the z-score by `skewtest` and ``k`` is the z-score by `kurtosistest`.


def normality_split(feature, input_range, silent=1):
    splits = {}
    lower_plot = []
    upper_plot = []

    sorted_values = feature.loc[feature.notnull()].sort_values().get_values()

    for i in input_range:
        lower_array =  round(normaltest(sorted_values[int(len(sorted_values)*(i*.01)):])[0], 2)
        upper_array = round(normaltest(sorted_values[:int(len(sorted_values)*(i*.01))])[0], 2)
        splits[i] = [lower_array, upper_array]
        lower_plot.append(lower_array)
        upper_plot.append(upper_array)
        if silent == 0: print "{0}/{1} split normality score:".format(splits[i])

    plt.figure(figsize=(14,6),dpi=150)
    plt.xlabel("% Split")
    plt.ylabel("Normality Score")
    plt.plot(lower_plot, label="Lower Split",lw=3)
    plt.plot(upper_plot, label="Upper Split",lw=3)
    return 'Lowest Normality test score: {0}: '.format(min(splits.values()))
    return plt.show()
