library(geosphere)
library(tidyverse)
library(dplyr)
library(terra)
library(lubridate)
######################
# dies sind die Variablen, die man für den eigenen Gebrauch anpassen muss
programPath <- "C:/Users/Simon/Documents/VSP-Projects/matsim-kelheim/src/main/R/LocDestAnalysis" # hier sollen die Funktionen neareststop.R und countdrivenstops.R liegen
filePath <- "C:/Users/Simon/Documents/shared-svn/projects/KelRide/data/KEXI" # hier sollen die beiden folgenden Files liegen
originfilename <- "VIA_Rides_202106_202201.csv" # Filename der Realdaten
haltestellenFile <- "KEXI_Haltestellen_Liste_Kelheim.csv" # Filename der Haltestellenliste
startdate <- "2022-01-27"  # wenn das ganze File ausgewertet werden soll, schreibe hier -1 rein
tage <- 1 # Anzahl an Tagen die ausgewertet werden sollen
nameAnalyseFile <- paste("typicalDays/", startdate , "_Via-Origin-drt-count-Analysis-KEXI.csv") # Filename des Analyseoutputfiles, in tsv
csvfilename <- "stop2stopridesVIA.csv"
setwd(programPath)
source("neareststop.R")
source("countdrivenstops.R")



setwd(filePath)
# Daten von VIA einlesen
viaDataframe <- read.csv(originfilename, stringsAsFactors = FALSE, header = TRUE, encoding = "UTF-8", sep= ";")

viaDataframe <- viaDataframe %>% mutate(Actual.DO.time = ymd_hms(Actual.DO.time))

if (startdate!=-1){
  d <- interval(ymd(startdate),ymd(startdate)+days(x=tage))
  viaDataframe <- viaDataframe %>% filter(Actual.DO.time %within% d)
}



if(("fromstopID" %in% colnames(viaDataframe))==FALSE){
  #VSP-stops müssen den VIA Daten hinzugefügt werd
  ######################################

  # Daten der jeweiligen Haltestellen einlesen

  stops <- read.csv(haltestellenFile, stringsAsFactors = FALSE, header = TRUE, encoding = "UTF-8",sep= ";")



  ########################################
  # fügt zu den VIA Daten den Haltestellenwert VSP hinzu

  viaDataframe <- viaDataframe  %>%
    rowwise() %>%
    #mutate(fromstopID=as.integer(neareststop(Origin.Longitude, Origin.latitude,"Stop.ID")))
    mutate(fromstopID=as.integer(neareststop(Origin.Longitude, Origin.latitude,"Haltestellen.Nr.")))

  viaDataframe <- viaDataframe  %>%
    rowwise() %>%
    #mutate(tostop_ID = as.integer(neareststop(Destination.Longitude, Destination.latitude,"Stop.ID")))
    mutate(tostop_ID=as.integer(neareststop(Destination.Longitude, Destination.latitude,"Haltestellen.Nr.")))

  setwd(filePath)

  #write.csv2(viaDataframe, "VIA_Rides_202106_202201neu.csv",quote = FALSE)

}
# zählt die Anzahl der Fahrten von einem Stop zum nächsten
countdrivenlinks(viaDataframe,"fromstopID","tostop_ID",nameAnalyseFile)




