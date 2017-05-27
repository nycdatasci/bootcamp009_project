from __future__ import division
from collections import defaultdict
from glob import glob
import sys
import math

glob_files = sys.argv[1]
loc_outfile = sys.argv[2]
weights = sys.argv[3]
weights = map(float, weights.split(','))

def kaggle_bag(glob_files, loc_outfile, weights=[], method="average"):
# Once the output file is open, it could possibly be picked up by the glob
# depending on the regex, so define input_files here to be safe 
  input_files = ( glob(glob_files) )
  if method == "average":
    scores = defaultdict(float)
  if len(weights) == 0:
      weights = [1] * len(input_files)
  elif not len(weights) == len(input_files):
      raise ValueError('length of non-zero weights list does not match number of input files')
  with open(loc_outfile,"wb") as outfile:
    for i, glob_file in enumerate( input_files ):
      print "parsing:", glob_file
      # sort glob_file by first column, ignoring the first line
      lines = open(glob_file).readlines()
      lines = [lines[0]] + sorted(lines[1:])
      for e, line in enumerate( lines ):
        if i == 0 and e == 0:
          outfile.write(line)
        if e > 0:
          row = line.strip().split(",")
          if scores[(e,row[0])] == 0:
            scores[(e,row[0])] = 1
          scores[(e,row[0])] *= float(row[1])**weights[i]
    for j,k in sorted(scores):
      outfile.write("%s,%f\n"%(k,math.pow(scores[(j,k)],1/(sum(weights)))))
    print("wrote to %s"%loc_outfile)

kaggle_bag(glob_files, loc_outfile, weights)