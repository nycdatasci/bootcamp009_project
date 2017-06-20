## Steps:

### 1. Install [Java Development Kit (JDK)](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) (Required for Spark)

### 2. Installing Spark:

1. **Download Spark:** [spark-2.1.1-bin-hadoop2.7.tgz](https://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.7.tgz)

2. **Extract the tgz file into a directory you'd like to use:** (`/usr/local/spark` is recommended). If you are using `/usr/local/spark`, you'll need root permissions (sudo).

3. From your terminal, enter the directory you just extracted:
```
$ cd /usr/local/spark
```

4.  Run the following command in your directory
```
./bin/pyspark
```

3. **Add spark as an environmental variable:** Depending on your shell, it's likely either the ~/.bashrc or ~/.zshrc or ~/bash_profile. Add the following line to your shell configuration:
```
export PATH=$PATH:/usr/local/spark/bin
```
To configure jupyter notebook access, add the following lines to the bottom of your config file:
```
export PYSPARK_DRIVER_PYTHON="jupyter"
export PYSPARK_DRIVER_PYTHON_OPTS="notebook"
```

4. **Save and exit** out of your config file.

5. **Restart** your shell terminal.

6.  **Run pySpark:** To confirm spark was installed correctly, run  `pyspark` from your terminal. This should open up jupyter notebook.

7. **Test your Spark Installation:**
(you can also use the ipynb example in the git directory)

```
from pyspark import SparkContext
import random

sc = SparkContext.getOrCreate()

# getOrCreate() will create a SparkContext instance or if there is one already created, it will use that one. Spark allows for only one SparkContext at a time

num_samples = 1000 # the bigger this is, the more accurate your pi approximation
def inside(p):
  x, y = random.random(), random.random()
  return x*x + y*y < 1
count = sc.parallelize(range(0, num_samples)).filter(inside).count()
pi = 4 * count / num_samples
print(pi)
sc.stop()
```
