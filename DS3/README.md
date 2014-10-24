This code assumes the necessary data file (downloadable from "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip") is available in the current working directory where run_analysis.R is located

The data set has three types of data:
- feature data, 561 columns of data derived from accelerometer and gyroscope data
- subject data, a single column of data indicating the individual who was measured
- activity data, a single column of data indicating the type of activity 
> 1 WALKING
> 2 WALKING_UPSTAIRS
> 3 WALKING_DOWNSTAIRS
> 4 SITTING
> 5 STANDING
> 6 LAYING

The data set was also divided into two parts, a training set and a test set.

Refer to codebook.md for a data codebook on the output of run_analysis.R

To obtain the second, independent tidy data set for the course project, the following steps were taken:

First, **merge the training and the test set** for Subject data:
```
train_subj <-  read.table("UCI HAR Dataset/train/subject_train.txt", colClasses = "factor", col.names = "subject", header=F,sep="")
test_subj <-  read.table("UCI HAR Dataset/test/subject_test.txt", colClasses = "factor", col.names = "subject", header=F,sep="")
subject <- rbind(train_subj,test_subj)
```

Second, **merge the training and the test set** for Activity data:
```
train_activity <-  read.table("UCI HAR Dataset/train/y_train.txt", colClasses = "factor", col.names = "activity", header=F,sep="")
test_activity <-  read.table("UCI HAR Dataset/test/y_test.txt", colClasses = "factor", col.names = "activity", header=F,sep="")
activity <- rbind(train_activity,test_activity)
```

Apply **descriptive activity names to the activities in the data set** setting factor labels as indicated in activity_labels.txt
```
activity$activity <- factor(activity$activity, labels = c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING"))
```


From full feature list, **identify the measurements on the mean and standard deviation for each measurement** by looking for "mean()" and "std()" creating a logical vector for data extraction
```
desired_feature_indices <- grepl("mean\\(\\)|std\\(\\)", feature_names)
```

**Appropriately label the data set with descriptive variable names** by removing characters that are inappropriate in standard variable names (ie. characters that can cause issues for some types of code)
also correct non-meaningful duplication of text on "BodyBody"
```
clean_feature_names <- gsub('\\(', "", feature_names)
clean_feature_names <- gsub("\\)", "", clean_feature_names)
clean_feature_names <- gsub("-", "_", clean_feature_names)
clean_feature_names <- gsub("\\,", "_", clean_feature_names)
clean_feature_names <- gsub("BodyBody", "Body", clean_feature_names)
```

Load feature training and test sets and subset to **extract only the measurements on the mean and standard deviation for each measurement** (ie. selectively choose only the data columns ending in "mean()" and "std()") using logical vector "desired_feature_indices"
```
train_X <- read.table("UCI HAR Dataset/train/X_train.txt",header=F, col.names = clean_feature_names, sep="")
test_X <- read.table("UCI HAR Dataset/test/X_test.txt",header=F,col.names = clean_feature_names, sep="")
train_X_sub <- train_X[desired_feature_indices]
test_X_sub <- test_X[desired_feature_indices]
```

Third, **merge the training and the test set** for Feature data:
```
combo_X <- rbind(train_X_sub,test_X_sub)
```

Align subject, activity, and feature data ("combo_X") and merge into one data set:
```
combo <- cbind(subject, activity, combo_X)
```

Finally, **create a second, independent tidy data set with the average of each variable for each activity and each subject** using the plyr library
```
new_tidy <- ddply(combo, c("subject","activity"),numcolwise(mean) )
```

Write the resulting data frame to a file, "tidy_data.txt" and upload the resulting new tidy data set
```
write.table(new_tidy, file = "tidy_data.txt", row.name=FALSE)
```

Note to graders: You can use the following command to reconstitute the data frame in R from tidy_data.txt
```
reconst <- read.table("tidy_data.txt", header = TRUE)
```
