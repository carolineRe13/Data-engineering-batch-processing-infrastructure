from pyspark import SparkConf, SparkContext
from pyspark.sql import SparkSession


def a():
    # with open as csv:
    conf = SparkConf()\
            .setAppName("Word Count")\
            .setMaster("spark://spark-master:7077")\
            # .set("spark.exexutor.memory", "4g")\
            # .set("spark.local.ip", "127.0.0.1")\
            # .set("spark.driver.host", "host.docker.internal")\
            # .set("spark.driver.port", "52777")\

    spark = SparkSession.builder\
                .config(conf=conf)\
                .getOrCreate()

    df = spark.read.csv("/root/us-accidents/US_Accidents_Dec21_updated.csv", header=True)
    df.printSchema()

    print(sorted(df.groupBy("Severity").agg({"*": "count"}).collect()))



if __name__ == "__main__":
    a()
