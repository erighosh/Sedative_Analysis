function(starttime,endtime) {
  startdate = as.data.frame(format(starttime, format = "%Y-%m-%d"))
  colnames(startdate)[1] = "date"
  startdate$date = as.POSIXct(startdate$date, format = "%Y-%m-%d")
  
  starttime = as.data.frame(format(starttime, format = "%H:%M:%S"))
  colnames(starttime)[1] = "time"
  starttime$time = as.POSIXct(starttime$time,format = "%H:%M:%S")
  
  enddate = as.data.frame(format(endtime, format = "%Y-%m-%d"))
  colnames(enddate)[1] = "date"
  enddate$date = as.POSIXct(enddate$date, format = "%Y-%m-%d")
  
  endtime = as.data.frame(format(endtime, format = "%H:%M:%S"))
  colnames(endtime)[1] = "time"
  endtime$time = as.POSIXct(endtime$time,format = "%H:%M:%S")
  
  t1 = as.POSIXct("00:00:00",format = "%H:%M:%S")
  t2 = as.POSIXct("07:00:00",format = "%H:%M:%S")
  t3 = as.POSIXct("19:00:00",format = "%H:%M:%S")
  t4 = as.POSIXct("24:00:00",format = "%H:%M:%S")
  sequence = seq(1,length(starttime$time))
  dayHrs = numeric(length(starttime$time))
  nightHrs = numeric(length(starttime$time))
  
   for (i in sequence) {

    if (starttime$time[i] < t2) {
      dayHrs[i] = 12
      nightHrs[i] = as.numeric(difftime(t2,starttime$time[i],units = "hours")) + as.numeric(t4 - t3)
    }
    else if (starttime$time[i] >= t2 & starttime$time[i] < t3) {
      dayHrs[i] = as.numeric(difftime(t3, starttime$time[i],units = "hours"))
      nightHrs[i] = as.numeric(t4 - t3)
    }
    else {
      dayHrs[i] = 0
      nightHrs[i] = as.numeric(difftime(t4, starttime$time[i], units = "hours"))
    }
     
     
    if (endtime$time[i] < t2) {
      dayHrs[i] = dayHrs[i]
      nightHrs[i] = nightHrs[i] + as.numeric(difftime(endtime$time[i], t1, units = "hours"))
    }
    else if (endtime$time[i] >= t2 & endtime$time[i] < t3) {
      dayHrs[i] = dayHrs[i] + as.numeric(difftime(endtime$time[i], t2, units = "hours"))
      nightHrs[i] = nightHrs[i] + as.numeric(t2 - t1)
    }
    else {
      dayHrs[i] = dayHrs[i] + as.numeric(t3 - t2)
      nightHrs[i] = nightHrs[i] + as.numeric(t2 - t1) + as.numeric(difftime(endtime$time[i], t3,units = "hours"))
    }
     
    dayHrs[i] = dayHrs[i] + 12 * (enddate$date[i] - startdate$date[i] - 1)
    nightHrs[i] = nightHrs[i] + 12 * (enddate$date[i] - startdate$date[i] - 1)
  }
#   results = list("dayHrs" = dayHrs,"nightHrs" = nightHrs)
  return(data.frame(dayHrs,nightHrs))
}