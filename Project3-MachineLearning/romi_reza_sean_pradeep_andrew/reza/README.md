## Theory and Research

Stacking: Taking the predictions of the base models as features (i.e. meta features) for the stacked model.  Stacking is really effective on Kaggle when you have a team of people trying to collaborate on a model. A single set of folds is agreed upon and then every team member builds their own model(s) using those folds. Then each model can be combined using a single stacking script. This is great because it prevents team members from stepping on each others toes, awkwardly trying to stitch their ideas into the same code base.
(source: http://blog.kaggle.com/2016/12/27/a-kagglers-guide-to-model-stacking-in-practice/)

Real residential investment displays co-movement with house prices during the first two decades of the sample. The peaks in res- idential investment anticipate the peaks in house prices by one quarter. In contrast, during the last two decades, the cycles of residential investment and house prices are unsynchronized. House prices generally increase since the mid-1990’s to 2005Q3. In contrast, residential invest- ment displays a different pattern and more closely follow the U.S. economic cycle. Leading the NBER business activity peak by a few quarters, residential investment display a peak in 2000Q3, whereas the decline in housing investment ends in 2003Q1, a few quarters after the through of activity.
Is there any role for news shocks during housing market booms and busts? Regarding the relative importance of the anticipated and unanticipated component of shocks for changes in house prices, news shocks contribute to the boom-phases, whereas the busts are almost entirely the result of unanticipated monetary policy and productivity shocks. News shocks also sizably contributed to changes in residential investment.
(SOURCE: https://www.ecb.europa.eu/pub/pdf/scpwps/ecbwp1775.en.pdf?97f22e51ed195b7a0f48e5357c65bb2d)

Significantly better performance is obtained by boosting full decision trees with exponential loss, and then calibrating their predictions using either Platt Scaling or Isotonic Regression. Calibration with Platt Scaling or Isotonic Regression is so effective that after calibration boosted decision trees predict better probabilities than any other learning method we have compared them to, including neural nets, bagged trees, random forests, and calibrated SVMs.
(source: https://www.aaai.org/Papers/Workshops/2007/WS-07-05/WS07-05-006.pdf)

In this work, we identify good practices for Bayesian optimization of machine learning algorithms. We argue that a fully Bayesian treatment of the underlying GP kernel is preferred to the approach based on optimization of the GP hyperparameters, as previously proposed [5]. Our second contribution is the description of new algorithms for taking into account the variable and unknown cost of experiments or the availability of multiple cores to run experiments in parallel.
(Source: http://papers.nips.cc/paper/4522-practical-bayesian-optimization-of-machine-learning-algorithms.pdf)

This paper is a tutorial for students and researchers on some of the techniques that can be used to reduce this computational cost considerably on modern x86 CPUs. We emphasize data layout, batching of the computation, the use of SSE2 instructions, and particularly leverage SSSE3 and SSE4 fixed-point instructions which provide a 3× improve- ment over an optimized floating-point baseline.
(source: https://static.googleuserconte(source: http://homes.cs.washington.edu/%7Etqchen/2016/03/10/story-and-lessons-behind-the-evolution-of-xgboost.html)

When creating predictions for the test set, you can do that in one go, or take an average of the out-of-fold predictors. Though taking the average is the clean and more accurate way to do this, I still prefer to do it in one go as that slightly lowers both model and coding complexity.
(source: https://mlwave.com/kaggle-ensembling-guide/)

multi:softprob” –same as softmax, but output a vector of ndata * nclass, which can be further reshaped to ndata, nclass matrix. The result contains predicted probability of each data point belonging to each class.

“multi:softmax” –set XGBoost to do multiclass classification using the softmax objective, you also need to set num_class(number of classes)

blending logistic regression with xgboost: https://github.com/emanuele/kaggle_pbr/blob/master/blend.py

http://fastml.com/classifier-calibration-with-platts-scaling-and-isotonic-regression/


For faster speed
• Use bagging by set bagging_fraction and bagging_freq • Use feature sub-sampling by set feature_fraction
• Use small max_bin
• Use save_binary to speed up data loading in future learning
• Use parallel learning, refer to parallel learning guide.
For better accuracy
• Use large max_bin (may be slower)
CHAPTER 4
Parameters Tuning
  19
LightGBM Documentation, Release
 • Use small learning_rate with large num_iterations • Use large num_leaves(may cause over-fitting)
• Use bigger training data
• Try dart
Deal with over-fitting
• Use small max_bin
• Use small num_leaves
• Use min_data_in_leaf and min_sum_hessian_in_leaf
• Use bagging by set bagging_fraction and bagging_freq
• Use feature sub-sampling by set feature_fraction
• Use bigger training data
• Try lambda_l1, lambda_l2 and min_gain_to_split to regularization • Try max_depth to avoid growing deep tree
(Source: https://media.readthedocs.org/pdf/lightgbm/latest/lightgbm.pdf)



### 1-of-K encoding:
sklearn.preprocessing.OneHotEncoder:  Note: a one-hot encoding of y labels should use a LabelBinarizer instead.
pandas.get_dummies:
