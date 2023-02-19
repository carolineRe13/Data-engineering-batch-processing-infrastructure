import os
from pyspark import SparkConf, SparkContext
from pyspark.sql import SparkSession
import time

MASTER_URI = "spark://spark-master:7077" if os.environ["ENVIRONMENT"] == "Development" else "spark://localhost:7077"

def preprocess():
    # TODO: make sure cluster is started before running this script

    # with open as csv:
    conf = SparkConf()\
            .setAppName("Preprocessing")\
            .setMaster(MASTER_URI)

    spark = SparkSession.builder\
                .config(conf=conf)\
                .getOrCreate()

    df = spark.read.csv("/data/US_Accidents_Dec21_updated.csv", header=True)
    df.printSchema()

    df = df.na.drop(subset=["Weather_Condition"])

    result = df.groupBy(["State", "Weather_Condition"]).agg({"*": "count"})

    result.write.option("header",True).csv(f"/data/accident_per_state_per_weather_{int(time.time())}")


if __name__ == "__main__":
    preprocess()
