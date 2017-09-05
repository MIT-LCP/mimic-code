require("RPostgreSQL")
library(Amelia)
library(plyr)

#connect SQL database to R
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "mimic",
                 host = "localhost", port = 5432,
                 user = "postgres", password = "")

data <- dbGetQuery(con,"Select * from mimiciii.log_table")

#fills empty cells with the average from that column
data$avgbp[is.na(data$avgbp)] <- mean(data$avgbp,na.rm=T)
data$avgperc[is.na(data$avgperc)] <- mean(data$avgperc,na.rm=T)
data$avggdl[is.na(data$avggdl)] <- mean(data$avggdl,na.rm=T)
data$avgkul[is.na(data$avgkul)] <- mean(data$avgkul,na.rm=T)
data$avgunits[is.na(data$avgunits)] <- mean(data$avgunits,na.rm=T)
data$avgmgdl[is.na(data$avgmgdl)] <- mean(data$avgmgdl,na.rm=T)
data$avgcmh2o[is.na(data$avgcmh2o)] <- mean(data$avgcmh2o,na.rm=T)
data$avglmin[is.na(data$avglmin)] <- mean(data$avglmin,na.rm=T)
data$avgmeql[is.na(data$avgmeql)] <- mean(data$avgmeql,na.rm=T)
data$avgkg[is.na(data$avgkg)] <- mean(data$avgkg,na.rm=T)

train <- data[1:48000,]
test <- data[48001:49444,]

#trains the logistic regression model
model <- glm(expire ~ avgbp + avgmgdl + avgkul + avggdl + avgcmh2o + avgmeql + avgunits,family=binomial(link='logit'),data=train)

#give a summary of the regression model
summary(model)

#uses the model on the test data set
fitted.results <- predict(model,newdata=subset(test,select=c(2,4,5,6,8,9,10)),type='response')

#if the probability of death is >.5, say that the patient has died
fitted.results <- ifelse(fitted.results > 0.5,1,0)

#compare with the actual data to see the % error 
Error <- mean(fitted.results != test$expire)
print(paste(mean(test[,3])))
print(paste('Accuracy',1-Error))
dbDisconnect(con)


