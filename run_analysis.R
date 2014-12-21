# Load libraries
library(data.table)
library(plyr)
library(dplyr)

# Options
dataDir <- "./data"
zipFile <- file.path(dataDir, "UCI HAR Dataset.zip")
tidyFile <- file.path(dataDir, "tidy.txt")

# Download and unzip datafile
if(!file.exists(dataDir)){dir.create(dataDir)}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile=zipFile)
unzip(zipFile, exdir=dataDir)

## Read data files into variable.
# Read labels
label.features <- read.table( file.path(dataDir, "UCI HAR Dataset", "features.txt"))
label.activity <- read.table( file.path(dataDir, "UCI HAR Dataset", "activity_labels.txt"))

# Read fearures files
feature.train <- read.table( file.path(dataDir, "UCI HAR Dataset", "train", "X_train.txt"))
feature.test <- read.table( file.path(dataDir, "UCI HAR Dataset", "test", "X_test.txt"))

# Read subject files
subject.train <- read.table( file.path(dataDir, "UCI HAR Dataset", "train", "subject_train.txt"))
subject.test <- read.table( file.path(dataDir, "UCI HAR Dataset", "test", "subject_test.txt"))

# Read activity files
activity.train <- read.table( file.path(dataDir, "UCI HAR Dataset", "train", "Y_train.txt"))
activity.test <- read.table( file.path(dataDir, "UCI HAR Dataset", "test", "Y_test.txt"))

## 1. Merge the training and the test sets to create one data set.
# merge data tables
data.features <- rbind(feature.train, feature.test)
data.subject <- rbind(subject.train, subject.test)
data.activity <- rbind(activity.train, activity.test)

names(data.features) <- label.features$V2
names(data.subject) <- c("subject")

# Merge all columns to get one big data frame
# And transform the data frame to data table.
data <- data.table(cbind(data.features, data.subject, data.activity))

## 2. Extract only the measurements on the mean and standard deviation for each measurement
selected.features <- label.features$V2[grep("-mean\\(\\)[-]?|-std\\(\\)[-]", label.features$V2)]
selected.columns <- c(as.character(selected.features), "subject", "activity" )
data <- subset(data, select = selected.columns)

## 3. Use descriptive activity names to name the activities in the data set
names(data.activity) <- c("activity")

## 4. Appropriately label the data set with descriptive variable names 
setnames(data, gsub("^t", "time", names(data)))
setnames(data, gsub("^f", "frequency", names(data)))
setnames(data, gsub("Acc", "Accelerometer", names(data)))
setnames(data, gsub("Gyro", "Gyroscope", names(data)))
setnames(data, gsub("Mag", "Magnitude", names(data)))
setnames(data, gsub("BodyBody", "Body", names(data)))

## 5. From the data set in step 4, creates a second, independent tidy data set 
#     with the average of each variable for each activity and each subject
tidy <- aggregate(. ~subject + activity, data, mean)
tidy <- tidy[order(tidy$subject, tidy$activity), ]
write.table(tidy, file = tidyFile, row.name=FALSE)
