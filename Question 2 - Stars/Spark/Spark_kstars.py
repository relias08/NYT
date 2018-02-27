#!/usr/bin/python

import sys
print('Co-ordinates of the {} nearest stars from the Sun'.format(int(sys.argv[1])))

from pyspark.sql import SparkSession
from pyspark.sql.functions import lit

spark = SparkSession.builder.getOrCreate()

stars = spark.read.csv('hygdata_v3.csv', header = True, inferSchema = True)
stars = stars.select('id', 'proper', 'x', 'y', 'z' )

x0 = stars.select('id', 'proper', 'x', 'y', 'z' ).head(2)[0][2]
y0 = stars.select('id', 'proper', 'x', 'y', 'z' ).head(2)[0][3]
z0 = stars.select('id', 'proper', 'x', 'y', 'z' ).head(2)[0][4]

stars = stars.withColumn('x0', lit(x0)).withColumn('y0', lit(y0)).withColumn('z0', lit(z0))
stars = stars.withColumn('distance', ((stars.x - stars.x0)**2 + (stars.y - stars.y0)**2 + (stars.z - stars.z0)**2)**0.5)
stars.orderBy('distance').select('id', 'proper', 'x', 'y', 'z', 'distance').show(int(sys.argv[1]))
