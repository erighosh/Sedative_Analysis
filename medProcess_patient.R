# cohort_patients = read.csv("cohort_consildation_2.csv", stringsAsFactors = FALSE)
# the code is for analyzingdiurnal difference in the benzo, opiod, propofol and precedex subgroups 


cohort_benzo = subset(cohort_patients,benzo > 0)
nrow(cohort_benzo)
cohort_opiod = subset(cohort_patients,opiod > 0)
nrow(cohort_opiod)
cohort_propofol = subset(cohort_patients, propofol > 0)
nrow(cohort_propofol)
cohort_precedex = subset(cohort_patients, precedex >0)
nrow(cohort_precedex)

##### Calculate hourly med use for day and night
cohort_benzo$D_benzo_hourly = cohort_benzo$D_benzo/cohort_benzo$dayHrs
cohort_benzo$N_benzo_hourly = cohort_benzo$N_benzo/cohort_benzo$nightHrs
cohort_benzo$benzoDiff = cohort_benzo$D_benzo_hourly - cohort_benzo$N_benzo_hourly

cohort_opiod$D_opiod_hourly = cohort_opiod$D_opiod/cohort_opiod$dayHrs
cohort_opiod$N_opiod_hourly = cohort_opiod$N_opiod/cohort_opiod$nightHrs
cohort_opiod$opiodDiff = cohort_opiod$D_opiod_hourly - cohort_opiod$N_opiod_hourly

cohort_propofol$D_propofol_hourly = cohort_propofol$D_propofol/cohort_propofol$dayHrs
cohort_propofol$N_propofol_hourly = cohort_propofol$N_propofol/cohort_propofol$nightHrs
cohort_propofol$propofolDiff = cohort_propofol$D_propofol_hourly - cohort_propofol$N_propofol_hourly

cohort_precedex$D_precedex_hourly = cohort_precedex$D_precedex/cohort_precedex$dayHrs
cohort_precedex$N_precedex_hourly = cohort_precedex$N_precedex/cohort_precedex$nightHrs
cohort_precedex$precedexDiff = cohort_precedex$D_precedex_hourly - cohort_precedex$N_precedex_hourly

############ 
##### exclude patients whose hourly med use is outlier
# benzoTotalLQ = quantile(cohort_benzo$benzo/cohort_benzo$duration_hours)[2]
# benzoTotalUQ = quantile(cohort_benzo$benzo/cohort_benzo$duration_hours)[4]
# benzoTotalIQR = benzoTotalUQ - benzoTotalLQ
# benzoTotalLT = benzoTotalLQ - benzoTotalIQR * 1.5
# benzoTotalUT = benzoTotalUQ + benzoTotalIQR * 1.5
# nrow(cohort_benzo)
# cohort_benzo = subset(cohort_benzo, benzo/duration_hours >= benzoTotalLT & benzo/duration_hours <= benzoTotalUT)
# nrow(cohort_benzo)
# 
# opiodTotalLQ = quantile(cohort_opiod$opiod/cohort_opiod$duration_hours)[2]
# opiodTotalUQ = quantile(cohort_opiod$opiod/cohort_opiod$duration_hours)[4]
# opiodTotalIQR = opiodTotalUQ - opiodTotalLQ
# opiodTotalLT = opiodTotalLQ - opiodTotalIQR * 1.5
# opiodTotalUT = opiodTotalUQ + opiodTotalIQR * 1.5
# nrow(cohort_opiod)
# cohort_opiod = subset(cohort_opiod, opiod/duration_hours >= opiodTotalLT & opiod/duration_hours <= opiodTotalUT)
# nrow(cohort_opiod)
# 
# propofolTotalLQ = quantile(cohort_propofol$propofol/cohort_propofol$duration_hours)[2]
# propofolTotalUQ = quantile(cohort_propofol$propofol/cohort_propofol$duration_hours)[4]
# propofolTotalIQR = propofolTotalUQ - propofolTotalLQ
# propofolTotalLT = propofolTotalLQ - propofolTotalIQR * 1.5
# propofolTotalUT = propofolTotalUQ + propofolTotalIQR * 1.5
# nrow(cohort_propofol)
# cohort_propofol = subset(cohort_propofol, propofol/duration_hours >= propofolTotalLT & propofol/duration_hours <= propofolTotalUT)
# nrow(cohort_propofol)
# 
# precedexTotalLQ = quantile(cohort_precedex$precedex/cohort_precedex$duration_hours)[2]
# precedexTotalUQ = quantile(cohort_precedex$precedex/cohort_precedex$duration_hours)[4]
# precedexTotalIQR = precedexTotalUQ - precedexTotalLQ
# precedexTotalLT = precedexTotalLQ - precedexTotalIQR * 1.5
# precedexTotalUT = precedexTotalUQ + precedexTotalIQR * 1.5
# nrow(cohort_precedex)
# cohort_precedex = subset(cohort_precedex, precedex/duration_hours >= precedexTotalLT & precedex/duration_hours <= precedexTotalUT)
# nrow(cohort_precedex)


#############
## boxplot to check whether the cohort satisfies the assumptions of paired t test
# par(mfrow = c(2,2))
# boxplot(cohort_benzo$benzoDiff, main = "benzo")
# boxplot(cohort_opiod$opiodDiff, main = "opiod")
# boxplot(cohort_propofol$propofolDiff, main = "propofol")
# boxplot(cohort_precedex$precedexDiff, main = "precedex")

##### calculate the number of outliers for benzo group
mean(cohort_benzo$benzoDiff)
median(cohort_benzo$benzoDiff)
# calculate lower and upper quantile, and IQR of benzoDiff
benzoLQ = quantile(cohort_benzo$benzoDiff)[2]
benzoUQ = quantile(cohort_benzo$benzoDiff)[4]
benzoIQR = benzoUQ - benzoLQ
# lower and upper threshold for extreme outliers
benzoLT = benzoLQ - benzoIQR * 1.5
benzoUT = benzoUQ + benzoIQR * 1.5
cohort_benzoOutlier = subset(cohort_benzo, benzoDiff > benzoUT | benzoDiff < benzoLT)
nrow(cohort_benzoOutlier)
nrow(cohort_benzo)

######### calculate the number of outliers for opiod group
mean(cohort_opiod$opiodDiff)
median(cohort_opiod$opiodDiff)
# calculate lower and upper quantile, and IQR of opiodDiff
opiodLQ = quantile(cohort_opiod$opiodDiff)[2]
opiodUQ = quantile(cohort_opiod$opiodDiff)[4]
opiodIQR = opiodUQ - opiodLQ
# lower and upper threshold for extreme outliers
opiodLT = opiodLQ - opiodIQR * 1.5
opiodUT = opiodUQ + opiodIQR * 1.5
cohort_opiodOutlier = subset(cohort_opiod, opiodDiff > opiodUT | opiodDiff < opiodLT)
nrow(cohort_opiodOutlier)
nrow(cohort_opiod)

#### calculate the number of outliers for propofol group
mean(cohort_propofol$propofolDiff)
median(cohort_propofol$propofolDiff)
#calculate lower and upper quantile, and IQR of propofolDiff
propofolLQ = quantile(cohort_propofol$propofolDiff)[2]
propofolUQ = quantile(cohort_propofol$propofolDiff)[4]
propofolIQR = propofolUQ - propofolLQ
# lower and upper threshold for extreme outliers
propofolLT = propofolLQ - propofolIQR * 1.5
propofolUT = propofolUQ + propofolIQR * 1.5
cohort_propofolOutlier = subset(cohort_propofol, propofolDiff > propofolUT | propofolDiff < propofolLT)
nrow(cohort_propofolOutlier)
nrow(cohort_propofol)

####### calculate the number of outliers for precedex group
mean(cohort_precedex$precedexDiff)
median(cohort_precedex$precedexDiff)
#calculate lower and upper quantile, and IQR of precedexDiff
precedexLQ = quantile(cohort_precedex$precedexDiff)[2]
precedexUQ = quantile(cohort_precedex$precedexDiff)[4]
precedexIQR = precedexUQ - precedexLQ
# lower and upper threshold for extreme outliers
precedexLT = precedexLQ - precedexIQR * 1.5
precedexUT = precedexUQ + precedexIQR * 1.5
cohort_precedexOutlier = subset(cohort_precedex, precedexDiff > precedexUT | precedexDiff < precedexLT)
nrow(cohort_precedexOutlier)
nrow(cohort_precedex)


#####
### use wilcox paired signed rank test, for statistics of non-normalized distributions
wilcox.test(cohort_benzo$D_benzo_hourly, cohort_benzo$N_benzo_hourly, conf.int = TRUE, paired = TRUE)
median(cohort_benzo$D_benzo_hourly-cohort_benzo$N_benzo_hourly)
wilcox.test(cohort_opiod$D_opiod_hourly, cohort_opiod$N_opiod_hourly, conf.int = TRUE, paired = TRUE)
median(cohort_opiod$D_opiod_hourly-cohort_opiod$N_opiod_hourly)
wilcox.test(cohort_propofol$D_propofol_hourly, cohort_propofol$N_propofol_hourly, conf.int = TRUE, paired = TRUE)
median(cohort_propofol$D_propofol_hourly-cohort_propofol$N_propofol_hourly)
wilcox.test(cohort_precedex$D_precedex_hourly, cohort_precedex$N_precedex_hourly, conf.int = TRUE, paired = TRUE)
median(cohort_precedex$D_precedex_hourly-cohort_precedex$N_precedex_hourly)


