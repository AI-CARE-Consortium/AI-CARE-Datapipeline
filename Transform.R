# Welche Auspraegungen sind vorhanden?
# Pro Variable (z.B. TNM-T) eine Tabelle mit Auspraegung (0,X,is,1,1a,1b...) und zusaetzlicher Variable (z.B. ICD-10-Code) fuer eine eventuelle 
# Spezifitaet (nicht alle TNM-T Auspraegungen fuer alle ICD-10-Codes zugelassen).

# Which expressions are present?
# Per variable (e.g. TNM-T) one table with the expressions (0,x,is,1,1a,1b...) and optionally one additional column for another variable (e.g. ICD-10-code)
# in case an expression specific subset of the reference data is used (not all TNM-T expressions are valid for all ICD-10 codes)

# Uebersicht ueber alle Variablen: Welche Kategorien von Werten hinsichtlich der Referenz koennen vorkommen? 
# 3 Gruppen von Werten existieren: 
# 1) steht auf der Referenzliste, 
# 2) kann in die Referenzlistenangabe umgewandelt werden
# 3) braucht eine Ueberleitungstabelle.

# ad 1) Daten auf der Referenzliste und der Datenliste muessen das gleiche Format haben (gross/klein, leerzeichen)
# ad 2) saemtliche noetigen Umwandlungen sollten abgestuft durchgefuehrt werden. 
# Nach jeder Umwandlung sollte mit der Referenzliste abgeglichen werden.
# ad 3) Ueberleitungstabelle und Transformationsskript wird im Konsortium diskutiert und erstellt.

# Overview over all variables: What kind of relationship can exist between expressed values and reference data?
# 3 Groups exist:
# 1) The value exists in the reference data.
# 2) The value can be easily simplified to a fitting value in the reference data.
# 3) A more complex transformation is required in order to assign the value to the reference data.

# ad 1) Data and reference data are required to be in the same format (capitalization, spaces)
# ad 2) All required simple transformations need to be done in a stepwise order from least to most transforming (simplifying).
# After each transformation, the alignment with the reference data has to be checked.
# ad 3) The minor and major transformations have to be discussed in the consortium.
 
# 1) Abgleich der Werte mit der entsprechenden Referenztabelle ####
# 1) Alignment with reference data. ####
# import der Referenztabellen
# Import of reference data

landkreis_zuordnung <- read.csv("./Referenzdaten/landkreis_zuordnung.csv", encoding="UTF-8")

get_primary_icd <- function(tablename, data, zeile) {
  # Function to get the primary diagnosis icd for every field (useful for halde)
  if(tablename == "temp.patient"){
    return (as.character(data[["temp.tumor"]][data[["temp.tumor"]][,"Patient_ID_FK"]==data[[tablename]][zeile,"Patient_ID"],"Primaertumor_ICD"][1]))
  } else if (tablename == "temp.tumor"){
    return (as.character(data[["temp.tumor"]][zeile, "Primaertumor_ICD"]))
  } else {
    return (as.character(data[["temp.tumor"]][data[["temp.tumor"]][,"Tumor_ID"]==data[[tablename]][zeile,"Tumor_ID_FK"],"Primaertumor_ICD"]))
  }
}

referenztabelle_liste <- reference_data
# Import der Halde ####
# Import of data about non-conform values and expressions.
halde <- read.csv(paste0(OUTPUT_DIRECTORY,"/halde.csv"),stringsAsFactors = FALSE)
halde[,1] <- as.character(halde[,1])
halde[,2] <- as.character(halde[,2])
halde[,3] <- as.character(halde[,3])
halde[,4] <- as.character(halde[,4])
halde[,5] <- as.character(halde[,5])

zuweisungstabelle <- readRDS("./zuweisungstabelle.RDS")
datensatz_transformiert <- datensatz
registerID <- datensatz_transformiert[["temp.patient"]][,"Register_ID_FK"][1]
print(registerID)
# Abgleich mit Referenzdaten ####
# Es wird durch jede Datentabelle der XML-Abfragen gelooped (tumor, patient, folgeereignis, strahlentherapie, systemische therapie, operation, mamma-modul) 
# Alignment to reference data ####
# Each data table from the XML queries is loaded via a loop (tumor, patient, follow-up event, radiation, systemic therapy, surgery, mamma-module)
for (temp.tabelle in names(datensatz)) {
  print(temp.tabelle)
  # Innerhalb jeder Datentabelle wird jede Variable nacheinander durch einen Loop eingeladen. Nur Variablen aus der Zuweisungstabelle werden geladen.
  # Within each data table, each variable is loaded via a for loop. Only variables from "Zuweisungstabelle" with reference data are chosen. (%in% names Zuweisungstabelle)
  for (temp.variable in colnames(datensatz[[temp.tabelle]])[colnames(datensatz[[temp.tabelle]]) %in% names(which(!is.na(zuweisungstabelle[,2])))]) {
    # gc(reset = TRUE)
    print(temp.variable) #  Alle Variablen der csv Datensaetze werden nacheinander abgefragt
    # Anhand der Zuweisungstabelle werden die passenden Referenzdaten dieser Variable zu "referenz_tabelle" hinzugefuegt.
    # The reference data is assigned to "referenz_tabelle" according to the related variable as displayed in "zuweisungstabelle".
    
    

    #Special Case: Variable is in TNM
    if(temp.variable %in% c("cTNM_T","pTNM_T","Folgeereignis_TNM_T")){
      referenz_tabelle_tnm <- list(referenztabelle_liste$tnm7_t_krhb, referenztabelle_liste$tnm8_t_krsh, referenztabelle_liste$tnm_t_gesamt)
    } else if(temp.variable %in% c("cTNM_N","pTNM_N","Folgeereignis_TNM_N")){
      referenz_tabelle_tnm <- list(referenztabelle_liste$tnm7_n_krhb, referenztabelle_liste$tnm8_n_krsh, referenztabelle_liste$tnm_n_gesamt)
    } else if (temp.variable %in% c("cTNM_M","pTNM_M","Folgeereignis_TNM_M")){
      referenz_tabelle_tnm <- list(referenztabelle_liste$tnm7_m_krhb, referenztabelle_liste$tnm8_m_krsh, referenztabelle_liste$tnm_m_gesamt)
    }
    referenz_tabelle <- referenztabelle_liste[[zuweisungstabelle[zuweisungstabelle[,"variable"]==temp.variable,"referenztabelle"]]]
    
    # Die Daten der betrachteten Variable werden in ein temporaeres Objekt geladen um in den folgenden Schritten diese Daten mit den Referenzdaten abzugleichen.
    # The data of the current variable is assigned to a temporary object in order to allign the expressions to reference data in the following steps.
    temp.data <- datensatz[[temp.tabelle]][,temp.variable]
    if(SKIP_TRANSFORMATION){
      datensatz_transformiert[[temp.tabelle]][,temp.variable] <- temp.data
    }
    else {
    
      # Methodencheck der Variablen ####
      # Muss ein Abgleich jeder Angabe dieser Variable durchgefuehrt werden, oder entsprechen die Angaben vollstaendig der Referenz?
      # Sofern alle Angaben dieser Variable "NA" sind, muss keine Anpassung der Ausprägungen vorgenommen werden und es wird "Variable nicht angepasst" gedruckt. 
      # Selbes gilt auch, sofern für diese Variable die Methode Referenz oder Menge vorgesehen ist und alle Ausprägungen den Referenzdaten entsprechen.
      # Sollte eine dieser Bedingungen nicht stimmen, werden die Ausprägungen der Variable einzeln gegen die Referenzdaten geprüft. 
      
      # Method of reference data alignment ####
      # Is it necessary to compare all given expressions of this variable to the reference data, or are they identical?
      # If alle values of this variable are "NA" than no comparison to the reference data is neccessary and "Variable not adjusted (nicht angepasst)" is printed.
      # The same happens if for this variable the method "reference" or "menge" (multiple) is used and all unique values can be found in the reference data.
      # If one of these conditions does not apply, the individual expressions within the data set are compared to the reference data.
      if(all(is.na(unique(temp.data))) || 
        ((zuweisungstabelle[zuweisungstabelle[,"variable"]==temp.variable,"methode"] %in% c("referenz","menge")) &&
          all(unique(temp.data) %in% referenz_tabelle[,1]))){
          print(paste0(temp.variable," nicht angepasst"))
      } else {
        # Welche Methode des Referenztabellenabgleichs ist fuer diese Variable vorgesehen?
        # Which method is assigned to this variable and reference data?
        
        # menge / multiple (Menge OPS, Lokalisation Fernmetastasen) (Multiple OPS-Codes, localisation of metastases)
        if(zuweisungstabelle[zuweisungstabelle[,"variable"]==temp.variable,"methode"]=="menge"){
          print("menge")
          # Fuer jede Angabe/Zeile dieser Variable: Aufteilen der in dieser Menge verketteten Angaben (";" oder "|")
          # For all entries / rows for this variable: Split the concatenated values by their separator (either ";" or "|")
          for (zeile in 1:length(temp.data)) {
            if(zeile%%5000 == 0) {print(zeile)}
            if(is.na(temp.data[zeile]) | temp.data[zeile] == ""){
              next
            }
            else{
              temp.data.menge <- NA
              temp.data.menge <- unlist(strsplit(as.character(temp.data[zeile]),split = ";|\\|"))
              # Sofern eine der aufgeteilten Angaben nicht auf der Referenzliste ist: starte den Abgleich durch das "Ueberfuehrungsskript"
              # If any value from this split entry is not in the reference data: start the "Ueberfuehrungsskript" in order to check for transformation possibilities.
              # menge_checksumme ist ein Hilfsobjekt. Diesem wird zu beginn jeder Angabe der Wert "0" zugeordnet. 
              # Wenn im "Ueberfuehrungsskript" eine Zuordnung zur Referenzliste moeglich war, wird der Wert "1" eingefuegt. Andernfalls bleibt er "0".
              # menge_checksumme is a supportive object. Initialy the value "0" is assigned. 
              # If during "ueberfuehrungsskript" an alignment to the reference data is possible, the value is updated to "1", otherwise is stays "0".
              if (any(!temp.data.menge %in% as.character(unlist(referenz_tabelle[,1])))) {
                menge_checksumme <- 0
                source("./Transform_Utils.R",echo = FALSE)
                # Falls im Rahmen des Ueberfuehrungsskriptes keine erfolgreiche Zuordnung stattgefunden hat, wird der Wert der Halde hinzugefuegt und in den Ausgabedaten entfernt.
                if (menge_checksumme <1){
                  halde <- rbind(halde,
                                c(as.character(datensatz[[temp.tabelle]][zeile,grep(pattern = "Patient",x = colnames(datensatz[[temp.tabelle]]))]),
                                  get_primary_icd(temp.tabelle, datensatz, zeile),
                                  register,temp.tabelle,temp.variable,
                                  paste0(as.character(temp.data.menge[which(!temp.data.menge%in%as.character(referenz_tabelle[,1]))]),collapse = ";"),"deleted"))
                  # Formatiere die aktuellen temporaeren Daten, sodass sie neue Werte annehmen koennen (as.character erlaubt es, as.factor erlaubt es nicht)
                  # Format the current temporary data to allow for new expressions (as.character allows new expressions, as.factor does not)
                  temp.data <- as.character(temp.data)
                  # Ueberpruefe fuer jeden Wert dieser Menge-Angabe, ob er sich auf der Referenz-Tabelle befindet. Behalte nur die zutreffenden Daten und schreibe sie in temp.data.
                  # split menge data into their elements, check for each if they are in the reference table and only keep those alligned values and write them into temp.data.
                  splitted_field <- unlist(strsplit(as.character(temp.data[zeile]), split = ";|\\|"))
                  splitted_field <- splitted_field[which(splitted_field %in% as.character(unlist(referenz_tabelle[,1]))==TRUE)]
                  temp.data[zeile] <- paste(splitted_field, sep = ";", collapse = ";")
                  temp.data <- as.factor(temp.data)
                }
              }
            }
            
          }
          # Ersetze im (Ausgabe-)Datensatz zu dieser Variable die Daten mit den transformierten Daten (temp.data).
          # Update the (transformed) output data for this variable with the just transformed data (temp.data).
          datensatz_transformiert[[temp.tabelle]][,temp.variable] <- temp.data
        }

        else if (zuweisungstabelle[zuweisungstabelle[,"variable"]==temp.variable,"methode"]=="numerisch") {
          #numerisch (z.B.: Abstand Tage, Tumorgroesse) (e.g. time between primary diagnosis and therapy, size of tumor)
          print("numerisch")
          # Es wird durch alle Angaben dieser Variable gelooped
          # Each data entry is looked on seperately
          for (zeile in 1:length(temp.data)) {
            # Sofern der Dateneintrag nicht "NA" ist, wird weiter verfahren.
            # If the data entry is not "NA" the alignment is proceeded.
            if (!is.na(temp.data[zeile])) {
              # Pruefung, ob sich der aktuelle Datenwert zwischen der ersten und zweiten Angabe auf der Referenztabelle befindet (einschliesslich der Grenzwerte)
              # Check, if the data value is in between the upper and lower limit given by the reference data (including the limit value).
              if (!(temp.data[zeile] >= referenz_tabelle[1,] & referenz_tabelle[2,] >= temp.data[zeile])) {
                # Sofern der Datenwert nicht den Referenzdaten entspricht, wird er unter Angabe des Pat-ID, des Registers und der Variable der Halde hinzugefuegt.
                # In the case that the data value does not adhere to the reference data, the value is added to "halde" by giving the patient-ID, registry-ID, 
                # name of the variable and name of the data value.
                halde <- rbind(halde, c(as.character(datensatz[[temp.tabelle]][zeile,grep(pattern = "Patient",x = colnames(datensatz[[temp.tabelle]]))]),
                              get_primary_icd(temp.tabelle, datensatz, zeile),
                              register,temp.tabelle,temp.variable,as.character(temp.data[zeile]),"deleted"))
                # Der Datenwert wird fuer die Ausgabedaten geloescht, sofern er nicht den Referenzdaten entspricht.
                # In the case of not adherence to the reference data, the data entry is replaced by "NA" for the output.
                temp.data[zeile] <- NA
              }
            }
          }
          # Fuege dem transformierten (Ausgabe-)Datensatz zu dieser Variable die transformierten Daten (temp.data) hinzu.
          # Update the transformed (output-) data for this variable with the just transformed data (temp.data).       
          datensatz_transformiert[[temp.tabelle]][,temp.variable] <- temp.data
        }

        else if (zuweisungstabelle[zuweisungstabelle[,"variable"]==temp.variable,"methode"]=="datum") {
          temp.data <- trimws(gsub("\\s+", "", temp.data))
          #datum 
          print("datum")
          #Special case: Bavarian Birthday is Age at diagnosis, thus no Date check needed
          if (temp.variable == "Geburtsdatum" && registerID == 9){
            temp.data.date <- temp.data
            

          }

          else{
            # Es wird durch alle Angaben dieser Variable gelooped
            # Each data entry is looked on seperately
            # read minimal and maximal date
            if (requireNamespace("lubridate", quietly = TRUE)) {
              minimal_date <- lubridate::ymd(referenz_tabelle[1,], tz = "UTC")
              maximal_date <- lubridate::ymd(referenz_tabelle[2,], tz = "UTC")
              temp.data.date <- lubridate::parse_date_time(temp.data, orders = c("%Y-%m-%d", "%Y"), exact = TRUE)
              for (zeile in 1:length(temp.data)) {
                # Sofern der Dateneintrag nicht "NA" ist, wird weiter verfahren.
                # If the data entry is not "NA" the alignment is proceeded.
                if (!is.na(temp.data[zeile]) && temp.data[zeile] != ""){
                  #try to convert string to date
                  # print(temp.data[zeile])
                  # temp.data[zeile] <- lubridate::parse_date_time(temp.data[zeile], orders = c("%Y-%m-%d", "%Y"), exact = TRUE)
                  # print(temp.data[zeile])
                  # Pruefung, ob sich der aktuelle Datenwert zwischen der ersten und zweiten Angabe auf der Referenztabelle befindet (einschliesslich der Grenzwerte)
                  # Check, if the data value is in between the upper and lower limit given by the reference data (including the limit value).
                  if (is.na(temp.data.date[zeile]) || temp.data.date[zeile] < minimal_date || temp.data.date[zeile] > maximal_date) {
                    # Sofern der Datenwert nicht den Referenzdaten entspricht, wird er unter Angabe des Pat-ID, des Registers und der Variable der Halde hinzugefuegt.
                    # In the case that the data value does not adhere to the reference data, the value is added to "halde" by giving the patient-ID, registry-ID, 
                    # name of the variable and name of the data value.
                    halde <- rbind(halde, c(as.character(datensatz[[temp.tabelle]][zeile,grep(pattern = "Patient",x = colnames(datensatz[[temp.tabelle]]))]),
                                    get_primary_icd(temp.tabelle, datensatz, zeile),
                                    register,temp.tabelle,temp.variable,as.character(temp.data[zeile]),"deleted"))
                    # Der Datenwert wird fuer die Ausgabedaten geloescht, sofern er nicht den Referenzdaten entspricht.
                    # In the case of not adherence to the reference data, the data entry is replaced by "NA" for the output.

                    temp.data.date[zeile] <- NA
                  }
                }
              }
            }
            else{
              #If lubridate is not installed, we ignore this column
              temp.data.date <- as.Date(temp.data, tryFormats=c("%Y-%m-%d", "%Y"), optional=TRUE)
            }
            
          }
          # Fuege dem transformierten (Ausgabe-)Datensatz zu dieser Variable die transformierten Daten (temp.data) hinzu.
          # Update the transformed (output-) data for this variable with the just transformed data (temp.data). 
          datensatz_transformiert[[temp.tabelle]][,temp.variable] <- temp.data.date
          
        }
        else if (zuweisungstabelle[zuweisungstabelle[,"variable"] == temp.variable,"methode"] == "referenz") {
          #referenz, (TNM, Therapieart, etc.) (TNM, therapy intention, etc.)
          print("referenz")
          # Erneute Formatierung der aktuellen Daten dieser Variable ins character-Format um durch Aenderungen neue Werte erzeugen zu koennen.
          # Reformatting the temp.data into character instead of factor, in order to be able to change entries into values not present before.
          temp.data <- as.character(temp.data)

          # get tnm versions to gather specific reference lists
          if (temp.variable %in% c("cTNM_T", "cTNM_N", "cTNM_M")){
            temp.data.control <- datensatz[[temp.tabelle]][, "cTNM_Version"]
          } else if (temp.variable %in% c("pTNM_T", "pTNM_N", "pTNM_M")){
            temp.data.control <- datensatz[[temp.tabelle]][, "pTNM_Version"]
          } else if (temp.variable %in% c("Folgeereignis_TNM_T", "Folgeereignis_TMN_N", "Folgeereignis_TNM_M")){
            temp.data.control <- datensatz[[temp.tabelle]][, "Folgeereignis_TNM_Version"]
          }

          # Es wird durch alle Angaben dieser Variable gelooped
          # Each data entry is looked on seperately
          for (zeile in seq(1, length(temp.data))) {
            if (zeile %% 5000 == 0) {print(zeile)}
            # Zwischenspeichern des aktuellen Dateneintrags.
            # saving the original data value currently looked at.
            if(is.na(temp.data[zeile]) | temp.data[zeile] == ""){
              next
            }
            temp.data.zeile.alt <- temp.data[zeile]

            #Special Case: For TNM, check if value is compliant to specific version
            if(temp.variable %in% c("cTNM_T","pTNM_T","Folgeereignis_TNM_T","cTNM_N","pTNM_N",
                                    "Folgeereignis_TNM_N","cTNM_M","pTNM_M","Folgeereignis_TNM_M")) {
              if (!is.na(temp.data.control[zeile])){
                if (temp.data.control[zeile] == "7"){
                  referenz_tnm <- referenz_tabelle_tnm[[1]][,1]
                } else if (temp.data.control[zeile] == "8") {
                  referenz_tnm <- referenz_tabelle_tnm[[2]][,1]
                } else {
                  referenz_tnm <- referenz_tabelle_tnm[[3]][,1]
                }
              } else {
                referenz_tnm <- referenz_tabelle_tnm[[3]][,1]
              }
              if (!as.character(temp.data[zeile]) %in% referenz_tnm) {
                source("./Transform_Utils.R",echo = FALSE)
              }
            } else {
              # Pruefung, ob der aktuelle Datenwert in der Referenztabelle vorhanden ist.
              # Check, if the data value is present in the reference data.
              if (!as.character(temp.data[zeile]) %in% referenz_tabelle[,1])  {
                # Sofern der Dateneintrag nicht in den Referenzdaten vorhanden ist, wird das Ueberfuehrungsskript verwendet.
                # In the case that the data value is not in the reference data, the "ueberfuehrungsskript" should perform transformations.
                source("./Transform_Utils.R",echo = FALSE)
              }
            }
            # Falls der aktuelle Datenwert weiterhin nicht auf der Referenztabelle zu finden ist, wird er unter Angabe der Pat-ID, der Register-ID und der Variable 
            # auf der Halde gespeichert und in den Ausgabedaten entfernt.
            # In the case that the current data value is not present in the reference data, it is placed on "halde" and the patient-id, registry-id and variable are addeded.
            # The value itself is deleted from the output data.
            if (!temp.data[zeile]%in%referenz_tabelle[,1]) {
              halde <- rbind(halde, c(as.character(datensatz[[temp.tabelle]][zeile,grep(pattern = "Patient",x = colnames(datensatz[[temp.tabelle]]))]),
                                      get_primary_icd(temp.tabelle, datensatz, zeile),
                                      register,temp.tabelle,temp.variable,temp.data[zeile],"deleted"))
              temp.data[zeile] <- NA
              # Sofern der urspruengliche Wert nicht den Referenzdaten entspricht und der urspruengliche Wert vom aktuellen Wert abweicht (temp.data.zeile.alt != temp.data[zeile])
              # soll der alte und der neue Wert mit dem Kuerzel "angepasst zu:" unter Angabe der Pat-ID, Register-ID und Variablenname der Halde hinzugefuegt werden.
              # If the original data value is not in the reference data and the current value differs from the original value due to performed transformations (temp.data.zeile.alt != temp.data[zeile])
              # the "halde" will be extended by the old and the new value with the note "angepasst zu:" (transformed to), the pat-id, registry-id and variable.
              }  else if (!temp.data.zeile.alt %in% referenz_tabelle[,1] && temp.data.zeile.alt!=temp.data[zeile]) {
              halde <- rbind(halde, c(as.character(datensatz[[temp.tabelle]][zeile,grep(pattern = "Patient",x = colnames(datensatz[[temp.tabelle]]))]),
                                      get_primary_icd(temp.tabelle, datensatz, zeile),
                                      register,temp.tabelle,temp.variable,paste0(temp.data.zeile.alt,"| mapped to: |",temp.data[zeile]),"mapped")) 
            }

          }
          # Die Daten der aktuellen Variable werden als Faktor formatiert
          # The data of the current variable are formated as factor
          temp.data <- as.factor(temp.data)
          # Dem Datensatz_transformiert (output) werden die veraenderten Werte der Variable hinzugefuegt.
          # The transformed data is copied into the output data (datensatz_transformiert)
          datensatz_transformiert[[temp.tabelle]][,temp.variable] <- temp.data
        } else { 
          print("anders")
        }
        gc(reset = TRUE)
      }
    } 
  }
  # Calculate Age at diagnosis
  if((temp.tabelle == "temp.tumor")) {
    print("Alter_bei_Diagnose")
    #To get the birthday of a patient, we have to join tumor and patient table
    mergedtables <- merge(datensatz_transformiert[["temp.patient"]], datensatz_transformiert[["temp.tumor"]], by.x = "Patient_ID", by.y= "Patient_ID_FK", all.y = TRUE, sort=FALSE)
    if((registerID != 9)){
      if (requireNamespace("lubridate", quietly = TRUE)) {
        data_diff <- lubridate::interval(mergedtables[,"Geburtsdatum"], mergedtables[,"Diagnosedatum"]) %/% lubridate::years(1)
      }
      else {
        data_diff <- as.numeric(format(mergedtables[,"Diagnosedatum"], "%Y")) - as.numeric(format(mergedtables[,"Geburtsdatum"], "%Y"))

        # Adjust for cases where the diagnosis date is before the birthday in the same year
        has_not_had_birthday <- format(mergedtables[,"Diagnosedatum"], "%m%d") < format(mergedtables[,"Geburtsdatum"], "%m%d")
        data_diff[has_not_had_birthday] <- data_diff[has_not_had_birthday] - 1
      }
    }
    else {
      #For Bavaria, they have written the Age at Diagnosis into the birthday field. Therefore, we copy it and delete it as birthday afterwards
      data_diff <- mergedtables[,"Geburtsdatum"]
      datensatz_transformiert[["temp.patient"]][,"Geburtsdatum"] <- ""
      write.csv(datensatz_transformiert[["temp.patient"]], paste0(OUTPUT_DIRECTORY,"/zwischenstand_",register,"_","temp.patient",".csv"),row.names = FALSE)
    }
    datensatz_transformiert[["temp.tumor"]][,"Alter_bei_Diagnose"] <- data_diff
    print("berechnet")
  }

  # Die Subtabelle (Abfrage nach XQuery temp.patient, temp.tumor, temp.folgeereignis, temp.modul-mamma, temp.op, temp.strahlentherapie, temp.systemisch) 
  # wird als  "zwischenstand_register_tabelle" lokal abgespeichert.
  # The current data table (XQuery patient, tumor, follow-up, module-mamma, surgery, radiation, systemic) is saved locally "zwischenstand_register_tabelle"
  # (intermediate-state_registry_table)
  write.csv(datensatz_transformiert[[temp.tabelle]],paste0(OUTPUT_DIRECTORY,"/zwischenstand_",register,"_",temp.tabelle,".csv"),row.names = FALSE)
}
# Die Werte der Halde werden ohne Patient-ID und ICD10-Code auf einzigartige Werte aggregiert (Vervielfaeltigung durch Pat-ID wird aufgeloest)
# The halde (log of non conform values) are aggregated to unique combinations leaving out the patiend-id and ICD-10 (multiplicity due to pat-id is solved)
halde_unique <- unique(halde[,which(!colnames(halde)%in%c("patid","tumoricd10"))])
# Die Werte der Halde werden auf die ICD10-Codes von AI-CARE gefiltert und es wird eine Halde ohne Patient-ID und ICD10-Code erstellt
# The log file is filtered to entries from AI-CARE relevant entities ICD10-Code C34,C50,C73 and multiple C80s for NHL.
halde_selected_entities <- halde[grep(x = halde[,"tumoricd10"],pattern = "34|50|73|80|81|82|83|84|85|86|87|88|89"),]
halde_unique_selected_entities <- unique(halde_selected_entities[,which(!colnames(halde_selected_entities)%in%c("patid","tumoricd10"))])
halde_selected_entities_no_registries_entities <- unique(halde_selected_entities[,which(!colnames(halde_selected_entities)%in%c("register","patid","tumoricd10"))])
# Lokales abspeichern der Halde mit und ohne Pat-ID und mit und ohne ICD10 im Ausgabedatenordner
# Locally saved halde with and without pat-ids or ICD10 in the output folder
write.csv(unique(halde),paste0(OUTPUT_DIRECTORY,"/halde.csv"),row.names = FALSE)
write.csv(halde_unique,paste0(OUTPUT_DIRECTORY,"/halde-ohne-patid.csv"),row.names = FALSE)
write.csv(halde_selected_entities,paste0(OUTPUT_DIRECTORY,"/halde-nur-aicareicd10.csv"),row.names = FALSE)
write.csv(halde_unique_selected_entities,paste0(OUTPUT_DIRECTORY,"/halde-ohne-patid-nur-aicareicd10.csv"),row.names = FALSE)
write.csv(halde_selected_entities_no_registries_entities,paste0(OUTPUT_DIRECTORY,"/halde-aicareicd10-variable-auspraegung.csv"),row.names = FALSE)
