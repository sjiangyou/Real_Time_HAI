setwd('~/Programs/Real_Time_HAI/')
options(scipen = 999)
trainend <- 2018000000

all_data <- read.csv('BRTK_SHIPS_2000to2019_IMERG_OK_Request_2023_FINAL.csv')
all_data <- all_data[, 1:14]
all_data[all_data == -999] <- NA
all_data <- all_data[complete.cases(all_data), ]

train <- all_data[all_data$DATE < trainend, ]
test <- all_data[all_data$DATE >= trainend, ]

doresample <- function(d, c, n){
  t <- d[d$CAT == c, ]
  if(nrow(t) < n){
    t2 <- t[sample(1:nrow(t), n-nrow(t), replace = T),]
    t <- rbind(t,t2)
  }
  return(t)
}

train$CAT <- ifelse(train$VMAX <= 33, "TD", 
                      ifelse(train$VMAX <= 63, "TS", 
                            ifelse(train$VMAX <= 95, "Min", "Maj")))

test$CAT <- ifelse(test$VMAX <= 33, "TD", 
                      ifelse(test$VMAX <= 63, "TS", 
                            ifelse(test$VMAX <= 95, "Min", "Maj"))

train_resample <- do.call(rbind, lapply(unique(train$CAT), function(y) doresample(train,y, max(table(train$CAT)))))
nrow(train_resample[train_resample$CAT == 'TD', ])
nrow(train_resample[train_resample$CAT == 'TS', ])
nrow(train_resample[train_resample$CAT == 'Min', ])
nrow(train_resample[train_resample$CAT == 'Maj', ])


write.csv(train, 'HIECNN/IMERG/DEV/ALL_TRAIN_DATA.csv')
write.csv(test, 'HIECNN/IMERG/DEV/ALL_TEST_DATA.csv')
write.csv(train_resample, 'HIECNN/IMERG/DEV/ALL_TRAIN_DATA_RESAMPLE.csv')
