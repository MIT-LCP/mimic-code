library(rpart)
require("RPostgreSQL")
library(Amelia)
library(plyr)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "mimic",
                 host = "localhost", port = 5432,
                 user = "postgres", password = "lasdkjf")

data <- dbGetQuery(con,"Select * from mimiciii.log_table")

data$avgperc[is.na(data$avgperc)] <- mean(data$avgperc,na.rm=T)
data$avgbp[is.na(data$avgbp)] <- mean(data$avgbp,na.rm=T)
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

model<-rpart(expire~ avgbp + avgmgdl + avgkul + avggdl + avgcmh2o + avgmeql + avgunits,data=train,method="anova")
#plot(model, uniform=TRUE, main="Regression Tree for Mileage ")
#text(model, use.n=TRUE, all=TRUE, cex=.8)
hello<-model$cptable[which.min(model$cptable[,"xerror"]),"CP"]

pruned<-prune(model,cp=.01)
pred <- predict(pruned,newdata=subset(test,select=c(2,4,5,6,8,9,10)))
pred <- ifelse(pred > 0.5,1,0)

print(paste('Accuracy',mean(pred==test[,3])))
plot(pruned, uniform=TRUE, main="Pruned Regression Tree for Mileage")
text(pruned, use.n=TRUE, all=TRUE, cex=.8)
dbDisconnect(con)
