# @author Scott Dobbins
# @version 0.3
# @date 2017-05-03 21:30

from numpy.random import normal as np_rand_norm
from math import exp
from time import sleep

def wait_log_normal(mu, sigma):
    sleep(exp(np_rand_norm(mu, sigma)))
