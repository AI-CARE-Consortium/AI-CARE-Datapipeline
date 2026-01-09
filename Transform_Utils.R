# Anpassung von Angaben, sodass sie den Werten auf der Referenzliste entsprechen.
# Transformation of data values to allign them to the reference data.
# TNM ####
# Ist der aktuelle Variablenname einer der folgenden?
# Is the current variable name one of the following?
if (temp.variable %in% c("cTNM_T","pTNM_T","Folgeereignis_TNM_T","cTNM_N","pTNM_N",
                         "Folgeereignis_TNM_N","cTNM_M","pTNM_M","Folgeereignis_TNM_M")) {
  # Automatisches kleinschreiben aller Buchstaben und entfernen von Leerzeichen
  # lower case for all expressions and deletion of spaces
  temp.shift.data <- c(gsub(" ","", tolower(as.character((temp.data[zeile])))),0)
  # Ist die Kontrollnummer kleiner 1 (und entsprechend noch nicht angepasst)?
  # is the controlnumber smaller 1 (and therefore the value not yet fitting)?
  if (temp.shift.data[2]==0) {
    # Ist die kleingeschriebene Variante der Auspraegung auf der Referenzliste? Wenn Ja: Einfuegen des transformierten Wertes in temp.data[zeile] 
    # und erhoehen der Kontrollnummer auf 1 (Transformation erfolgreich durchgefuehrt)
    # is the lower case version of the value in the reference data? If so: replace original value with the transformed value and
    # adjust the controlnumber to 1 instead of 0 (succesfull transformation)
    if (temp.shift.data[1] %in% referenz_tnm){
      temp.data[zeile] <- temp.shift.data[1]
      temp.shift.data[2] <- 1
    }
  }
  # Ist die Kontrollnummer kleiner 1 (und entsprechend noch nicht angepasst)?
  # is the controlnumber smaller 1 (and therefore the value not yet fitting)? 
  if (temp.shift.data[2]==0) {
    # Extrahieren eines Ausdrucks aus dem aktuellen Wert der dem Muster (Zahl(1-4)+ optionaler Buchstabe(a-d)) entspricht.
    # extract substring of current value that is conform to the regular expression (number (1-4) + optional letter (a-d).
    m <- regexpr(pattern = "[0-4](([a-e]|mi)(?!dr|ra))?(\\((sn|i\\+|i-|mol\\+|mol-|f)\\)){0,2}",temp.shift.data[1], perl = TRUE)
    temp.m <- regmatches(temp.shift.data[1],m)
    # Sofern ein solcher Ausdruck gefunden worden ist (length > 0), naechste Zeilen ausfuehren
    # If this regular expression hit a substring (length>0) continue
    if(length(temp.m)>0){ 
      # UEberpruefe, ob der oben gefundene Ausdruck auf der Referenzliste zu finden ist. Wenn Ja: Einfuegen des transformierten Wertes in temp.data[zeile] 
      # und erhoehen der Kontrollnummer auf 1 (Transformation erfolgreich durchgefuehrt)
      # Check if the found substring is in the reference data. If so: replace original value with the transformed value and
      # adjust the controlnumber to 1 instead of 0 (succesfull transformation)
      if (temp.m %in% referenz_tnm){
        temp.data[zeile] <- temp.m
        temp.shift.data[2] <- 1
      }
    }
  } 
  # Ist die Kontrollnummer kleiner 1 (und entsprechend noch nicht angepasst)?
  # is the controlnumber smaller 1 (and therefore the value not yet fitting)?
  if (temp.shift.data[2]==0) {
    # Extrahieren eines Ausdrucks aus dem aktuellen Wert der dem Muster (Zahl(1-4)) entspricht.
    # extract substring of current value that is conform to the regular expression (number (1-4)).
    m <- regexpr(pattern = "[x0-4]",temp.shift.data[1])
    temp.m <- regmatches(temp.shift.data[1],m)
    # Sofern ein solcher Ausdruck gefunden worden ist (length > 0), naechste Zeilen ausfuehren
    # If this regular expression hit a substring (length>0) continue
    if(length(temp.m)>0){
      # UEberpruefe, ob der oben gefundene Ausdruck auf der Referenzliste zu finden ist. Wenn Ja: Einfuegen des transformierten Wertes in temp.data[zeile] 
      # und erhoehen der Kontrollnummer auf 1 (Transformation erfolgreich durchgefuehrt)
      # Check if the found substring is in the reference data. If so: replace original value with the transformed value and
      # adjust the controlnumber to 1 instead of 0 (succesfull transformation)
      if (temp.m %in% referenz_tnm) {
        temp.data[zeile] <- temp.m
        temp.shift.data[2] <- 1
      }
    }
  } 
}
  
# Menge ####  
# Ist der aktuelle Variablenname eine Menge ("Menge_OPS_code", "Menge_FM", "Weitere_Todesursachen")?
# Is the current variable name "Menge_OPS_code"?
if(temp.variable %in% c("Menge_OPS_code", "Menge_FM", "Primaerdiagnose_Menge_FM", "Weitere_Todesursachen")) {
  temp.data.menge
  # Erstellung der Kontrollnummern und der temporaeren Tabellen
  # Initiation of control numbers and temporary tables
  menge_checksumme <- 1
  temp.data.menge.positiv <- c()
  temp.data.menge.halde <- c()
  temp.data.menge.regex <- c()
  temp.data.menge.mapped_to <- c()
  temp.data.menge.mapped_from <- c()
  # Betrachtung aller Einzelangaben der Verketten Angabe Menge (PUL, BRA oder SKI aus "PUL;BRA;SKI")
  # Check for each element of the previously concatenated multiple value entry (for PUL, BRA and SKI independently instead of source "PUL;BRA;SKI")
  if(length(temp.data.menge) > 0){
    for (anteil in seq(1, length(temp.data.menge))) {
      curr_code <- temp.data.menge[anteil]

      if (curr_code != "") {

        # Findet sich die Einzelangabe auf mindestens einer Angabe der Referenztabelle wieder?
        # Does the current element fit as a pattern to at least one element of the reference data?
        if (length(grep(pattern = curr_code, x = referenz_tabelle[,1]))>0){
          # Erweitere die temporaere Tabelle der positiven (passenden) Werte um die aktuelle Einzelangabe
          # Append the temporary table of fitting values by this element
          temp.data.menge.positiv <- c(temp.data.menge.positiv, curr_code)
          # Erweitere die temporaere Tabelle der passenden Referenzdaten um den ersten (kuerzesten) Wert der Referenzdaten, 
          # der mit dem aktuellen Wert als regulaeren Ausdruck gefunden wird.
          # Append the temporary table of fitting Values from the reference data by the first (shortest) expression from the reference data, 
          # that is found using the current element as a regular expression.
          # temp.data.menge.regex <- c(temp.data.menge.regex,
          #                            as.character(sort(referenz_tabelle[grep(pattern = curr_ops,x = referenz_tabelle[,1]),1]))[1])
        }
        else {
          # Sofern die aktuelle Einzelangabe nicht in den Referenzdaten zu finden ist, wird dieser Wert auf die temporaere mengen.halte Datei kopiert.
          # If the current element does not fit the reference data in any pattern, it is placed in the temporary menge.halde object
          variable.kurz <- NULL

          #Special Case: Some FMs are coded as "CXX.X" instead of "XXX"
          if ((temp.variable=="Menge_FM") && (nchar(curr_code)==5)) {
            if (paste0(substr(curr_code,2,3),substr(curr_code,5, 5)) %in% referenz_tabelle[,1]) {
              variable.kurz <- paste0(substr(curr_code,2,3),substr(curr_code,5, 5))
              temp.data.menge.mapped_to <- c(temp.data.menge.mapped_to, variable.kurz)
              temp.data.menge.mapped_from <- c(temp.data.menge.mapped_from, curr_code)
            }
          } 

          if (is.null(variable.kurz)){
            #curr_code <- tolower(curr_code)
            if (temp.variable == "Menge_OPS_code"){
              temp.variable.under_bound <- 5
            } else if (temp.variable == "Weitere_Todesursachen") {
              temp.variable.under_bound <- 3
            }
            else {
              temp.variable.under_bound <- 1
            }
            for (i in seq(nchar(curr_code), temp.variable.under_bound)) {
              if (substr(curr_code, 1, i) %in% referenz_tabelle[,1]) {
                variable.kurz <- substr(curr_code, 1, i)
                temp.data.menge.mapped_to <- c(temp.data.menge.mapped_to, variable.kurz)
                temp.data.menge.mapped_from <- c(temp.data.menge.mapped_from, curr_code)
                break
              }
            }
          }
          if (is.null(variable.kurz)){
            temp.data.menge.halde <- c(temp.data.menge.halde,temp.data.menge[anteil])
          }
        }
      }
    }
  }
  # temp.data wird zu as.character formatiert.
  # temp.data is formated to as.character()
  temp.data <- as.character(temp.data)
  # temp.data wird durch die Werte ersetzt, die auf der Referenzliste gefunden worden sind.
  # temp.data is replaced by the those values that were found in the reference data.
  temp.data[zeile] <- paste0(c(temp.data.menge.positiv, temp.data.menge.mapped_to),collapse = ";")
  temp.data <- as.factor(temp.data)
  # Die halde wird durch die Anteile an Angaben ergaenzt, die sich nicht auf den Referenzlisten haben finden lassen.
  # The halde of not conform values is appended by those values that were not found in the reference data.
  halde[,"auspraegung"] <- as.character(halde[,"auspraegung"])
  if(length(temp.data.menge.halde) > 0){
    halde <- rbind(halde,c(as.character(datensatz[[temp.tabelle]][zeile,grep(pattern = "Patient",x = colnames(datensatz[[temp.tabelle]]))]),
                           get_primary_icd(temp.tabelle, datensatz, zeile),
                           register,temp.tabelle,temp.variable,paste0(c(temp.data.menge.halde),collapse = ";"),"deleted"))
  }
  
  if(length(temp.data.menge.mapped_from) > 0){
    halde <- rbind(halde, c(as.character(datensatz[[temp.tabelle]][zeile,grep(pattern = "Patient",x = colnames(datensatz[[temp.tabelle]]))]),
                            get_primary_icd(temp.tabelle, datensatz, zeile),
                            register,temp.tabelle,temp.variable,paste0(temp.data.menge.mapped_from,"| mapped to: |",temp.data.menge.mapped_to, collapse=";"),"mapped")) 
  }
 }

# ICD-10 Codes
# Ist der aktuelle Variablenname "Primaertumor_ICD"?
# Is the current variable name "Primaertumor_ICD"?
if (temp.variable %in% c("Primaertumor_ICD", "Todesursache_Grundleiden", "pTNM_UICC_Stadium", "cTNM_UICC_Stadium", "Folgeereignis_TNM_UICC")){
  # Auswahl des ersten Buchstabens/Zeichens der ICD-10 Angabe und angefuegt die ersten Zahlwerte, die auf diesem Buchstaben folgen (paste0())
  # Beispiel: Verkuerzung von C90.90 durch as.numeric(90.90)=90.9 auf C90.9, welches auf der Referenzliste ist.
  # Selection of first letter in the current element of primary diagnosis and the first (most often numbers) following this letter. 
  # Concatenation of this entries relieves of trailing zeros. Example: Shortening of C90.90 via as.numeric(90.90)=90.9 to C90.9.
  if (!is.na(temp.data[zeile])){
    if (toupper(temp.data[zeile]) %in% referenz_tabelle[,1]){
      temp.data[zeile] <- toupper(temp.data[zeile])
    }
    else{
      for (i in seq(nchar(temp.data[zeile]), 3)) {
        if (substr(temp.data[zeile], 1, i) %in% referenz_tabelle[,1]) {
          temp.data[zeile] <- substr(temp.data[zeile], 1, i)
          break
        }
      }
    }

  }
  # Pruefung, ob diese Verkuerzung (ohne ueberschuessige Nullen nach dem Komma) einen Wert aus den Referenzdaten ergibt. 
  # Wenn Ja: Ersatz des Ausgangswertes durch Verkuerzung
  # Alignment of shortened value (losing trailing zeros after comma) to the reference data is checked and potentially replaces current original element
  #if (variable.kurz %in% referenz_tabelle[,1]){
  #  temp.data[zeile] <- variable.kurz
  #}
}

##ICD_O####
#Ist der aktuelle Variablenname "Primaertumor_Topographie_ICD_O"?
# Is the current variable name "Primaertumor_Topographie_ICD_O"?
if (temp.variable == "Primaertumor_Topographie_ICD_O"){
  #Ueberpruefung ob der ICD_O-Code sechs Stellen hat, denn dann muesste bei diesen die letzte Stelle entfernt werden
  #Check whether the ICD_O code has six digits, because then the last digit must be removed
  if(nchar(temp.data[zeile])>=6){
    variable.kurz <- substr(x=temp.data[zeile] ,start = 1, stop = 5)
    
    # Pruefung, ob diese Verkuerzung  einen Wert aus den Referenzdaten ergibt. 
    # Wenn Ja: Ersatz des Ausgangswertes durch Verkuerzung
    # Alignment of shortened value to the reference data is checked and potentially replaces current original element
    if (variable.kurz %in% referenz_tabelle[,1]){
      temp.data[zeile] <- variable.kurz
    }
  }
}


### mapping of inzidenzort (translating older codes that were used before 2007 to up-to-date codes)

#If Inzidenzort is not Hesse, try to map some old codes to the new codes
if ((temp.variable == "Inzidenzort") && (registerID != 6)) {
  temp.data[zeile] <- as.character(temp.data[zeile])
  
  if (temp.data[zeile] %in% as.character(landkreis_zuordnung$old_number)) {
    find_index <- match(temp.data[zeile], as.character(landkreis_zuordnung$old_number))
    if (!is.na(find_index)) {
      temp.data[zeile] <- as.character(landkreis_zuordnung$new_number[find_index])
    }
  }
}
