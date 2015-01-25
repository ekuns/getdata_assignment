######################################################################
# 0. Clean our environment and ensure that dplyr is loaded.
######################################################################

rm(list = ls())
library(dplyr, warn.conflicts = FALSE)

######################################################################
# 1. Read the data set, applying appropriate column names to every data
# set we read in except for X.Test and X.Train which are done later.
#
# NOTE:  We assume the data is already unzipped and in the folder
# "UCI HAR Dataset" -- git will ignore this folder so we won't accidentally
# commit the data)
######################################################################
# Read the meta-data
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt",
                              col.names=c("activityId", "activityName"))
features <- read.table("UCI HAR Dataset/features.txt",
                       col.names=c("featureIndex", "featureName"))

# Read the test sample data
subject.Test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names=c("subjectId"))
X.Test <- read.table("UCI HAR Dataset/test/X_test.txt")
y.Test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names=c("activityId"))

# Read the training sample data
subject.Train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names=c("subjectId"))
X.Train <- read.table("UCI HAR Dataset/train/X_train.txt")
y.Train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names=c("activityId"))

# Fix the activity level factor names to be more human-friendly.  Lowercase
# everything after the first character.  This code uses Perl regular expressions
# and \L to force lowercase.  It also replaces underscore with blank.
activities <- gsub("(.)(.*)", "\\1\\L\\2", activity_labels$activityName, perl=TRUE)
activities <- gsub("_", " ", activities, fixed=TRUE)
levels(activity_labels$activityName) <- activities

######################################################################
# 2. Appropriately label the data set with descriptive variable names.
#
# Clean the feature names we read from features.txt and turn them into proper
# column names.  We only rename the parts of names related to names we will keep
# later.  For example, we don't care about giving pretty names to the
# "bandsEnergy_XX_XX" columns since we'll drop them later.  We could do this
# step later, but our sanity check at the end relies on the training and test
# samples having the same column names as our final sample (for those columns
# that are in both).
######################################################################

# Use chaining to do a series of gsub substitutions in a row.  (Chaining is awesome)
featureList <- as.character(features$featureName) %>%
  gsub(pattern="-|,|\\(", replace="_") %>%
  gsub(pattern="_\\)?_+", replace="_") %>%
  gsub(pattern="_+\\)?$|\\)", replace="") %>%
  gsub(pattern="tBody", replace="Body") %>%
  gsub(pattern="fBody|fBodyBody", replace="frequency_Body") %>%
  gsub(pattern="tGravity", replace="Gravity") %>%
  gsub(pattern="Mag", replace="_Magnitude") %>%
  gsub(pattern="Acc", replace="_Acceleration") %>%
  gsub(pattern="Jerk", replace="_Jerk") %>%
  gsub(pattern="Gyro", replace="_Gyroscopic") %>%
  make.names(unique = TRUE)
names(X.Train) <- featureList
names(X.Test) <- featureList

######################################################################
# 3. Merge the training and the test sets to create one data set.
######################################################################

subject <- rbind(subject.Train, subject.Test)
X <- rbind(X.Train, X.Test)
y <- rbind(y.Train, y.Test)

# Create an ID equal to row index so we can safely merge the activity ID and
# subject ID with the data.
y$id <- 1:nrow(y)
subject$id <- 1:nrow(subject)
X$id <- 1:nrow(X)

# Merge the three data sets on the ID column we just created
merged_X <- merge(merge(X, y, by="id"), subject, by="id")

######################################################################
# 4. Extract only the measurements on the mean and standard deviation
# for each measurement.
#
# "meanFreq" is not included.  The requirement is: "mean and standard deviation
# for each measurement," not "mean and standard deviation and weighted mean
# frequency of each measurement."  See CodeBook.md for more information.
######################################################################

reduced_X <- select(merged_X, activityId, subjectId, contains("_mean"), contains("_std"),
                    -contains("_meanFreq"))

######################################################################
# 5. Use descriptive activity names to name the activities in the data set
######################################################################

# Replace activityId (an index) with activityName (a factor)
reduced_X$activityName <- factor(reduced_X$activityId, activity_labels$activityId, activity_labels$activityName)
reduced_X <- select(reduced_X, -activityId)

######################################################################
# 6. From the data set from the last step, creates a second, independent tidy
# data set with the average of each variable for each activity and each subject.
# Write this to a text file created with write.table() using row.name=FALSE.
######################################################################

# Here is our tidy data
summarized <- reduced_X %>% group_by(subjectId, activityName) %>% summarise_each(funs(mean))
write.table(summarized, file="summarized_data.txt", row.name=FALSE)

######################################################################
# At this point, the assignment is complete.   Code below this point exists to
# cross-check the summarized tidy data to be sure the algorithm is correct and
# to clean the environment of data.frames and other objects that are no longer
# necessary.
######################################################################

# This method performs a cross-check on the final summarized data, comparing
# against the data.frames read from disk.  It takes a column to check (by name),
# a subject to check by integer subject ID, and an activity to check by integer
# activity ID.
# Returns: TRUE if the check passes, FALSE if it fails.
maxAcceptableDelta <- 0.000001
sanityCheck <- function(colToCheck, subjectToCheck, activityToCheck) {
  # Calculate the expected mean for this column, subject, and activity using the
  # original data.frames from the original data
  train.list <- X.Train[y.Train == activityToCheck & subject.Train == subjectToCheck, ][[colToCheck]]
  test.list <- X.Test[y.Test == activityToCheck & subject.Test == subjectToCheck, ][[colToCheck]]
  expected_subject_1_walking_mean <- mean(c(train.list, test.list))

  # Get the name of the activity we are checking
  selectedActivityName <- subset(activity_labels, activityId == activityToCheck)$activityName

  # Fetch the value we calculated in our summary
  actual_subject_1_walking_mean <- summarized[summarized$subjectId == subjectToCheck & summarized$activityName == selectedActivityName, ][[colToCheck]]

  # Compare the two and warn if there is a difference.  Since we're comparing
  # floating point numbers, allow a very small difference.  We know these numbers
  # are bounded between -1 and 1, so we can safely pick an absolute number
  # for the check
  delta <- abs(actual_subject_1_walking_mean - expected_subject_1_walking_mean)
  success <- (delta < maxAcceptableDelta)
  if (!success) {
    warning(paste("Delta is bigger than expected for column ", colToCheck, ", subject ",
                  subjectToCheck, ", activity ", selectedActivityName, " -- ",
                  actual_subject_1_walking_mean, " != ", expected_subject_1_walking_mean,
                  sep=""))
  } else {
    message(paste("All good for column ", colToCheck, ", subject ", subjectToCheck,
                  ", activity ", selectedActivityName,
                  sep=""))
  }

  success
}

errorCount <- 0

# Test subject one for the first column for all six activities
errorCount <- errorCount + (sanityCheck("Body_Acceleration_mean_X", 1, 1) == FALSE)
errorCount <- errorCount + (sanityCheck("Body_Acceleration_mean_X", 1, 2) == FALSE)
errorCount <- errorCount + (sanityCheck("Body_Acceleration_mean_X", 1, 3) == FALSE)
errorCount <- errorCount + (sanityCheck("Body_Acceleration_mean_X", 1, 4) == FALSE)
errorCount <- errorCount + (sanityCheck("Body_Acceleration_mean_X", 1, 5) == FALSE)
errorCount <- errorCount + (sanityCheck("Body_Acceleration_mean_X", 1, 6) == FALSE)

# Test 10 more elements, selected at random -- set a seed so this test is reproducible
set.seed(314156)
for (loop in 1:10) {
  # Pick a random measurement column, subject, and activity
  randomColumn <- sample(names(summarized)[3:length(summarized)], 1)
  randomSubject <- sample(1:30, 1)
  randomActivity <- sample(1:6, 1)
  errorCount <- errorCount + (sanityCheck(randomColumn, randomSubject, randomActivity) == FALSE)
}

if (errorCount > 0) {
  warning("********************************")
  warning("Check the code or environment, the cross-check failed")
  warning("********************************")
}

#################################
# Clean up the environment
#################################

rm(X.Test)
rm(X.Train)
rm(subject.Test)
rm(subject.Train)
rm(subject)
rm(y.Test)
rm(y.Train)
rm(y)

rm(activities)
rm(activity_labels)
rm(features)

rm(featureList)

rm(merged_X)
rm(loop)
rm(randomActivity)
rm(randomColumn)
rm(randomSubject)
rm(errorCount)
rm(maxAcceptableDelta)
