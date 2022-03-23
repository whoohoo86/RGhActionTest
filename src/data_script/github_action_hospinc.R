library(readr)
library(openxlsx)
library(dplyr)
library(tidyr)

Hospitalisierungen <- read_csv("https://raw.githubusercontent.com/robert-koch-institut/COVID-19-Hospitalisierungen_in_Deutschland/master/Aktuell_Deutschland_COVID-19-Hospitalisierungen.csv", col_types = cols(Datum = col_character()))
Hospitalisierungen_D <- Hospitalisierungen %>% filter(Bundesland_Id == "00", Altersgruppe=="00+",Datum>=Sys.Date()-60) %>% dplyr::select(Bundesland, Datum, `7T_Hospitalisierung_Inzidenz`) %>% spread(Datum, `7T_Hospitalisierung_Inzidenz`)
Hospitalisierungen_BL <- Hospitalisierungen %>% filter(Bundesland_Id != "00", Altersgruppe=="00+",Datum>=Sys.Date()-60) %>% dplyr::select(Bundesland, Datum, `7T_Hospitalisierung_Inzidenz`) %>% spread(Datum, `7T_Hospitalisierung_Inzidenz`)
Hospitalisierungen_Gesamt <- bind_rows(Hospitalisierungen_BL, Hospitalisierungen_D)

wb <- createWorkbook()
addWorksheet(wb, sheetName = "BL_7-Tage-Inzidenz Hosp(aktual)", gridLines = TRUE)
writeData(wb, sheet = 1, x = "7-Tage-Inzidenzen der Hospitalisierten pro Bundesland, aktualisiert für die vergangenen Tage unter Berücksichtigung von Nachübermittlungen", startRow = 1, colNames = FALSE, rowNames = FALSE)
writeDataTable(wb, sheet = 1, x = Hospitalisierungen_Gesamt, startRow = 3,
               colNames = TRUE, rowNames = FALSE,
               tableStyle = "TableStyleMedium16", withFilter = F)

setColWidths(wb, sheet = 1, cols = "A", widths = 20)
setColWidths(wb, sheet = 1, cols = 2:63, widths = 10)
two <- createStyle(numFmt = "0.00")
two_bold <- createStyle(textDecoration = "bold",  numFmt = "0.00")
addStyle(wb, 1, style = two, rows = 4:19, cols = 2:63, gridExpand = TRUE)
addStyle(wb, 1, style = two_bold, rows = 20, cols = 1:63, gridExpand = TRUE)

saveWorkbook(wb, paste0("./data/7-Tage-Inzidenzen_",Sys.Date(),".xlsx"), overwrite = TRUE)
