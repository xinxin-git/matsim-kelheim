# Title     : Analysis of KEXI request data
# Objective : get KPIs for drt demand calibration
# Created by: Simon
# Created on: 10.02.2022

library(lubridate)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(plotly)
library(hrbrthemes)
library(geosphere)

#####################################################################
####################################################
### INPUT DEFINITIONS ###

# set working directory
#setwd("D:/svn/shared-svn/projects/KelRide/data/KEXI/")
setwd("C:/Users/Simon/Documents/shared-svn/projects/KelRide/data/KEXI/")

# read data
VIArides2021 <- read.csv2("VIA_Rides_202106_202201.csv", stringsAsFactors = FALSE, header = TRUE, encoding = "UTF-8")
VIArides2022 <- read.csv2("VIA_Rides_202201_202210.csv", stringsAsFactors = FALSE, header = TRUE, encoding = "UTF-8")

VIAridesAll <- union(VIArides2021, VIArides2022)

datasets <- list(VIArides2021, VIArides2022, VIAridesAll)
names <- c("VIArides2021","VIArides2022","VIAridesAll")
i <- 1

avgValues <- setNames(data.frame(matrix(ncol = 5, nrow = 0)), c("dataset", "avgRidesPerDay", "avgDistance[m]", "avgDistance_withoutFilter[m]", "avgTravelTime[s]"))

for(dataset in datasets) {
  print(paste0("Starting to calculate stats for dataset ",names[i]))

  # In the VIA data they differentiate between requested PU time and requested DO time. Only 450 requests do not have a requested PU time
  # Therefore the rows will get joined (otherwise it will lead to errors)
  dataset <- dataset %>%
    unite(Requested.PU.time,Requested.DO.time,col="Requested.time",sep="")

  # convert time columns
  dataset <- dataset %>% mutate(Ride.request.time = ymd_hms(Ride.request.time),
                                          Requested.time = ymd_hms(Requested.time),
                                          No.show.time = ymd_hms(No.show.time),
                                          Actual.PU.time = ymd_hms(Actual.PU.time),
                                          Actual.DO.time = ymd_hms(Actual.DO.time),
                                          Cancellation.time = ymd_hms(Cancellation.time),
                                          date = date(Actual.PU.time),
                                          weekday = wday(date, label = TRUE)
  )

  # some entries seem to have errors (mssing Pickup time). As the total number only is 167 we just filter them for now -sm 02-2022
  # noPUTime <- dataset %>%
  #   filter(is.na(Actual.PU.time))
  #
  # write.csv2(noPUTime, "VIA_Rides_202106_202201_noPUTime.csv", quote = FALSE)

  dataset <- dataset %>%
    filter(! is.na(Actual.PU.time))

  weekdayRides <- dataset %>%
    filter(weekday != "Fr",
           weekday != "Sa",
           weekday != "So",
           weekday != "Mo")

  #Possibly add a lockdown in late 2021 / early 2022 here,
  # although the "low periods" observed in the "Zeitverlauf der Fahrten pro Tag (VIA)"-plot seem be explainable through holiday times (christmas and summer)
  summer_holiday21 <- interval(ymd("2021-07-30"), ymd("2021-09-13"))
  autumn_holiday21 <- interval(ymd("2021-11-01"), ymd("2021-11-05"))
  holiday_bettag21 <- interval(ymd("2021-11-17"), ymd("2021-11-17"))
  holidays_christmas21 <- interval(ymd("2021-12-24"), ymd("2022-01-08"))
  winter_holiday22 <- interval(ymd("2022-02-28"), ymd("2022-03-04"))
  easter_holiday22 <- interval(ymd("2022-04-11"), ymd("2022-04-23"))
  holiday_himmelfahrt22 <- interval(ymd("2022-05-26"), ymd("2022-05-26"))
  pfingsten_holiday22 <- interval(ymd("2022-06-06"), ymd("2022-06-18"))
  summer_holiday22 <- interval(ymd("2022-08-01"), ymd("2022-09-12"))
  holiday_einheit22 <- interval(ymd("2022-10-03"), ymd("2022-10-03"))


  ridesToConsider <- weekdayRides %>%
    filter(! date %within% summer_holiday21,
           ! date %within% autumn_holiday21,
           ! date %within% holiday_bettag21,
           ! date %within% holidays_christmas21,
           ! date %within% winter_holiday22,
           ! date %within% easter_holiday22,
           ! date %within% holiday_himmelfahrt22,
           ! date %within% pfingsten_holiday22,
           ! date %within% summer_holiday22,
           ! date %within% holiday_einheit22,
    ) %>%
    mutate( travelTime_s = Actual.DO.time - Actual.PU.time) %>%
    # The dataset appears to have one entry with Actual.DO.time < Actual.PU.time, which produces a negative travelTime
    #It (Ride ID: 17036) therefore is excluded
    filter(travelTime_s > 0)

  ##########################################################################################################################################################
  #calculate Distance on an ellipsoid (the geodesic) between the calculated start and end points of each tour
  ridesToConsider <- ridesToConsider  %>%
    rowwise() %>%
    mutate(distance_m = as.double(distGeo(c(as.double(Origin.Longitude), as.double(Origin.latitude)),
                                          c(as.double(Destination.Longitude), as.double(Destination.latitude)))))

  ################################################################################################################################################################
  #tested the different distance-calculation functions on the geosphere package
  #result: variation is only about 1m
  # coord <- c(as.double(ridesToConsider$Kalkulierter.Abfahrtsort..lon.[1]), as.double(ridesToConsider$Kalkulierter.Abfahrtsort..lat.[1]))
  # coord2 <- c(as.double(ridesToConsider$Kalkulierter.Ankunftsort..lon.[1]), as.double(ridesToConsider$Kalkulierter.Ankunftsort..lat.[1]))
  #
  # coord
  #
  # dist <- distHaversine(coord, coord2)
  # dist2 <- distGeo(coord, coord2)
  # dist6 <- distCosine(coord, coord2)
  # dist7 <- distMeeus(coord, coord2)
  # dist8 <- distRhumb(coord, coord2)
  # dist8 <- distVincentyEllipsoid(coord, coord2)
  # dist9 <- distVincentySphere(coord, coord2)

  ############################################################################################################################################################

  j <- ridesToConsider %>%
    mutate(travelTime_s = seconds(travelTime_s))
  hist(j$travelTime_s, plot = TRUE)
  boxplot(j$travelTime_s)
  avgTravelTime_s <- mean(ridesToConsider$travelTime_s)
  avgTravelTime_s

  hist(j$distance_m, plot = TRUE)
  boxplot(j$distance_m)

  avgDistance_m <- mean(ridesToConsider$distance_m)
  avgDistance_m

  #ridesLessThan10Seconds <- ridesToConsider %>%
  #  filter(travelTime_s <= 180)

  # there are 47 rides below tt=120s and 22 rides below tt=60s out of 7542 considerable rides. For three minutes, this goes up to 157 rides.
  # so for a first version, we cut everyhing below 2 minutes
  # by doing so, we increase mean travel time from 508 to 511 seconds

  # below120s <- ridesToConsider %>%
  #   filter(travelTime_s < 120)
  # below60s <- ridesToConsider %>%
  #   filter(travelTime_s < 60)
  # below180s <- ridesToConsider %>%
  #   filter(travelTime_s < 180)
  # over1500s <- ridesToConsider %>%
  #   filter(travelTime_s > 1500)
  # over1000s <- ridesToConsider %>%
  #   filter(travelTime_s > 1000)

  ridesToConsider <- ridesToConsider %>%
    filter(travelTime_s >= 120)

  #calculate avg travel time of all rides
  j <- ridesToConsider %>%
    mutate(travelTime_s = seconds(travelTime_s)) %>%
    filter(travelTime_s < 1500)
  avgTravelTime_s <- mean(j$travelTime_s)
  avgTravelTime_s

  hist(j$travelTime_s, plot = TRUE)
  ggplot(j, aes(y=travelTime_s)) +
    stat_boxplot(geom="errorbar", width=3) +
    geom_boxplot(width=5) +
    scale_y_continuous(n.breaks = 10) +
    scale_x_discrete() +
    stat_summary(fun=mean, geom="errorbar",aes(ymax=..y.., ymin=..y.., x=0),
                 width=5, colour="red") +
    # labs(x="", y="travel time [s]", title="Boxplot KEXI Travel Time") +
    labs(x="", y="travel time [s]") + #for paper only
    theme(plot.title = element_text(hjust=0.5, size=20, face="bold"), axis.text.y = element_text(size=24),
          axis.title.y = element_text(size=25, face="bold"))

  # boxplot(j$travelTime_s, main = "Boxplot KEXI Travel Time", ylab = "travel time [s]",
  #         pars = list(mar = c(5.0,5.0,5.0), boxwex = 1.5, cex.lab=1.4, cex.axis=1.4, cex.main=1.4))
  #abline(h = avgTravelTime_s - 2 * sd(j$travelTime_s), col="red",lty=2)
  #abline(h = avgTravelTime_s + 2 * sd(j$travelTime_s), col="red",lty=2)

  k <- ridesToConsider %>%
    filter(distance_m <= 5000)

  avgDistance_m <- mean(k$distance_m)
  avgDistance_m

  avgDistance_m_withoutFilter <- mean(ridesToConsider$distance_m)
  avgDistance_m_withoutFilter

  hist(k$distance_m, plot = TRUE)
  ggplot(k, aes(y=distance_m)) +
    stat_boxplot(geom="errorbar", width=3) +
    geom_boxplot(width=5) +
    scale_y_continuous(n.breaks = 8) +
    scale_x_discrete() +
    stat_summary(fun=mean, geom="errorbar",aes(ymax=..y.., ymin=..y.., x=0),
                 width=5, colour="red") +
    # labs(x="", y="travel distance [m]", title="Boxplot KEXI Travel Distance") +
    labs(y="travel distance [m]", x="") + #for paper only
    theme(plot.title = element_text(hjust=0.5, size=20, face="bold"), axis.text.y = element_text(size=24),
          axis.title.y = element_text(size=25, face="bold"))
  # boxplot(k$distance_m, main = "Boxplot KEXI Travel Distance", ylab = "travel distance [m]")
  # abline(h = avgDistance_m - 2 * sd(k$distance_m), col="red",lty=2)
  # abline(h = avgDistance_m + 2 * sd(k$distance_m), col="red",lty=2)

  ############################################################################################################################################################

  #calculate avg rides per day
  ridesPerDay <- ridesToConsider %>%
    group_by(date) %>%
    tally()


  avgRides <- mean(ridesPerDay$n)
  avgRides

  #save avg values into df
  avgValuesDataset <- data.frame(names[i],avgRides,avgDistance_m,avgDistance_m_withoutFilter,avgTravelTime_s)
  names(avgValuesDataset) <- names(avgValues)
  avgValues <- rbind(avgValues,avgValuesDataset)

  # avgValues$avgRidesPerDay <- avgRides
  # avgValues$`avgDistance[m]` <- avgDistance_m
  # avgValues$`avgDistance_withoutFilter[m]` <- avgDistance_m_withoutFilter
  # avgValues$`avgTravelTime[s]` <- avgTravelTime_s

  ggplot(ridesPerDay, aes(y=n)) +
    stat_boxplot(geom="errorbar", width=3) +
    geom_boxplot(width=5) +
    scale_y_continuous(n.breaks = 8) +
    scale_x_discrete() +
    stat_summary(fun=mean, geom="errorbar",aes(ymax=..y.., ymin=..y.., x=0),
                 width=5, colour="red") +
    # labs(x="", y="rides", title="Boxplot KEXI Rides per day") +
    labs(x="", y="rides") + #for paper only
    theme(plot.title = element_text(hjust=0.5, size=20, face="bold"), axis.text.y = element_text(size=24),
          axis.title.y = element_text(size=25, face="bold"))

  #a typical day here can be seen as a day with no of rides close to the average no of rides (119)
  typicalDays <- filter(ridesPerDay, between(n, avgRides - 3, avgRides + 3))

  # #5 days are chosen as typical references
  # typicalDay_jul <- ymd("2021-07-21")
  # typicalDay_sep <- ymd("2021-09-15")
  # typicalDay_oct <- ymd("2021-10-12")
  # typicalDay_dec <- ymd("2021-12-01")
  # typicalDay_jan <- ymd("2022-01-27")
  #
  # typicalDaysList <- list(typicalDay_jul, typicalDay_sep, typicalDay_oct, typicalDay_dec, typicalDay_jan)
  #
  # # this is so ugly and hard coded right now, as you have to change the day you want to plot
  # #but a for loop for this just does not seem to work -sm apr22
  # typicalDayRidesPerInterval <- ridesToConsider %>%
  #   filter(date == typicalDay_jan) %>%
  #   mutate (interval = floor( (minute(Actual.PU.time) + hour(Actual.PU.time) * 60) / 5)  )  %>%
  #   group_by(interval) %>%
  #   tally()
  #
  # p <- typicalDayRidesPerInterval %>%
  #   ggplot( aes(x=interval*5/60, y=n)) +
  #   ggtitle(paste("Fahrten pro 5-Minuten-Intervall (VIA): typischer Tag im ", month(typicalDay_jan, label=TRUE))) +
  #   geom_area(fill="#69b3a2", alpha=0.5) +
  #   geom_line(color="#69b3a2") +
  #   ylab("Anzahl Fahrten") +
  #   xlab("Stunde") +
  #   theme_ipsum()
  #
  # plotFile = paste("typicalDays/KEXI_rides_VIA_", month(typicalDay_jan, label=TRUE), ".png")
  # paste("printing plot to ", plotFile)
  # png(plotFile, width = 1200, height = 800)
  # p
  # dev.off()
  # ggplotly(p)

  # boxplot(ridesPerDay$n, main = "Boxplot KEXI Rides per day", ylab = "rides")
  # abline(h = avgRides - 2 * sd(ridesPerDay$n), col="red",lty=2)
  # abline(h = avgRides + 2 * sd(ridesPerDay$n), col="red",lty=2)


  i <- i + 1
}
csvFileName <- paste0("avg_params_kexi.csv")
write.table(avgValues,csvFileName,quote=FALSE, row.names=FALSE, dec=".", sep=";")
print(paste0("avg values for all analyzed datasets were printed to ",csvFileName))


