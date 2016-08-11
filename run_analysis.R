## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

rm(list = ls())

# My Work Directorie

setwd("D:/Documentos/Coursera/Data Science/3.Getting and Cleaning Data/Project")

# Library

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

library(data.table)
library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load Data
activityLabels  <- read.table("./UCI HAR Dataset/activity_labels.txt")
features        <- read.table("./UCI HAR Dataset/features.txt")
#X_test          <- read.table("./UCI HAR Dataset/test/X_test.txt")
#y_test          <- read.table("./UCI HAR Dataset/test/y_test.txt")
#subject_test    <- read.table("./UCI HAR Dataset/test/subject_test.txt")

activityLabels[,2] <- as.character(activityLabels[,2])
features[,2] <- as.character(features[,2])

# Extract
extractFeatures       <- grep(".*mean.*|.*std.*",features[,2])
extractFeatures.names <- features[extractFeatures,2]
extractFeatures.names <- gsub("-mean","Mean",extractFeatures.names)
extractFeatures.names <- gsub("-std","Std",extractFeatures.names)
extractFeatures.names <- gsub("[-()]","",extractFeatures.names)

# Load datasets
train           <- read.table("./UCI HAR Dataset/train/X_train.txt")[extractFeatures] #Only the values for Mean|Std
trainActivities <- read.table("./UCI HAR Dataset/train/Y_train.txt")
trainSubjects   <- read.table("./UCI HAR Dataset/train/subject_train.txt")
test            <- read.table("./UCI HAR Dataset/test/X_test.txt")[extractFeatures] #Only the values for Mean|Std
testActivities  <- read.table("./UCI HAR Dataset/test/Y_test.txt")
testSubjects    <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# Bind the 3 data tables for test and train
train <- cbind(trainSubjects, trainActivities, train)
test  <- cbind(testSubjects, testActivities, test)

# Merge datasets and add labels
data <- rbind(train, test)
colnames(data) <- c("subject", "activity", extractFeatures.names)

data$activity <- factor(data$activity, levels = activityLabels[,1], labels = activityLabels[,2])
data$subject <- as.factor(data$subject)

data.melted <- melt(data, id = c("subject", "activity"))
data.mean <- dcast(data.melted, subject + activity ~ variable, mean)

write.table(data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)