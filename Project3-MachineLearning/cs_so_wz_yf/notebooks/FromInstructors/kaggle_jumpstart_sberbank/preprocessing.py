import numpy as np
import warnings
from sklearn import preprocessing

__all__ = [
    'LabelEncoder',
]


class LabelEncoder(preprocessing.LabelEncoder):
    
    def fit(self, y):
        super(self.__class__, self).fit(y)
        val_cnt = y.value_counts()
        self.classes_ = np.array(val_cnt.index)
        return self
        
    @property
    def fit_transform(self):
        raise AttributeError("'LabelEncoder' object has no attribute 'fit_transform'")

    def transform(self, y, newlables=np.nan):
        """Transform labels to normalized encoding.
        Parameters
        ----------
        y : array-like of shape [n_samples]
            Target values.
        Returns
        -------
        y : array-like of shape [n_samples]
        """
        # check_is_fitted(self, 'classes_')
        # y = column_or_1d(y, warn=True)
        
        val_cnt = y.value_counts()
        classes = np.array(val_cnt.index)
        # _check_numpy_unicode_bug(classes)
        if len(np.intersect1d(classes, self.classes_)) < len(classes):
            diff = np.setdiff1d(classes, self.classes_)
            warnings.warn("y contains new labels: {}".format(str(diff)))
        return np.array([np.searchsorted(self.classes_, [x])[0]
                        if x in self.classes_ else newlables for x in y])
        
        
        