# Code Book for "Getting and Cleaning Data"

## Definitions

* Origin (or Original) Data Set -- the data set used as an input to this analysis
* Current Data Set -- the data set that is the output of this analysis
* FFT -- Fast Fourier Transform, a specific algorithm for doing a Fourier
  Transform rapidly.  A Fourier transform will help identify repetitive motion,
  for example, the up-and-down bouncing that occurs while walking at a 
  constant speed.

## Original Source of Data

The data included here is a tidied and summarized subset of data from another
source, which is itself a processed set of data from that source.  Although the
raw data is also included in that original data source, it was not used for this
analysis.

The original data set is provided courtesy of the University of California at
Irvine's Machine Learning Repository, which is a repository of useful data
sources but is not itself the origin of most of them.  The original source of
this specific data set is cited as:

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

A full description of the original data set can be found at this web site:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

Additional details about the origin data set, including the transformations that
were performed on the raw data to create its summarized data, are included
within files included with it.  Assuming the origin data set is unpacked in the
default directory "UCI HAR Dataset" relative to the current working directory,
these details can be found in:

* `UCI HAR Dataset/README.txt` -- high level information about the data set
* `UCI HAR Dataset/features_info.txt` -- details about the transformations
    performed on the raw data to get the summarized data that is the input for
    this analysis and that is found in the `test` and `train` subfolders.  Also
    defined in this document is the meaning of the data set column names.

The original data set can be downloaded from the URL:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

This analysis used the following data files from the origin data set:

* `UCI HAR Dataset/activity_labels.txt` -- relates the activity index values 1-6
    to the activity names, such as "Walking" or "Standing".  The activity index
    values are used in `y_test.txt` and `y_train.txt`.
* `UCI HAR Dataset/features.txt` -- provides the column name for each of the 561
    columns in `X_test.txt` and `X_train.txt`.  The meaning of the column names
    is defined in `features_info.txt` as mentioned above.
* `UCI HAR Dataset/test/X_test.txt` -- The test data set
* `UCI HAR Dataset/test/y_test.txt` -- the activity index for each row of the test data set
* `UCI HAR Dataset/test/subject_test.txt` -- the subject index for each row of the test data set
* `UCI HAR Dataset/train/X_train.txt` -- The training data set
* `UCI HAR Dataset/train/y_train.txt` -- the activity index for each row of the training data set
* `UCI HAR Dataset/train/subject_train.txt` -- the subject index for each row of the training data set

The raw data is found in the "Inertial Signals" folders:

* `UCI HAR Dataset/test/Inertial Signals/*`
* `UCI HAR Dataset/train/Inertial Signals/*`

The raw data is not required for this analsysis.  The `run_analysis.R` script
does not load or reference any file from those folders.

Note that the origin data have been normalized and bounded to [-1, 1].  Due to
this normalization, the variables are unitless.

## Transformations

The following transformations were done on the origin data set:

* The column labels were improved to be much clearer what is being measured
  (see below for details)
* The training and test data sets were merged into a single data set
* Data from the separate subject ID and activity ID files was merged into the data set
* Most of the columns were discarded, keeping only the columns for subject ID,
  activity ID, and any measurement representing a mean or standard deviation.
* The activity ID was replaced by a factor containing the activity name
* On this reduced data set, each variable was averaged across all instances
  for the same subject and activity.  Yes, this means the measurements in the
  final data set represent the mean of means and the mean of standard
  deviations.
* The final summarized data set was written to a file

## Measurements included in the final data set

All measurements are ultimately derived from two instruments, an accelerometer
and a gyroscope.  Each measures three different values, an X, Y, and Z axis
value.  The original experimenters expanded these six measurements into 33
measurements, 20 of them computed from the raw data and the other 13 derived
from a FFT of some of the data.

*Note:* The columns containing "MeanFreq" are not included in this analysis.  The
requirement is: "mean and standard deviation for each measurement," not 
"mean and standard deviation and weighted mean frequency of each measurement."
Looking at `features_info.txt`, it is clear that mean frequency is another
variable measured from the signal, along with the mean, standard deviation,
min, max, energy measure, correlation, and so on.  We were only asked to keep
two of those variables, the mean and the standard deviation.

### Time-domain measurements

The first 20 measurements were computed by computing four values for each of
the following:

 Measurement          | Time derivative of measurement
--------------------- | -----------------------------------
Body accleration      | Body Acceleration Jerk
Gravity acceleration  | --
Body angular velocity | Body Gyroscopic Jerk

For each of the above, the four values are the three X, Y, and Z axis values,
plus the magnitude of the 3-dimensional signal (the Euclidean norm).  The
acceleration from gravity was separated from the acceleration from body movement
using a set of filters.

These values were represented in the origin data set with a `t` in front of the
column name to indicate a time-domain measurement.  Since a time-domain
measurement is just the ordinary measurement, the transformed column names
dropped the `t` as not being useful or interesting.

### Frequency-domain measurements

The final 13 measurements were computed from an FFT of some of the above values.
As with the above, except as noted below, each signal shown in the table 
represents four values, an X, Y, and Z measurement, and the Euclidean norm of
the 3-vector.  The one exception (noted with (*)) only includes the magnitude
of the 3-vector but does not include the X, Y, or Z  components of the vector.
Because of this exception, and because the FFT was not applied to the measured
acceleration of gravity, there are seven fewer frequency-domain measurements 
than time-domain measurements.

 FFT Measurement      | FFT Time derivative of measurement
--------------------- | -----------------------------------
Body accleration      | Body Acceleration Jerk
Body angular velocity | Body Gyroscopic Jerk (*)

### A note about "Jerk"

The term "Jerk" has a specific meaning.  It represents the time derivative of
acceleration for linear motion and the time derivative of angular acceleration
for rotational motion.  Jerk represents the rate of change of acceleration.

To read more about Jerk, see its
[Wikipedia Entry](http://en.wikipedia.org/wiki/Jerk_%28physics%29)

### Total number of columns

A total of thirty-three variables is kept in the final data set.  The mean
and the standard deviation for each is kept.  That results in 66 variables.
Since the subject ID and activity name are essential parts of each measurement,
the total number of variables in the final data set is 68, two qualitative and
66 quantitative.

## Description of all variables in the final data set

The final data set has two qualitative variables and 66 quantitative variables. 
The two qualitative variables are the first two columns.  Each variable is 
defined in the table below.  Time-domain measurements are just listed as the 
measurement. Frequency-domain measurements have "Frequency_" prepended to the 
name.

Since all measurements in the final data set represent a mean, it would be
redundant to prepend `Mean_of_` to every name.  Thus, each quantitative column
name indicates which measurement it is the mean of.

Column                                          | Column contents
----------------------------------------------- | ------------------------------------------------------------------------------------------
subjectId                                       | The subject ID, an integer from 1 to 30
activityName                                    | The name of the activity the subject was doing when the measurements in this row were made
----------------------------------------------- | ------------------------------------------------------------------------------------------
Body_Acceleration_mean_X                        | mean acceleration of the body along the X axis
Body_Acceleration_mean_Y                        | mean acceleration of the body along the Y axis
Body_Acceleration_mean_Z                        | mean acceleration of the body along the Z axis
Gravity_Acceleration_mean_X                     | mean acceleration of gravity along the X axis
Gravity_Acceleration_mean_Y                     | mean acceleration of gravity along the Y axis
Gravity_Acceleration_mean_Z                     | mean acceleration of gravity along the Z axis
Body_Acceleration_Jerk_mean_X                   | mean jerk (time derivative of acceleration) of the body along the X axis
Body_Acceleration_Jerk_mean_Y                   | mean jerk (time derivative of acceleration) of the body along the Y axis
Body_Acceleration_Jerk_mean_Z                   | mean jerk (time derivative of acceleration) of the body along the Z axis
Body_Gyroscopic_mean_X                          | mean X axis component of the angular velocity of the body
Body_Gyroscopic_mean_Y                          | mean Y axis component of the angular velocity of the body
Body_Gyroscopic_mean_Z                          | mean Z axis component of the angular velocity of the body
Body_Gyroscopic_Jerk_mean_X                     | mean jerk (time derivative) of the X axis component of the angular velocity of the body
Body_Gyroscopic_Jerk_mean_Y                     | mean jerk (time derivative) of the Y axis component of the angular velocity of the body
Body_Gyroscopic_Jerk_mean_Z                     | mean jerk (time derivative) of the Z axis component of the angular velocity of the body
----------------------------------------------- | ------------------------------------------------------------------------------------------
Body_Acceleration_Magnitude_mean                | mean magnitude of the 3D vector of body acceleration
Gravity_Acceleration_Magnitude_mean             | mean magnitude of the 3D vector of the acceleration of gravity
Body_Acceleration_Jerk_Magnitude_mean           | mean magnitude of the 3D vector of the body Jerk measurement
Body_Gyroscopic_Magnitude_mean                  | mean magnitude of the 3D vector of the body angular velocity
Body_Gyroscopic_Jerk_Magnitude_mean             | mean magnitude of the 3D vector of time derivative of the body angular velocity
----------------------------------------------- | ------------------------------------------------------------------------------------------
frequency_Body_Acceleration_mean_X              | mean frequency-domain transform of acceleration of the body along the X axis
frequency_Body_Acceleration_mean_Y              | mean frequency-domain transform of acceleration of the body along the Y axis
frequency_Body_Acceleration_mean_Z              | mean frequency-domain transform of acceleration of the body along the Z axis
frequency_Body_Acceleration_Jerk_mean_X         | mean frequency-domain transform of jerk (time derivative of acceleration) of the body along the X axis
frequency_Body_Acceleration_Jerk_mean_Y         | mean frequency-domain transform of jerk (time derivative of acceleration) of the body along the Y axis
frequency_Body_Acceleration_Jerk_mean_Z         | mean frequency-domain transform of jerk (time derivative of acceleration) of the body along the Z axis
frequency_Body_Gyroscopic_mean_X                | mean frequency-domain transform of X axis component of the angular velocity of the body
frequency_Body_Gyroscopic_mean_Y                | mean frequency-domain transform of Y axis component of the angular velocity of the body
frequency_Body_Gyroscopic_mean_Z                | mean frequency-domain transform of Z axis component of the angular velocity of the body
----------------------------------------------- | ------------------------------------------------------------------------------------------
frequency_Body_Acceleration_Magnitude_mean      | mean magnitude of the 3D vector of the frequency-domain transform of body acceleration
frequency_Body_Acceleration_Jerk_Magnitude_mean | mean magnitude of the 3D vector of the frequency-domain transform of body Jerk
frequency_Body_Gyroscopic_Magnitude_mean        | mean magnitude of the 3D vector of the frequency-domain transform of body angular velocity
frequency_Body_Gyroscopic_Jerk_Magnitude_mean   | mean magnitude of the 3D vector of the frequency-domain transform of jerk (time derivative) of body angular velocity
----------------------------------------------- | ------------------------------------------------------------------------------------------
Body_Acceleration_std_X                         | standard deviation of acceleration of the body along the X axis                                           
Body_Acceleration_std_Y                         | standard deviation of acceleration of the body along the Y axis                                           
Body_Acceleration_std_Z                         | standard deviation of acceleration of the body along the Z axis                                           
Gravity_Acceleration_std_X                      | standard deviation of acceleration of gravity along the X axis                                            
Gravity_Acceleration_std_Y                      | standard deviation of acceleration of gravity along the Y axis                                            
Gravity_Acceleration_std_Z                      | standard deviation of acceleration of gravity along the Z axis                                            
Body_Acceleration_Jerk_std_X                    | standard deviation of jerk (time derivative of acceleration) of the body along the X axis                 
Body_Acceleration_Jerk_std_Y                    | standard deviation of jerk (time derivative of acceleration) of the body along the Y axis                 
Body_Acceleration_Jerk_std_Z                    | standard deviation of jerk (time derivative of acceleration) of the body along the Z axis                 
Body_Gyroscopic_std_X                           | standard deviation of X axis component of the angular velocity of the body                                
Body_Gyroscopic_std_Y                           | standard deviation of Y axis component of the angular velocity of the body                                
Body_Gyroscopic_std_Z                           | standard deviation of Z axis component of the angular velocity of the body                                
Body_Gyroscopic_Jerk_std_X                      | standard deviation of jerk (time derivative) of the X axis component of the angular velocity of the body  
Body_Gyroscopic_Jerk_std_Y                      | standard deviation of jerk (time derivative) of the Y axis component of the angular velocity of the body  
Body_Gyroscopic_Jerk_std_Z                      | standard deviation of jerk (time derivative) of the Z axis component of the angular velocity of the body  
----------------------------------------------- | ------------------------------------------------------------------------------------------
Body_Acceleration_Magnitude_std                 | standard deviation of the magnitude of the 3D vector of body acceleration                           
Gravity_Acceleration_Magnitude_std              | standard deviation of the magnitude of the 3D vector of the acceleration of gravity                 
Body_Acceleration_Jerk_Magnitude_std            | standard deviation of the magnitude of the 3D vector of the body Jerk measurement                   
Body_Gyroscopic_Magnitude_std                   | standard deviation of the magnitude of the 3D vector of the body angular velocity                   
Body_Gyroscopic_Jerk_Magnitude_std              | standard deviation of the magnitude of the 3D vector of time derivative of the body angular velocity
----------------------------------------------- | ------------------------------------------------------------------------------------------
frequency_Body_Acceleration_std_X               | standard deviation of the frequency-domain transform of acceleration of the body along the X axis                            
frequency_Body_Acceleration_std_Y               | standard deviation of the frequency-domain transform of acceleration of the body along the Y axis                            
frequency_Body_Acceleration_std_Z               | standard deviation of the frequency-domain transform of acceleration of the body along the Z axis                            
frequency_Body_Acceleration_Jerk_std_X          | standard deviation of the frequency-domain transform of jerk (time derivative of acceleration) of the body along the X axis  
frequency_Body_Acceleration_Jerk_std_Y          | standard deviation of the frequency-domain transform of jerk (time derivative of acceleration) of the body along the Y axis  
frequency_Body_Acceleration_Jerk_std_Z          | standard deviation of the frequency-domain transform of jerk (time derivative of acceleration) of the body along the Z axis  
frequency_Body_Gyroscopic_std_X                 | standard deviation of the frequency-domain transform of X axis component of the angular velocity of the body                 
frequency_Body_Gyroscopic_std_Y                 | standard deviation of the frequency-domain transform of Y axis component of the angular velocity of the body                 
frequency_Body_Gyroscopic_std_Z                 | standard deviation of the frequency-domain transform of Z axis component of the angular velocity of the body                 
----------------------------------------------- | ------------------------------------------------------------------------------------------
frequency_Body_Acceleration_Magnitude_std       | standard deviation of the magnitude of the 3D vector of the frequency-domain transform of body acceleration      
frequency_Body_Acceleration_Jerk_Magnitude_std  | standard deviation of the magnitude of the 3D vector of the frequency-domain transform of body Jerk              
frequency_Body_Gyroscopic_Magnitude_std         | standard deviation of the magnitude of the 3D vector of the frequency-domain transform of body angular velocity  
frequency_Body_Gyroscopic_Jerk_Magnitude_std    | standard deviation of the magnitude of the 3D vector of the frequency-domain transform of jerk (time derivative) of body angular velocity
----------------------------------------------- | ------------------------------------------------------------------------------------------
