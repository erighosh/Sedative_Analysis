
cohort_benzo_only = subset(cohort_patients, benzo>0 & opiod ==0 & propofol ==0 & precedex ==0)
nrow(cohort_benzo_only)
table(cohort_benzo_only$last_careunit)

cohort_benzo_opiod_only = subset(cohort_patients, benzo>0 & opiod > 0 & propofol ==0 & precedex ==0)
nrow(cohort_benzo_opiod_only)
table(cohort_benzo_opiod_only$last_careunit)

cohort_benzo_propofol_only = subset(cohort_patients, benzo>0 & opiod == 0 & propofol > 0 & precedex ==0)
nrow(cohort_benzo_propofol_only)
table(cohort_benzo_propofol_only$last_careunit)

cohort_benzo_precedex_only = subset(cohort_patients, benzo>0 & opiod == 0 & propofol == 0 & precedex > 0)
nrow(cohort_benzo_precedex_only)
table(cohort_benzo_precedex_only$last_careunit)

cohort_benzo_opiod_propofol_only = subset(cohort_patients, benzo>0 & opiod > 0 & propofol > 0 & precedex ==0)
nrow(cohort_benzo_opiod_propofol_only)
table(cohort_benzo_opiod_propofol_only$last_careunit)

cohort_benzo_opiod_precedex_only = subset(cohort_patients, benzo>0 & opiod > 0 & propofol == 0 & precedex > 0)
nrow(cohort_benzo_opiod_precedex_only)
table(cohort_benzo_opiod_precedex_only$last_careunit)

cohort_benzo_propofol_precedex_only = subset(cohort_patients, benzo>0 & opiod == 0 & propofol > 0 & precedex > 0)
nrow(cohort_benzo_propofol_precedex_only)
table(cohort_benzo_propofol_precedex_only$last_careunit)

cohort_benzo_opiod_propofol_precedex_only = subset(cohort_patients, benzo>0 & opiod > 0 & propofol > 0 & precedex > 0)
nrow(cohort_benzo_opiod_propofol_precedex_only)
table(cohort_benzo_opiod_propofol_precedex_only$last_careunit)

cohort_opiod_only = subset(cohort_patients, benzo == 0 & opiod > 0 & propofol == 0 & precedex == 0)
nrow(cohort_opiod_only)
table(cohort_opiod_only$last_careunit)

cohort_opiod_propofol_only = subset(cohort_patients, benzo == 0 & opiod > 0 & propofol > 0 & precedex == 0)
nrow(cohort_opiod_propofol_only)
table(cohort_opiod_propofol_only$last_careunit)

cohort_opiod_precedex_only = subset(cohort_patients, benzo == 0 & opiod > 0 & propofol == 0 & precedex > 0)
nrow(cohort_opiod_precedex_only)
table(cohort_opiod_precedex_only$last_careunit)

cohort_opiod_propofol_precedex_only = subset(cohort_patients, benzo == 0 & opiod > 0 & propofol > 0 & precedex > 0)
nrow(cohort_opiod_propofol_precedex_only)
table(cohort_opiod_propofol_precedex_only$last_careunit)

cohort_propofol_only = subset(cohort_patients, benzo == 0 & opiod == 0 & propofol > 0 & precedex == 0)
nrow(cohort_propofol_only)
table(cohort_propofol_only$last_careunit)

cohort_propofol_precedex_only = subset(cohort_patients, benzo == 0 & opiod == 0 & propofol > 0 & precedex > 0)
nrow(cohort_propofol_precedex_only)
table(cohort_propofol_precedex_only$last_careunit)

cohort_precedex_only = subset(cohort_patients, benzo == 0 & opiod == 0 & propofol == 0 & precedex > 0)
nrow(cohort_precedex_only)
table(cohort_precedex_only$last_careunit)
