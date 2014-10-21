###set working directory to appropriate location
setwd("/Users/jlchang/Documents/jean/private/Coursera/DataSci/3CleaningData/CourseProject")

###Download and uncompress data set IF it is not already available locally
target_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
target_localfile = "getdata_projectfiles_UCI HAR Dataset.zip"
if (!file.exists(target_localfile)) {
  download.file(target_url, target_localfile, method="curl") #may need modifying if binary etc
  library(tools)       # for md5 checksum
  sink("download_metadata.txt")
  print("Download date:")
  print(Sys.time() )
  print("Download URL:")
  print(target_url)
  print("Downloaded file Information")
  print(file.info(target_localfile))
  print("Downloaded file md5 Checksum")
  print(md5sum(target_localfile))
  sink()
} else {
  print("starting dataset already downloaded")
}
uncompressed_localfile= "UCI HAR Dataset"
if (!file.exists(uncompressed_localfile)) {
  unzip(target_localfile)
} else {
  print("starting dataset already uncompressed")
} 

###ingest single column data inputs into R
train_subj <-  read.table("UCI HAR Dataset/train/subject_train.txt", colClasses = "factor", header=F,sep="")
train_activity <-  read.table("UCI HAR Dataset/train/y_train.txt", colClasses = "factor",header=F,sep="")
test_subj <-  read.table("UCI HAR Dataset/test/subject_test.txt", colClasses = "factor", header=F,sep="")
test_activity <-  read.table("UCI HAR Dataset/test/y_test.txt", colClasses = "factor",header=F,sep="")

###merge train and test data
activity <- rbind(train_activity,test_activity)
subject <- rbind(train_subj,test_subj)
names(activity) <- "activity"
names(subject) <- "subject"
#clean up workspace - remove unneeded objects
rm(train_subj,train_activity,test_subj,test_activity)

###replace activity numbers with descriptive activity names
#activity <- gsub("1","WALKING",activity)
#activity <- gsub("2","WALKING_UPSTAIRS",activity)
#activity <- gsub("3","WALKING_DOWNSTAIRS",activity)
#activity <- gsub("4","SITTING",activity)
#activity <- gsub("5","STANDING",activity)
#activity <- gsub("6","LAYING",activity)
#TODO### instead of hardcoding as above, pull in activity_labels info and gsub values into activity
#activity_map <- read.table("UCI HAR Dataset/activity_labels.txt",header=F,sep="")
activity$activity <- factor(activity$activity, labels = c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING"))

###load desired column of features.txt file
###mycols is device to skip loading the first column into memory - may turn out to need those indices...
mycols <- c("NULL", "character")
feature_names <- unlist(read.table("UCI HAR Dataset/features.txt",colClasses=mycols, sep=""))

###identify subset of mean and std features from full feature list
#desired_feature_indices <- grep("mean|std", clean_feature_names)
#desired_feature_indices <- grep("mean\\(\\)|std\\(\\)", feature_names)
desired_feature_indicesL <- grepl("mean\\(\\)|std\\(\\)", feature_names)
#desired_features <- feature_names[desired_feature_indices]

###remove invalid characters from feature names
#lapply(feature_names, )
clean_feature_names <- gsub('\\(', "", feature_names)
clean_feature_names <- gsub("\\)", "", clean_feature_names)
clean_feature_names <- gsub("-", "_", clean_feature_names)
clean_feature_names <- gsub("\\,", "_", clean_feature_names)
clean_feature_names <- gsub("BodyBody", "Body", clean_feature_names)
###set column names to labels from features.txt

### Give X columns the feature names from features.txt
### pull only desired columns into data set with desired_feature_indices
### create desired_cols vector to restrict loaded features
#load training and test set
train_X <- read.table("UCI HAR Dataset/train/X_train.txt",header=F, col.names = clean_feature_names, sep="")
train_X_sub <- train_X[desired_feature_indicesL]
test_X <- read.table("UCI HAR Dataset/test/X_test.txt",header=F,col.names = clean_feature_names, sep="")
test_X_sub <- test_X[desired_feature_indicesL]

#combine in same order as subj and activity data
combo_X <- rbind(train_X_sub,test_X_sub)

##align subject, activity and X data in one data frame
combo <- cbind(subject, activity, combo_X)

#clean up workspace - remove unneeded objects
rm(train_X, test_X, train_X_sub, test_X_sub, feature_names,clean_feature_names, subject, activity, combo_X, desired_feature_indicesL, mycols)

all_names <- names(combo)
means <- all_names[-(1:2)]


###manipulate data for desired summarized data
#test <- c("tBodyAcc_mean_X","fBodyAccJerkMag_mean")
#foo <- c("tBodyAcc_mean_X")
#following works (single value)
#final <- by(combo[,foo],INDICES=list(combo$subject,combo$activity), FUN=mean)
#following works (for multiple values, need to use colMeans)
#final <- by(combo[,test],INDICES=list(combo$subject,combo$activity), FUN=colMeans)
#following works (tapply instead of by)
#single <- tapply(X=combo$fBodyGyroJerkMag_std,INDEX=list(combo$subject,combo$activity), FUN=mean)
final <- by(combo[,means],INDICES=list(combo$subject,combo$activity), FUN=colMeans)
