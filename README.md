# README for Coursera class "Getting and Cleaning Data" class assignment

## Data Set Definition

All of the measurements in this data set are ultimately derived from two
instruments within a Samsung Galaxy S II smartphone: an accelerometer and a
gyroscope. Each instrument returns a three-dimensional vector as its
measurement, that is, a measurement along the X, Y, and Z axes.  A set of
thirty test subjects wore the smartphone strapped to their waist.  The
accelerometer and gyroscope were read 50 times per second while the subjects
performed one of six different activities, generating the raw data.

The original experimenters then did a significant amount of post-processing on
the raw data, ultimately resulting in the data set that was used as the input
for this analysis.

See the [Code Book](./CodeBook.md) for the full details of the data set, where
it came from, what variables it contains, and the processing that was done.

## Assumptions of the processing script

The processing script `run_analysis.R` assumes that the data set has already
been manually downloaded (from the URL listed below).  It further assumes that 
the data set was unzipped into the folder `UCI HAR Dataset` which R can find
in its current working directory.

As mentioned in the [Code Book](./CodeBook.md), you can download a copy of the
original data set from this URL:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

NOTE:  The processing script cleans its environment before it runs, to guarantee
no interference with previous environment contents.  It uses this command to do
this:

```R
rm(list = ls())
```

If you do not want the environment to be emptied, you can comment out this line
before running the script.

The processing script also requires that the library `dplyr` is installed
locally.  It will load it with the `library` function, so it does not have to
loaded before the processing script is executed.  It just has to be installed.
If dplyr is not already installed, you can install it with this command:

```R
install.packages("dplyr")
```

This script was developed and tested with R version 3.1.2 (2014-10-31), in a
Windows 7 64-bit environment. Dplyr version 0.4.1 was used.

## Using the processing script

The processing script `run_analysis.R` requires no arguments.  Since it clears
its environment before it runs, it does not depend on what was previously
loaded in the environment.  There are no external R scripts.  All of the
processing code is in one script.  Therefore, you can run the processing script
with this command:

```R
source("run_analysis.R")
```

When the script has completed, you will find a new file `summarized_data.txt`
in the current working directory.  The R environment will also contain these
variables:

* `X` -- The test and training data sets merged, but without the subject ID or
      activity ID.  It does have an added row-ID column that is used in merging.
* `reduced_X` -- the test and training sets merged, with only the desired subset of
      columns and with the subject ID and activity name columns added.
* `summarized` -- the data set that is the output of the processing script,
      and which is also saved in the file `summarized_data.txt`.
* `sanityCheck` -- the function used to double-check the analysis output.

All of the code is in a single script, for simplicity.  The important sections
of code are labeled with block comments to make it easy to identify what is
being done at each step.  Only one function is defined -- the function that
verifies that the analysis was consistent and accurate.  All other processing
was done inline in the script.

## Why data is tidy

FOr this exercise, either the "narrow" or "wide" form of tidy data would be
valid.  I opted to use the wide form of tidy data, as it is more convenient.
Each row represents all computed averages for a single observation, that is,
the summarized result of a single set of measurements for a single subject and
activity.  Each column is a single variable (representing the average of one of
the variables on the input data set) for a single observation.  There is only
one kind of "observational unit" so there is no need for a second table
(aka data.frame) or data file.

## How to read the data file

You can load and view this data set into a data.frame in R using this code:

```R
data <- read.table(file_path, header = TRUE) 
View(data)
```
