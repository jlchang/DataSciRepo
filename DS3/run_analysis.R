###merge the training and the test set for Subject data:
train_subj <-  read.table("UCI HAR Dataset/train/subject_train.txt", colClasses = "factor", col.names = "subject", header=F,sep="")
test_subj <-  read.table("UCI HAR Dataset/test/subject_test.txt", colClasses = "factor", col.names = "subject", header=F,sep="")
subject <- rbind(train_subj,test_subj)

###merge the training and the test set for Activity data:
train_activity <-  read.table("UCI HAR Dataset/train/y_train.txt", colClasses = "factor", col.names = "activity", header=F,sep="")
test_activity <-  read.table("UCI HAR Dataset/test/y_test.txt", colClasses = "factor", col.names = "activity", header=F,sep="")
activity <- rbind(train_activity,test_activity)

###clean up workspace - remove unneeded objects
rm(train_subj,train_activity,test_subj,test_activity)

###apply descriptive activity names to the activities in the data set, setting factor labels as indicated in activity_labels.txt
activity$activity <- factor(activity$activity, labels = c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING"))

###load desired column of features.txt file
feature_names <- unlist(read.table("UCI HAR Dataset/features.txt",colClasses=c("NULL", "character"), sep=""))

###From full feature list, identify the measurements on the mean and standard deviation for each measurement by looking for "mean()" and "std()" creating a logical vector for data extraction
desired_feature_indices <- grepl("mean\\(\\)|std\\(\\)", feature_names)

###Appropriately label the data set with descriptive variable names by removing characters that are inappropriate in standard variable names
#also correct non-meaningful duplication of text in "BodyBody"
clean_feature_names <- gsub('\\(', "", feature_names)
clean_feature_names <- gsub("\\)", "", clean_feature_names)
clean_feature_names <- gsub("-", "_", clean_feature_names)
clean_feature_names <- gsub("\\,", "_", clean_feature_names)
clean_feature_names <- gsub("BodyBody", "Body", clean_feature_names)

###Load feature training and test sets and subset to extract only the measurements on the mean and standard deviation for each measurement using logical vector "desired_feature_indices"
train_X <- read.table("UCI HAR Dataset/train/X_train.txt",header=F, col.names = clean_feature_names, sep="")
test_X <- read.table("UCI HAR Dataset/test/X_test.txt",header=F,col.names = clean_feature_names, sep="")
train_X_sub <- train_X[desired_feature_indices]
test_X_sub <- test_X[desired_feature_indices]

###merge the training and the test set for Feature data:
combo_X <- rbind(train_X_sub,test_X_sub)

##Align subject, activity, and feature data ("combo_X") and merge into one data set:
combo <- cbind(subject, activity, combo_X)

#clean up workspace - remove unneeded objects
rm(train_X, test_X, train_X_sub, test_X_sub, feature_names,clean_feature_names, subject, activity, combo_X, desired_feature_indices)


###Create a second, independent tidy data set with the average of each variable for each activity and each subject
library(plyr)
new_tidy <- ddply(combo, c("subject","activity"),numcolwise(mean) )

###Write output to file, "tidy_data.txt"
write.table(new_tidy, file = "tidy_data.txt", row.name=FALSE)
#to reconstitute the data frame from tidy_data.txt
#reconst <- read.table("tidy_data.txt", header = TRUE)

