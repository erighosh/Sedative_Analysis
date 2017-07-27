# cohort_patients = read.csv("cohort_consildation_2.csv", stringsAsFactors = FALSE)
# The code analyze the subgroup of MICU vs SICU


cohort_Medical = subset(cohort_patients, last_careunit == "MICU" | last_careunit == "CCU")
cohort_Surgical = subset(cohort_patients, last_careunit == "SICU" | last_careunit == "CSRU" | last_careunit == "TSICU")
nrow(cohort_Medical)
nrow(cohort_Surgical)
nrow(cohort_patients)

cohort_Medical_benzo = subset(cohort_Medical, benzo > 0)
cohort_Surgical_benzo = subset(cohort_Surgical, benzo > 0)

cohort_Medical_opiod = subset(cohort_Medical, opiod > 0)
cohort_Surgical_opiod = subset(cohort_Surgical, opiod > 0)

cohort_Medical_propofol = subset(cohort_Medical, propofol > 0)
cohort_Surgical_propofol = subset(cohort_Surgical, propofol > 0)

cohort_Medical_precedex = subset(cohort_Medical, precedex > 0)
cohort_Surgical_precedex = subset(cohort_Surgical, precedex > 0)

##############
### hourly dose for each subgroup
quantile(cohort_Medical_benzo$benzo/cohort_Medical_benzo$duration_hours)
quantile(cohort_Medical_opiod$opiod/cohort_Medical_opiod$duration_hours)
quantile(cohort_Medical_propofol$propofol/cohort_Medical_propofol$duration_hours)
quantile(cohort_Medical_precedex$precedex/cohort_Medical_precedex$duration_hours)

quantile(cohort_Surgical_benzo$benzo/cohort_Surgical_benzo$duration_hours)
quantile(cohort_Surgical_opiod$opiod/cohort_Surgical_opiod$duration_hours)
quantile(cohort_Surgical_propofol$propofol/cohort_Surgical_propofol$duration_hours)
quantile(cohort_Surgical_precedex$precedex/cohort_Surgical_precedex$duration_hours)

##########
## diurnal difference within MICU or SICU
wilcox.test(cohort_Medical_benzo$D_benzo/cohort_Medical_benzo$dayHrs, cohort_Medical_benzo$N_benzo/cohort_Medical_benzo$nightHrs, conf.int = TRUE, paired = TRUE)
median(cohort_Medical_benzo$D_benzo/cohort_Medical_benzo$dayHrs - cohort_Medical_benzo$N_benzo/cohort_Medical_benzo$nightHrs)

wilcox.test(cohort_Surgical_benzo$D_benzo/cohort_Surgical_benzo$dayHrs, cohort_Surgical_benzo$N_benzo/cohort_Surgical_benzo$nightHrs, conf.int = TRUE, paired = TRUE)
median(cohort_Surgical_benzo$D_benzo/cohort_Surgical_benzo$dayHrs - cohort_Surgical_benzo$N_benzo/cohort_Surgical_benzo$nightHrs)

wilcox.test(cohort_Medical_opiod$D_opiod/cohort_Medical_opiod$dayHrs, cohort_Medical_opiod$N_opiod/cohort_Medical_opiod$nightHrs, conf.int = TRUE, paired = TRUE)
median(cohort_Medical_opiod$D_opiod/cohort_Medical_opiod$dayHrs - cohort_Medical_opiod$N_opiod/cohort_Medical_opiod$nightHrs)

wilcox.test(cohort_Surgical_opiod$D_opiod/cohort_Surgical_opiod$dayHrs, cohort_Surgical_opiod$N_opiod/cohort_Surgical_opiod$nightHrs, conf.int = TRUE, paired = TRUE)
median(cohort_Surgical_opiod$D_opiod/cohort_Surgical_opiod$dayHrs - cohort_Surgical_opiod$N_opiod/cohort_Surgical_opiod$nightHrs)

wilcox.test(cohort_Medical_propofol$D_propofol/cohort_Medical_propofol$dayHrs, cohort_Medical_propofol$N_propofol/cohort_Medical_propofol$nightHrs, conf.int = TRUE, paired = TRUE)
median(cohort_Medical_propofol$D_propofol/cohort_Medical_propofol$dayHrs - cohort_Medical_propofol$N_propofol/cohort_Medical_propofol$nightHrs)

wilcox.test(cohort_Surgical_propofol$D_propofol/cohort_Surgical_propofol$dayHrs, cohort_Surgical_propofol$N_propofol/cohort_Surgical_propofol$nightHrs,conf.int = TRUE, paired = TRUE)
median(cohort_Surgical_propofol$D_propofol/cohort_Surgical_propofol$dayHrs - cohort_Surgical_propofol$N_propofol/cohort_Surgical_propofol$nightHrs)

wilcox.test(cohort_Medical_precedex$D_precedex/cohort_Medical_precedex$dayHrs, cohort_Medical_precedex$N_precedex/cohort_Medical_precedex$nightHrs, conf.int = TRUE, paired = TRUE)
median(cohort_Medical_precedex$D_precedex/cohort_Medical_precedex$dayHrs - cohort_Medical_precedex$N_precedex/cohort_Medical_precedex$nightHrs)

wilcox.test(cohort_Surgical_precedex$D_precedex/cohort_Surgical_precedex$dayHrs, cohort_Surgical_precedex$N_precedex/cohort_Surgical_precedex$nightHrs, conf.int = TRUE, paired = TRUE)
median(cohort_Surgical_precedex$D_precedex/cohort_Surgical_precedex$dayHrs - cohort_Surgical_precedex$N_precedex/cohort_Surgical_precedex$nightHrs)

##########
### diff btw MICU and SICU
wilcox.test(cohort_Medical_benzo$benzo/cohort_Medical_benzo$duration_hours, cohort_Surgical_benzo$benzo/cohort_Surgical_benzo$duration_hours, conf.int = TRUE, paired = FALSE)
median(cohort_Medical_benzo$benzo/cohort_Medical_benzo$duration_hours) - median(cohort_Surgical_benzo$benzo/cohort_Surgical_benzo$duration_hours)
wilcox.test(cohort_Medical_opiod$opiod/cohort_Medical_opiod$duration_hours, cohort_Surgical_opiod$opiod/cohort_Surgical_opiod$duration_hours, conf.int = TRUE, paired = FALSE)
median(cohort_Medical_opiod$opiod/cohort_Medical_opiod$duration_hours)-median(cohort_Surgical_opiod$opiod/cohort_Surgical_opiod$duration_hours)
wilcox.test(cohort_Medical_propofol$propofol/cohort_Medical_propofol$duration_hours, cohort_Surgical_propofol$propofol/cohort_Surgical_propofol$duration_hours, conf.int = TRUE, paired = FALSE)
median(cohort_Medical_propofol$propofol/cohort_Medical_propofol$duration_hours)- median(cohort_Surgical_propofol$propofol/cohort_Surgical_propofol$duration_hours)
wilcox.test(cohort_Medical_precedex$precedex/cohort_Medical_precedex$duration_hours, cohort_Surgical_precedex$precedex/cohort_Surgical_precedex$duration_hours, conf.int = TRUE, paired = FALSE)
median(cohort_Medical_precedex$precedex/cohort_Medical_precedex$duration_hours) - median(cohort_Surgical_precedex$precedex/cohort_Surgical_precedex$duration_hours)

############
### confounder 
t.test(cohort_Medical_benzo$age, cohort_Surgical_benzo$age, paired = FALSE)
t.test(cohort_Medical_opiod$age, cohort_Surgical_opiod$age, paired = FALSE)
t.test(cohort_Medical_propofol$age, cohort_Surgical_propofol$age, paired = FALSE)
t.test(cohort_Medical_precedex$age, cohort_Surgical_precedex$age, paired = FALSE)

t.test(cohort_Medical_benzo$sofa, cohort_Surgical_benzo$sofa, paired = FALSE)
t.test(cohort_Medical_opiod$sofa, cohort_Surgical_opiod$sofa, paired = FALSE)
t.test(cohort_Medical_propofol$sofa, cohort_Surgical_propofol$sofa, paired = FALSE)
t.test(cohort_Medical_precedex$sofa, cohort_Surgical_precedex$sofa, paired = FALSE)
