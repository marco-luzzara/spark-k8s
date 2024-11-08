package it.unimi;

import org.apache.spark.api.java.function.MapFunction;
import org.apache.spark.sql.Encoders;
import org.apache.spark.sql.SparkSession;
import static org.apache.spark.sql.functions.avg;

/**
 * Hello world!
 */
public class SparkSample {
    /**
     * Spark Job that computes the average of the ages in the input dataset
     * 
     * @param args two positional arguments:
     *             - Input file path: a CSV file with header (id,name,age)
     *             - Output file path: a generic text file
     */
    public static void main(String[] args) {
        SparkSession spark = SparkSession
                .builder()
                .appName(SparkSample.class.getName())
                .getOrCreate();

        var df = spark.read()
                .option("delimiter", ",")
                .option("header", "true")
                .csv(args[1])
                .as(Encoders.bean(Person.class));

        var mappedDf = df.map((MapFunction<Person, Long>) p -> p.getAge(), Encoders.LONG());
        var outDf = mappedDf.agg(avg(mappedDf.col("age")));

        outDf.write().text(args[2]);
    }
}
