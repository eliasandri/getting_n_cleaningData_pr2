library(dplyr)

folder <- "UCI HAR Dataset"
zipFile <- "getdata_projectfiles_UCI HAR Dataset.zip"
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# Check if zip file exists
if(!file.exists(zipFile)) {
  download.file(url, folder, method = 'curl')
}

# check if folder exists
if(!file.exists(folder)) {
  unzip(zipFile)
}

# load the data to variables
# features
features <- read.table("./UCI HAR Dataset/features.txt")
names(features) <- c("number", "feature")
# adjust features names
features$number <- NULL
features$feature <- gsub(",|-|\\(|\\)", "", features$feature)
#
# training & testing sets
xTraining <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names = features$feature)
xTesting <- read.table("./UCI HAR Dataset/test/X_test.txt", col.names = features$feature)
# training & testing labels
yTrainingLabel <- read.table("./UCI HAR Dataset/train/Y_train.txt")
names(yTrainingLabel) <- c("activityNumber")
yTestingLabel <- read.table("./UCI HAR Dataset/test/Y_test.txt")
names(yTestingLabel) <- c("activityNumber")
# training & testing subjects
subjectTraining <- read.table("./UCI HAR Dataset/train/subject_train.txt", col.names = c("subjectNumber"))
subjectTesting <- read.table("./UCI HAR Dataset/test/subject_test.txt", col.names = c("subjectNumber"))
# activity label
activityLabel <- read.table("./UCI HAR Dataset/activity_labels.txt")
names(activityLabel) <- c("activityNumber", "activity")

# row binding xTesting & xTraining
xCombined <- rbind(xTesting, xTraining)
# row binding yTesting & yTraining
yCombined <- rbind(yTestingLabel, yTrainingLabel)
# row binding subjects
subjectsCombined <- rbind(subjectTesting, subjectTraining)

# column binding everything
combinedData <- cbind(subjectsCombined, yCombined, xCombined)

# get std and mean data and subject number and activity
cleanedData<- combinedData %>% select(subjectNumber, activityNumber, contains("mean"), contains("std"))

# get names for activities
cleanedData$activityNumber <- activityLabel[cleanedData$activityNumber, 2]
names(cleanedData)[2] = "activity"

# all columns to lower case
names(cleanedData) <- tolower(names(cleanedData))

# summarzing the data by subject number and activiy
summarizedData<- cleanedData %>%
  group_by(subjectnumber, activity) %>%
  summarise_all(funs(mean))
# writing the table
write.table(summarizedData, "summarizedData.txt", row.name=FALSE)
