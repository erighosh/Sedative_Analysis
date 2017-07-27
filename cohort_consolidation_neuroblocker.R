# cohort_patients = read.csv("cohort_consildation_1.csv", stringsAsFactors = FALSE)
# the code exclude further patients based on use of neuroblockers and non-existent records of med use
# use of neuroblockers are extracted from med data

bolus = read.csv("170419_bolus_DN_totals.csv")
iv = read.csv("170419_IV_DN_totals.csv")

icuid_cohort = as.data.frame(cohort_patients$icustay_id)
colnames(icuid_cohort)[1] = "icustay_id"
bolus = merge(icuid_cohort, bolus, by = "icustay_id", all.x = TRUE, all.y = FALSE)
iv = merge(icuid_cohort, iv, by = "icustay_id", all.x = TRUE, all.y = FALSE)
bolus[is.na(bolus)] = 0
iv[is.na(iv)] = 0

cohort_patients$D_benzo = 0
cohort_patients$N_benzo = 0
cohort_patients$benzo = 0
cohort_patients$D_opiod = 0
cohort_patients$N_opiod = 0
cohort_patients$opiod = 0
cohort_patients$D_propofol = 0
cohort_patients$N_propofol = 0
cohort_patients$propofol = 0
cohort_patients$D_precedex = 0
cohort_patients$N_precedex = 0
cohort_patients$precedex = 0
for (icustayID in cohort_patients$icustay_id) {
  rowIDinCohort = which(cohort_patients$icustay_id == icustayID)
  rowIDinBolus = which(bolus$icustay_id==icustayID)
  rowIDinIV = which(iv$icustay_id==icustayID)
  
  cohort_patients$D_benzo[rowIDinCohort] = bolus$D_Lorazepam..Ativan.[rowIDinBolus] + 
    iv$D_Lorazepam..Ativan.[rowIDinIV] +
    0.2*bolus$D_Diazepam..Valium.[rowIDinBolus] +
    #    0.2*iv$D_Diazepam..Valium.[rowIDinIV] +
    0.33*bolus$D_Midazolam..Versed.[rowIDinBolus] +
    0.33*iv$D_Midazolam..Versed.[rowIDinIV]
  
  cohort_patients$N_benzo[rowIDinCohort] = bolus$N_Lorazepam..Ativan.[rowIDinBolus] + 
    iv$N_Lorazepam..Ativan.[rowIDinIV] +
    0.2*bolus$N_Diazepam..Valium.[rowIDinBolus] +
    #    0.2*iv$N_Diazepam..Valium.[rowIDinIV] +
    0.33*bolus$N_Midazolam..Versed.[rowIDinBolus] +
    0.33*iv$N_Midazolam..Versed.[rowIDinIV]
  
  cohort_patients$D_opiod[rowIDinCohort] = bolus$D_Morphine.Sulfate[rowIDinBolus] +
    iv$D_Morphine.Sulfate[rowIDinIV] +
    100*bolus$D_Fentanyl[rowIDinBolus] +
    100*iv$D_Fentanyl[rowIDinIV] + 
    #    100*bolus$D_Fentanyl..Concentrate.[rowIDinBolus] +
    100*iv$D_Fentanyl..Concentrate.[rowIDinIV] +
    #    100*bolus$D_Fentanyl..Push.[rowIDinBolus] +
    #    100*iv$D_Fentanyl..Push.[rowIDinIV] +
    6.67*bolus$D_Hydromorphone..Dilaudid.[rowIDinBolus] +
    6.67*iv$D_Hydromorphone..Dilaudid.[rowIDinIV] +
    0.13*bolus$D_Meperidine..Demerol.[rowIDinBolus]
  #    0.13*iv$D_Meperidine..Demerol.[rowIDinIV]
  
  cohort_patients$N_opiod[rowIDinCohort] = bolus$N_Morphine.Sulfate[rowIDinBolus] +
    iv$N_Morphine.Sulfate[rowIDinIV] +
    100*bolus$N_Fentanyl[rowIDinBolus] +
    100*iv$N_Fentanyl[rowIDinIV] + 
    #    100*bolus$N_Fentanyl..Concentrate.[rowIDinBolus] +
    100*iv$N_Fentanyl..Concentrate.[rowIDinIV] +
    #    100*bolus$N_Fentanyl..Push.[rowIDinBolus] +
    #    100*iv$N_Fentanyl..Push.[rowIDinIV] +
    6.67*bolus$N_Hydromorphone..Dilaudid.[rowIDinBolus] +
    6.67*iv$N_Hydromorphone..Dilaudid.[rowIDinIV] +
    0.13*bolus$N_Meperidine..Demerol.[rowIDinBolus]
  #    0.13*iv$N_Meperidine..Demerol.[rowIDinIV]
  
  cohort_patients$D_propofol[rowIDinCohort] = bolus$D_Propofol[rowIDinBolus] +
    iv$D_Propofol[rowIDinIV]
  cohort_patients$N_propofol[rowIDinCohort] = bolus$N_Propofol[rowIDinBolus] +
    iv$N_Propofol[rowIDinIV]
  
  cohort_patients$D_precedex[rowIDinCohort] = iv$D_Dexmedetomidine..Precedex.[rowIDinIV]
  cohort_patients$N_precedex[rowIDinCohort] = iv$N_Dexmedetomidine..Precedex.[rowIDinIV]
  
  
  cohort_patients$benzo[rowIDinCohort] = cohort_patients$D_benzo[rowIDinCohort] +cohort_patients$N_benzo[rowIDinCohort]
  cohort_patients$opiod[rowIDinCohort] = cohort_patients$D_opiod[rowIDinCohort] + cohort_patients$N_opiod[rowIDinCohort]
  cohort_patients$propofol[rowIDinCohort] = cohort_patients$D_propofol[rowIDinCohort] +cohort_patients$N_propofol[rowIDinCohort]
  cohort_patients$precedex[rowIDinCohort] = cohort_patients$D_precedex[rowIDinCohort] + cohort_patients$N_precedex[rowIDinCohort]
}

cohort_patients = subset(cohort_patients, benzo > 0 | opiod >0 | propofol > 0 | precedex >0)
nrow(cohort_patients)

# write.csv(cohort_patients, "cohort_consildation_2.csv")
