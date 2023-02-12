import os
from pyspark import SparkConf, SparkContext
from pyspark.sql import SparkSession

MASTER_URI = "spark://spark-master:7077" if os.environ["ENVIRONMENT"] == "Development" else "spark://localhost:7077"

def a():
    # with open as csv:
    conf = SparkConf()\
            .setAppName("Preprocessing")\
            .setMaster(MASTER_URI)

    spark = SparkSession.builder\
                .config(conf=conf)\
                .getOrCreate()

    df = spark.read.csv("/root/us-accidents/US_Accidents_Dec21_updated.csv", header=True)
    df.printSchema()

    print(sorted(df.groupBy("Severity").agg({"*": "count"}).collect()))


if __name__ == "__main__":
    a()
