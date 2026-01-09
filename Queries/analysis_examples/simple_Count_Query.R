library(dplyr)
tumorData <- read.csv("./TumorExample.csv", sep=",")
tumorData %>% count(cTNM_T) %>% arrange(desc(n))