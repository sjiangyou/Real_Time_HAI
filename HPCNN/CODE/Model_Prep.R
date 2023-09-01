setwd("~/Documents/sunny/palmetto_high/Grade_10/Sci_Fair_2022/IMERG")
options(scipen = 999)

basin <- 'ATL'
trainend = 2018000000

a <- read.csv("Land_Ocean_Futures.csv", header = TRUE)
a <- a[, -1]

# Only keep values in correct basin and remove land TCs 
data <- a[a$BASIN == basin, ]

columns <- c('GIS_ID', 'DATE', 'STORM_NAME', 'STORM_ID', 'LAND_OCEAN','SHIPS_PER', 
             'SHIPS_POT', 'VMAX')

data_structure <- data.frame(time=c("P06","P12","P18","P24"), 
                             value=c("_2","_3","_4","_5"))

doresample <- function(d, c, n){
  t <- d[d$Category == c, ]
  if(nrow(t) < n){
    t2 <- t[sample(1:nrow(t), n-nrow(t), replace = T),]
    t <- rbind(t,t2)
  }
  return(t)
}

# Predictions

for (i in 1:nrow(data_structure)) {
  x <- data[,c(columns, paste0("VMAX_", data_structure$time[i]), grep(paste0("SHDC", data_structure$value[i]), names(data), value = T), paste0("LO", data_structure$time[i]))]
  
  
  x[x == -999] <- NA
  x <- x[complete.cases(x), ]
  names(x) <- gsub(data_structure$value[i], "", names(x))
  names(x) <- gsub(data_structure$time[i], "FT", names(x))
  x <- x[x$LOFT == 'Ocean', ]
  x <- x[x$LAND_OCEAN == "Ocean", ]
  x$IC <- x$VMAX_FT - x$VMAX
  x$Category <- ifelse(x$VMAX <= 33, "TD", 
                       ifelse(x$VMAX <= 63, "TS", 
                              ifelse(x$VMAX <= 95, "Min", "Maj")))
  
  x_train <- x[x$DATE < trainend, ]
  x_test <- x[x$DATE >= trainend, ]
  assign(paste0(data_structure$time[i], "_train"), x_train)
  assign(paste0(data_structure$time[i], "_test"), x_test)
  
  x_train_resample <- do.call(rbind, lapply(unique(x$Category), function(y) doresample(x,y, max(table(x$Category)))))
  assign(paste0(data_structure$time[i], "_train_resample"), x_train_resample)
  
  write.csv(x_train, file = paste0("IC_Data/", data_structure$time[i], "_", substr(trainend, 1, 4), '_train.csv'))
  write.csv(x_test, file = paste0("IC_Data/", data_structure$time[i], "_", substr(trainend, 1, 4), '_test.csv'))
  write.csv(x_train_resample, file = paste0("IC_Data/", data_structure$time[i], "_", substr(trainend, 1, 4), '_train_resample.csv'))
}

# Estimations

estimate <- data[, c('VMAX', 'VMAX_N06', 'VMAX_N12', 'DATE', 'GIS_ID')]
estimate[estimate == -999] <- NA
estimate <- estimate[complete.cases(estimate),]
estimate$Category <- ifelse(estimate$VMAX <= 33, "TD", 
                            ifelse(estimate$VMAX <= 63, "TS", 
                                   ifelse(estimate$VMAX <= 95, "Min", "Maj")))
estimate_train <- estimate[estimate$DATE < trainend,]
estimate_test <- estimate[estimate$DATE >= trainend,]
estimate_train_resample <- do.call(rbind, lapply(unique(estimate_train$Category), function(y) doresample(estimate_train,y, max(table(estimate_train$Category)))))

write.csv(estimate_train_resample, paste0("Estimation_training_resample", substr(trainend, 1, 4), ".csv"))
write.csv(estimate_test, paste0("Estimation_testing", substr(trainend, 1, 4), ".csv"))

# files <- ls()[grepl("P", ls())]
# for(f in files){
#   write.csv(f, file = paste0("IC_Data/", f, ".csv"))
# }
