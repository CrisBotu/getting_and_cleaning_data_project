## You should create one R script called run_analysis.R that does the following.

## 1.Merges the training and the test sets to create one data set.
## 2.Extracts only the measurements on the mean and standard deviation for each measurement.
## 3.Uses descriptive activity names to name the activities in the data set
## 4.Appropriately labels the data set with descriptive variable names.
## 5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

rm(list = ls())

# 1. Download the dataset if doesn't exist in the WD

#setwd("D:/Documentos/Coursera/Data Science/3.Getting and Cleaning Data/Project")

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

library(data.table)
library(reshape2)

filename <- "dataset.zip"

if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# 2. Load data activity and data feature info
activityLabels  <- read.table("./UCI HAR Dataset/activity_labels.txt")
features        <- read.table("./UCI HAR Dataset/features.txt")

activityLabels[,2]  <- as.character(activityLabels[,2])
features[,2]        <- as.character(features[,2])

# 3. Extract the names, and cleaning data for mean and standard deviation
extractFeatures       <- grep(".*mean.*|.*std.*",features[,2])
extractFeatures.names <- features[extractFeatures,2]
extractFeatures.names <- gsub("-mean","Mean",extractFeatures.names)
extractFeatures.names <- gsub("-std","Sd",extractFeatures.names)
extractFeatures.names <- gsub("[-()]","",extractFeatures.names)
extractFeatures.names <- gsub("^t", "time", extractFeatures.names)
extractFeatures.names <- gsub("^f", "frequency", extractFeatures.names)
extractFeatures.names <- gsub("Acc", "Accelerometer", extractFeatures.names)
extractFeatures.names <- gsub("Gyro", "Gyroscope", extractFeatures.names)
extractFeatures.names <- gsub("Mag", "Magnitude", extractFeatures.names)
extractFeatures.names <- gsub("BodyBody", "Body", extractFeatures.names)

# 4. Loads the activity and subject data for train and test sets
train           <- read.table("./UCI HAR Dataset/train/X_train.txt")[extractFeatures] #Only the values for Mean|Std
trainActivities <- read.table("./UCI HAR Dataset/train/Y_train.txt")
trainSubjects   <- read.table("./UCI HAR Dataset/train/subject_train.txt")
test            <- read.table("./UCI HAR Dataset/test/X_test.txt")[extractFeatures] #Only the values for Mean|Std
testActivities  <- read.table("./UCI HAR Dataset/test/Y_test.txt")
testSubjects    <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# 5. Bind the 3 data tables for test and train
train <- cbind(trainSubjects, trainActivities, train)
test  <- cbind(testSubjects, testActivities, test)

# 6. Merge datasets into one and add labels
data <- rbind(train, test)
colnames(data) <- c("subject", "activity", extractFeatures.names)

# 7. Converts the activity and subject columns into factors
data$activity <- factor(data$activity, levels = activityLabels[,1], labels = activityLabels[,2])
data$subject <- as.factor(data$subject)

# 8. Create a tidy dataset, first melting data and them getting the mean of the each variable for each subject and activity pair
data.melted <- melt(data, id = c("subject", "activity"))
data.mean <- dcast(data.melted, subject + activity ~ variable, mean)

write.table(data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
