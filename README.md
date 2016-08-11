# 3. Project of Getting and Cleaning Data - Data Scientist Course

This is a script created for the project of Getting and Cleaning Data for the 3rd course of Data Scientist.
The R script receives the name `run_analysis.R`, and does the following things:

1. Download the dataset if doesn't exist in the WorkDirectory
2. Load data activity and data feature info
3. Extract the names, and cleaning data for mean and standard deviation
4. Loads the activity and subject data for train and test sets
5. Bind the 3 data tables for test and train
6. Merge datasets into one and add labels
7. Converts the `activity` and `subject` columns into factors
8. Create a tidy dataset, first melting data and them getting the mean of the each variable for each subject and activity pair

The end result is save in the file `tidy.txt`.
