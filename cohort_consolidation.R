setwd("D:/Documents/Courses/HST953_Secondary_Analysis_of_Health_Records/painLess/project/final2")

allpatients = read.csv("startingCohort.csv")
icustays = read.csv("icustays.csv", sep = ";", stringsAsFactors = FALSE)
patients = subset(allpatients, duration_hours>=48)
patients = subset(patients,age>=18 & age<=90)
sofa = read.csv("sofascore.csv", stringsAsFactors = FALSE)
dayNightHrs = dget("D:/Documents/Courses/HST953_Secondary_Analysis_of_Health_Records/painLess/project/final/dayNightHrs.R")


##################################
patients$starttime = as.POSIXct(patients$starttime,format="%Y-%m-%d %H:%M:%S")
patients$endtime = as.POSIXct(patients$endtime,format="%Y-%m-%d %H:%M:%S")

patients_id = as.data.frame(patients$subject_id)
colnames(patients_id)[1] = "subject_id"
colnames(patients_id)
nrow(patients_id)

######## specify cohort patients 
cohort_patients = merge(x = patients_id,y = patients, by = "subject_id", all = FALSE)
nrow(cohort_patients)


########################
### exclude patients by artic sun by subject_id
articsun = read.csv("articsun.csv")
length(unique(articsun$subject_id))
updated_patient_id = setdiff(unique(cohort_patients$subject_id),unique(articsun$subject_id))
updated_patient_id = as.data.frame(updated_patient_id)
colnames(updated_patient_id)[1] = "subject_id"
cohort_patients = merge(x = updated_patient_id,y = cohort_patients, by = "subject_id", all = FALSE)
nrow(cohort_patients)

### exclude patients by ICD9 by subject_id
ICD9 = read.csv("ICD9cohort.csv")
length(unique(ICD9$subject_id))
updated_patient_id = setdiff(unique(cohort_patients$subject_id),unique(ICD9$subject_id))
updated_patient_id = as.data.frame(updated_patient_id)
colnames(updated_patient_id)[1] = "subject_id"
cohort_patients = merge(x = updated_patient_id,y = cohort_patients, by = "subject_id", all = FALSE)
nrow(cohort_patients)

### exclude patients by DNR by subject_id
cmo = read.csv("cmo.csv")
length(unique(cmo$subject_id))
updated_patient_id = setdiff(unique(cohort_patients$subject_id),unique(cmo$subject_id))
updated_patient_id = as.data.frame(updated_patient_id)
colnames(updated_patient_id)[1] = "subject_id"
cohort_patients = merge(x = updated_patient_id,y = cohort_patients, by = "subject_id", all = FALSE)
nrow(cohort_patients)

##### calculate day and night hours when the patients are ventilated
dnh = dayNightHrs(cohort_patients$starttime, cohort_patients$endtime)
cohort_patients$dayHrs = dnh$dayHrs
cohort_patients$nightHrs = dnh$nightHrs


#### merge cohort_patients with icustays to add icustay durations to the cohort_patients
cohort_patients = merge(x = cohort_patients, y = icustays, by = c("subject_id","icustay_id"), all.x = TRUE, all.y = FALSE)
nrow(cohort_patients)

### exclude patients whose first_careunit is not the same as the last_careunit
# cohort_patients = subset(cohort_patients, first_careunit == last_careunit)
# nrow(cohort_patients)

### merge cohort_patients with sofa scores 
cohort_patients = merge(x = cohort_patients, y = sofa, by = c("subject_id","icustay_id"), all.x = TRUE, all.y = FALSE )
nrow(cohort_patients)

# write.csv(cohort_patients, "cohort_consildation_1.csv")

