#STEP0: Set my wd
setwd("D:/R-Projekte/Coursera_Getting and cleaning data/Course Project")

install.packages("reshape2")
library(reshape2)


#STEP1: Downlaod data from web
RohDatenDir <- "./RohDaten"
RohDatenUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
RohDatenDateiname <- "RohDaten.zip"
RohDatenDFn <- paste(RohDatenDir, "/", "RohDaten.zip", sep = "")
dataDir <- "./data"

#STEP1.1 Check if directory exists - or create it

if (!file.exists(RohDatenDir)) {
        dir.create(RohDatenDir)
        download.file(url = RohDatenUrl, destfile = RohDatenDFn)
}
if (!file.exists(dataDir)) {
        dir.create(dataDir)
        unzip(zipfile = RohDatenDFn, exdir = dataDir)
}

#STEP2: Load and Merge data

#STEP2.1: Load train data
x_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/X_train.txt"))
y_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/Y_train.txt"))
s_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/subject_train.txt"))

#STEP2.2: Load test data
x_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/Y_test.txt"))
s_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/subject_test.txt"))

#STEP2.3: Merge data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)

#STEP3: Add meaningful information to the data

features <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/features.txt"))

a_label <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/activity_labels.txt"))
a_label[,2] <- as.character(a_label[,2])


#STEP4: Get columns and names 'mean, std'
Spalten <- grep("-(mean|std).*", as.character(features[,2]))
SpaltenNamen <- features[Spalten, 2]
SpaltenNamen <- gsub("-mean", "Mean", SpaltenNamen)
SpaltenNamen <- gsub("-std", "Std", SpaltenNamen)
SpaltenNamen <- gsub("[-()]", "", SpaltenNamen)

#STEP5: Get data by cols & using descriptive name
x_data <- x_data[Spalten]
allData <- cbind(s_data, y_data, x_data)
colnames(allData) <- c("Subject", "Activity", SpaltenNamen)


allData$Activity <- factor(allData$Activity, levels = a_label[,1], labels = a_label[,2])
allData$Subject <- as.factor(allData$Subject)

#STEP6: Tidy data and write a new table
meltedData <- melt(allData, id = c("Subject", "Activity"))
tidyData <- dcast(meltedData, Subject + Activity ~ variable, mean)

write.table(tidyData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)

